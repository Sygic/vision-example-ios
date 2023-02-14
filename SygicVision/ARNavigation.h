//
//  ARNavigation.h
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import <VisionLib/SYVision.h>

@interface ARNavigation : NSObject {
}

-(nonnull CAShapeLayer*)getDrawingLayer;
-(void)draw:(nullable SYVisionARObject*)arObject;
-(void)clean;

@end

