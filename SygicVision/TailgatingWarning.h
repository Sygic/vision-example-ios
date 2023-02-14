//
//  TailgatingWarning.h
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import <VisionLib/SYVisionLogic.h>

@interface TailgatingWarning : NSObject<SYVisionLogicDelegate> {
}

-(nonnull CAShapeLayer*)getDrawingLayer;
-(void)clean;

-(void)didDetectTailgating:(nullable SYVisionObject*)object withTimeDistance:(float)timeDistance;

@end
