//
//  ARNavigation.m
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import "ARNavigation.h"

#import <VisionLib/SYVision.h>
#import <VisionLib/SYVisionARObject.h>

@interface ARNavigation () {
    
    NSMutableArray* arObjectLayers;
    CAShapeLayer *arObjectShapeLayer;
}
@end

@implementation ARNavigation

-(void)initShapeLayer:(CAShapeLayer*)layer width:(CGFloat)width color:(CGColorRef)color
{
    layer.strokeColor = color;
    layer.lineWidth = width;
    layer.fillColor = [[UIColor clearColor] CGColor];
}

-(void)clean
{
    self->arObjectShapeLayer.path = nil;
    [self clearARObjectLayers];
}

- (nonnull CAShapeLayer*)getDrawingLayer
{
    arObjectLayers = [NSMutableArray new];
    arObjectShapeLayer = [CAShapeLayer layer];
    [self initShapeLayer:arObjectShapeLayer width:5.0 color:[[UIColor redColor] CGColor]];
    return arObjectShapeLayer;
}

-(void)clearARObjectLayers
{
    for (CAShapeLayer* layer in arObjectLayers) {
        [layer removeFromSuperlayer];
    }
    [arObjectLayers removeAllObjects];
}

-(void)drawARObject:(nullable SYVisionARObject*)arObject
{
    if (arObject == nil)
        return;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint leftTop = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(arObject.bounds.left, arObject.bounds.top)];
    CGPoint leftBottom = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(arObject.bounds.left, arObject.bounds.bottom)];
    CGPoint rightTop = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(arObject.bounds.right, arObject.bounds.top)];
    CGPoint rightBottom = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(arObject.bounds.right, arObject.bounds.bottom)];

    [path moveToPoint:leftTop];

    [path addLineToPoint:rightTop];
    [path addLineToPoint:rightBottom];
    [path addLineToPoint:leftBottom];
    [path addLineToPoint:leftTop];
    
    self->arObjectShapeLayer.path = [path CGPath];
}

-(void)draw:(nullable SYVisionARObject*)arObject
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self clearARObjectLayers];
        [self drawARObject:arObject];
    });
}
@end
