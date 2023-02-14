//
//  CarDistance.m
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import "CarDistance.h"

#import <VisionLib/SYVision.h>
#import <VisionLib/SYVisionConfig.h>
#import <VisionLib/SYVisionObject.h>

@interface CarDistance () {
    
    NSMutableArray* carLayers;
    CAShapeLayer *carShapeLayer;
}
@end

@implementation CarDistance

-(void)initShapeLayer:(CAShapeLayer*)layer width:(CGFloat)width color:(CGColorRef)color
{
    layer.strokeColor = color;
    layer.lineWidth = width;
    layer.fillColor = [[UIColor clearColor] CGColor];
}

-(void)clean
{
    self->carShapeLayer.path = nil;
    [self clearCarLayers];
}

- (nonnull CAShapeLayer*)getDrawingLayer
{
    carLayers = [NSMutableArray new];
    carShapeLayer = [CAShapeLayer layer];
    [self initShapeLayer:carShapeLayer width:5.0 color:[[UIColor grayColor] CGColor]];
    return carShapeLayer;
}

-(void)clearCarLayers
{
    for (CAShapeLayer* layer in carLayers) {
        [layer removeFromSuperlayer];
    }
    [carLayers removeAllObjects];
}

-(void)addDistanceLabel:(CGPoint)textOrigin text:(NSString*)text font:(CFTypeRef)font size:(CGFloat)size color:(CGColorRef)color backgroundColor:(CGColorRef)backgroundColor width:(int)width height:(int)height
{
    CATextLayer *label = [CATextLayer new];
    [label setFont:font];
    [label setFontSize:size];
    [label setForegroundColor:color];
    [label setBackgroundColor:backgroundColor];
    
    [label setFrame:CGRectMake(textOrigin.x, textOrigin.y, width, height)];
    [label setString:text];
    [label setAlignmentMode:kCAAlignmentLeft];
    
    [carLayers addObject:label];
    [carShapeLayer addSublayer:label];
}

-(void)draw:(nonnull NSArray<SYVisionObject*>*)visionObjects
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self clearCarLayers];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        for (SYVisionObject* visionObject in visionObjects)
        {
            if (![visionObject isKindOfClass:[SYVisionVehicle class]])
                continue;
            
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
            
            [self addDistanceLabel:leftBottom text:[NSString stringWithFormat:@"%.2f m", [car distance]] font:@"Helvetica-Bold" size:30 color:[[UIColor whiteColor] CGColor] backgroundColor:[[UIColor blackColor] CGColor] width:120 height:30];
        }
        
        self->carShapeLayer.path = [path CGPath];
    });
}
@end
