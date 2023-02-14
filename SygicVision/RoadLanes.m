//
//  RoadLanes.m
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import "RoadLanes.h"

#import <VisionLib/SYVision.h>
#import <VisionLib/SYVisionConfig.h>
#import <VisionLib/SYVisionRoad.h>

@interface RoadLanes () {
    
    NSMutableArray* roadLaneLayers;
    CAShapeLayer *roadLaneShapeLayer;
}
@end

@implementation RoadLanes

-(void)initShapeLayer:(CAShapeLayer*)layer width:(CGFloat)width color:(CGColorRef)color
{
    layer.strokeColor = color;
    layer.lineWidth = width;
    layer.fillColor = [[UIColor clearColor] CGColor];
}

-(void)clean
{
    self->roadLaneShapeLayer.path = nil;
    [self clearRoadLaneLayers];
}

- (nonnull CAShapeLayer*)getDrawingLayer
{
    roadLaneLayers = [NSMutableArray new];
    roadLaneShapeLayer = [CAShapeLayer layer];
    [self initShapeLayer:roadLaneShapeLayer width:5.0 color:[[UIColor greenColor] CGColor]];
    return roadLaneShapeLayer;
}

-(void)clearRoadLaneLayers
{
    for (CAShapeLayer* layer in roadLaneLayers) {
        [layer removeFromSuperlayer];
    }
    [roadLaneLayers removeAllObjects];
}

-(void)draw:(nonnull SYVisionRoad*)visionRoad
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self clearRoadLaneLayers];
        
        UIBezierPath* path = [UIBezierPath bezierPath];
        
        for (SYVisionLane* lane in [visionRoad lanes])
        {
            CGPoint a = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake([lane line].x1, [lane line].y1)];
            CGPoint b = [[SYVision sharedVision] pointForCaptureDevicePoint:CGPointMake([lane line].x2, [lane line].y2)];

            [path moveToPoint:a];
            [path addLineToPoint:b];
        }
        
        self->roadLaneShapeLayer.path = [path CGPath];
    });
}
@end
