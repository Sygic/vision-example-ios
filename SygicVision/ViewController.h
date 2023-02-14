//
//  ViewController.h
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VisionLib/SYVision.h>
#import <VisionLib/SYVisionLogic.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<SYVisionDelegate, SYVisionCameraDelegate, SYVisionLogicDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate> {
    
    __weak IBOutlet UIView *previewLayer;
    __weak IBOutlet UIImageView *debugView;
}

@end
