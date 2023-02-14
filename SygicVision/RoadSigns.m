//
//  RoadSigns.m
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import "RoadSigns.h"

#import <VisionLib/SYVision.h>
#import <VisionLib/SYVisionConfig.h>
#import <VisionLib/SYVisionObject.h>

@interface RoadSigns () {
    
    NSMutableArray* roadSignLayers;
    CAShapeLayer *roadSignShapeLayer;
}
@end

@implementation RoadSigns

-(void)initShapeLayer:(CAShapeLayer*)layer width:(CGFloat)width color:(CGColorRef)color
{
    layer.strokeColor = color;
    layer.lineWidth = width;
    layer.fillColor = [[UIColor clearColor] CGColor];
}

-(void)clean
{
    self->roadSignShapeLayer.path = nil;
    [self clearRoadSignLayers];
}

- (nonnull CAShapeLayer*)getDrawingLayer
{
    roadSignLayers = [NSMutableArray new];
    roadSignShapeLayer = [CAShapeLayer layer];
    [self initShapeLayer:roadSignShapeLayer width:5.0 color:[[UIColor blueColor] CGColor]];
    return roadSignShapeLayer;
}

-(void)clearRoadSignLayers
{
    for (CAShapeLayer* layer in roadSignLayers) {
        [layer removeFromSuperlayer];
    }
    [roadSignLayers removeAllObjects];
}

-(void)draw:(nonnull NSArray<SYVisionObject*>*)visionObjects
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self clearRoadSignLayers];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        for (SYVisionObject* visionObject in visionObjects)
        {
            if (![visionObject isKindOfClass:[SYVisionSign class]])
                continue;
            
            SYVisionSign* sign = (SYVisionSign*)visionObject;
        
            CGPoint leftTop = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(sign.bounds.left, sign.bounds.top)];
            CGPoint leftBottom = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(sign.bounds.left, sign.bounds.bottom)];
            CGPoint rightTop = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(sign.bounds.right, sign.bounds.top)];
            CGPoint rightBottom = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake(sign.bounds.right, sign.bounds.bottom)];

            [path moveToPoint:leftTop];

            [path addLineToPoint:rightTop];
            [path addLineToPoint:rightBottom];
            [path addLineToPoint:leftBottom];
            [path addLineToPoint:leftTop];
        }
        
        self->roadSignShapeLayer.path = [path CGPath];
    });
}
@end
