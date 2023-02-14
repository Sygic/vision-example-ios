//
//  TailgatingWarning.m
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import "TailgatingWarning.h"

#import <VisionLib/SYVision.h>
#import <VisionLib/SYVisionConfig.h>
#import <VisionLib/SYVisionObject.h>

@interface TailgatingWarning () {
    
    NSMutableArray* tailgatingLayers;
    CAShapeLayer *tailgatingShapeLayer;
}
@end

@implementation TailgatingWarning

-(void)initShapeLayer:(CAShapeLayer*)layer width:(CGFloat)width color:(CGColorRef)color
{
    layer.strokeColor = color;
    layer.lineWidth = width;
    layer.fillColor = [[UIColor clearColor] CGColor];
}

-(void)clean
{
    self->tailgatingShapeLayer.path = nil;
    [self clearTailgatingLayers];
}

- (nonnull CAShapeLayer*)getDrawingLayer
{
    tailgatingLayers = [NSMutableArray new];
    tailgatingShapeLayer = [CAShapeLayer layer];
    [self initShapeLayer:tailgatingShapeLayer width:8.0 color:[[UIColor redColor] CGColor]];
    return tailgatingShapeLayer;
}

-(void)clearTailgatingLayers
{
    for (CAShapeLayer* layer in tailgatingLayers) {
        [layer removeFromSuperlayer];
    }
    [tailgatingLayers removeAllObjects];
}

-(void)addTimeDistanceLabel:(CGPoint)textOrigin text:(NSString*)text font:(CFTypeRef)font size:(CGFloat)size color:(CGColorRef)color backgroundColor:(CGColorRef)backgroundColor width:(int)width height:(int)height
{
    CATextLayer *label = [CATextLayer new];
    [label setFont:font];
    [label setFontSize:size];
    [label setForegroundColor:color];
    [label setBackgroundColor:backgroundColor];

    [label setFrame:CGRectMake(textOrigin.x, textOrigin.y, width, height)];
    [label setString:text];
    [label setAlignmentMode:kCAAlignmentLeft];

    [tailgatingLayers addObject:label];
    [tailgatingShapeLayer addSublayer:label];
}

-(void)didDetectTailgating:(nullable SYVisionObject*)visionObject withTimeDistance:(float)timeDistance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self clearTailgatingLayers];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        SYVisionVehicle* car = (SYVisionVehicle*)visionObject;
        
        CGPoint leftTop = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(car.bounds.left, car.bounds.top)];
        CGPoint leftBottom = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(car.bounds.left, car.bounds.bottom)];
        CGPoint rightTop = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(car.bounds.right, car.bounds.top)];
        CGPoint rightBottom = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(car.bounds.right, car.bounds.bottom)];

        [path moveToPoint:leftTop];

        [path addLineToPoint:rightTop];
        [path addLineToPoint:rightBottom];
        [path addLineToPoint:leftBottom];
        [path addLineToPoint:leftTop];
        
        [self addTimeDistanceLabel:leftTop text:[NSString stringWithFormat:@"%.2f s", timeDistance] font:@"Helvetica-Bold" size:30 color:[[UIColor redColor] CGColor] backgroundColor:[[UIColor blackColor] CGColor] width:120 height:30];
        
        self->tailgatingShapeLayer.path = [path CGPath];
    });
}

@end
