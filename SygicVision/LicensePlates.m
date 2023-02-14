//
//  LicensePlates.m
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import "LicensePlates.h"

#import <VisionLib/SYVision.h>
#import <VisionLib/SYVisionObject.h>

@interface LicensePlates () {
    
    NSMutableArray* licensePlateLayers;
    CAShapeLayer *licensePlateShapeLayer;
}
@end

@implementation LicensePlates

-(void)initShapeLayer:(CAShapeLayer*)layer width:(CGFloat)width color:(CGColorRef)color
{
    layer.strokeColor = color;
    layer.lineWidth = width;
    layer.fillColor = [[UIColor clearColor] CGColor];
}

-(void)clean
{
    self->licensePlateShapeLayer.path = nil;
    [self clearLicensePlateLayers];
}

- (nonnull CAShapeLayer*)getDrawingLayer
{
    licensePlateLayers = [NSMutableArray new];
    licensePlateShapeLayer = [CAShapeLayer layer];
    [self initShapeLayer:licensePlateShapeLayer width:5.0 color:[[UIColor yellowColor] CGColor]];
    return licensePlateShapeLayer;
}

-(void)clearLicensePlateLayers
{
    for (CAShapeLayer* layer in licensePlateLayers) {
        [layer removeFromSuperlayer];
    }
    [licensePlateLayers removeAllObjects];
}

-(void)addLicensePlateLabel:(CGPoint)textOrigin text:(NSString*)text font:(CFTypeRef)font size:(CGFloat)size color:(CGColorRef)color backgroundColor:(CGColorRef)backgroundColor width:(int)width height:(int)height
{
    CATextLayer *label = [CATextLayer new];
    [label setFont:font];
    [label setFontSize:size];
    [label setForegroundColor:color];
    [label setBackgroundColor:backgroundColor];
    
    [label setFrame:CGRectMake(textOrigin.x, textOrigin.y, width, height)];
    [label setString:text];
    [label setAlignmentMode:kCAAlignmentLeft];
    
    [licensePlateLayers addObject:label];
    [licensePlateShapeLayer addSublayer:label];
}

-(void)drawLicensePlate:(SYVisionText*)plate
{
    if (plate == nil)
        return;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint leftTop = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(plate.bounds.left, plate.bounds.top)];
    CGPoint leftBottom = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(plate.bounds.left, plate.bounds.bottom)];
    CGPoint rightTop = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(plate.bounds.right, plate.bounds.top)];
    CGPoint rightBottom = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(plate.bounds.right, plate.bounds.bottom)];

    [path moveToPoint:leftTop];

    [path addLineToPoint:rightTop];
    [path addLineToPoint:rightBottom];
    [path addLineToPoint:leftBottom];
    [path addLineToPoint:leftTop];

    [self addLicensePlateLabel:leftBottom text:plate.text font:@"Helvetica-Bold" size:30 color:[[UIColor yellowColor] CGColor] backgroundColor:[[UIColor blackColor] CGColor] width:180 height:30];
    
    self->licensePlateShapeLayer.path = [path CGPath];
}

//Callback with license plates and their positions
-(void)draw:(nonnull NSArray<SYVisionText*>*)licensePlates
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self clearLicensePlateLayers];
        
        for (SYVisionText* licensePlate in licensePlates)
        {
            [self drawLicensePlate:licensePlate];
        }
    });
}
@end
