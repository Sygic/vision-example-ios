//
//  RoadSigns.h
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import <VisionLib/SYVision.h>

@interface RoadSigns : NSObject {
}

-(nonnull CAShapeLayer*)getDrawingLayer;
-(void)draw:(nonnull NSArray<SYVisionObject*>*)visionObjects;
-(void)clean;

@end
