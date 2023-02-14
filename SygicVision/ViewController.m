//
//  ViewController.m
//  SygicVision
//
//  Created by Vlado Bedecs on 18/01/2019.
//  Copyright © 2019 Vlado Bedecs. All rights reserved.
//

#import "ViewController.h"
#import "LicensePlates.h"
#import "TailgatingWarning.h"
#import "ARNavigation.h"
#import "CarDistance.h"
#import "RoadSigns.h"
#import "RoadLanes.h"

#import <VisionLib/SYVision.h>
#import <VisionLib/SYVisionRoute.h>
#import <VisionLib/SYVisionConfig.h>

#import <CoreLocation/CoreLocation.h>

@interface ViewController ()
{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    TailgatingWarning* tailgatingWarning;
    LicensePlates* licensePlates;
    ARNavigation* arNavigation;
    CarDistance* carDistance;
    RoadSigns* roadSigns;
    RoadLanes* roadLanes;
}
@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

-(void)initShapeLayer:(CAShapeLayer*)layer width:(CGFloat)width color:(CGColorRef)color
{
    layer.strokeColor = color;
    layer.lineWidth = width;
    layer.fillColor = [[UIColor clearColor] CGColor];
}

-(void)cleanDebugInfo
{
    [licensePlates clean];
    [arNavigation clean];
    [roadSigns clean];
    [roadLanes clean];
    [tailgatingWarning clean];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Location init (for AR navi demonstration)
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    //Drawing layers
    licensePlates = [[LicensePlates alloc] init];
    arNavigation = [[ARNavigation alloc] init];
    carDistance = [[CarDistance alloc] init];
    roadSigns = [[RoadSigns alloc] init];
    roadLanes = [[RoadLanes alloc] init];
    tailgatingWarning = [[TailgatingWarning alloc] init];
    
    [debugView.layer addSublayer:[licensePlates getDrawingLayer]];
    [debugView.layer addSublayer:[arNavigation getDrawingLayer]];
    [debugView.layer addSublayer:[carDistance getDrawingLayer]];
    [debugView.layer addSublayer:[roadSigns getDrawingLayer]];
    [debugView.layer addSublayer:[roadLanes getDrawingLayer]];
    [debugView.layer addSublayer:[tailgatingWarning getDrawingLayer]];
    
    [[SYVisionLogic sharedVisionLogic] setDelegate:tailgatingWarning];
    
    //Vision init and camera start
    NSError* error = nil;
    [[SYVision sharedVision] initializeWithClientId:@"YOUR_CLIENT_ID" licenseKey:@"YOUR_LICENSE_KEY" error:&error];
    [[SYVision sharedVision] setDelegate:self];
    [[SYVision sharedVision] startCamera:self view:previewLayer debugView:nil];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Error: %@",error.description);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLocation = [locations lastObject];
    
    if (currentLocation != nil) {
        [[SYVision sharedVision] processRoute:[self getTestingRouteAtLocation:currentLocation]];
    }
}

- (void)dealloc {
    [[SYVision sharedVision] stopCamera];
}

-(SYVisionRoute*)getTestingRouteAtLocation:(CLLocation*)location
{
    //Simulating upcomming maneuver next to current position (allways at fixed distance, but close enough to activate feature tracking)
    SYVisionRoute* route = [[SYVisionRoute alloc] init];
    route.maneuverId = 1;
    route.maneuverPosition = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(location.coordinate.latitude + 0.00007, location.coordinate.longitude + 0.00007) altitude:-1 horizontalAccuracy:50 verticalAccuracy:50 timestamp:[NSDate date]];
    struct SYSize s = route.maneuverSize;
    s.width = 3;
    s.height = 1;
    route.maneuverSize = s;
    route.carPosition = location;
    return route;
}

//Vision callbacks
-(void)vision:(nonnull SYVision*)vision didDetectRoad:(nullable SYVisionRoad*)visionRoad withInfo:(nonnull SYVisionRoadInfo*)info
{
    [roadLanes draw:visionRoad];
}

-(void)vision:(nonnull SYVision*)vision didDetectObjects:(nonnull NSArray<SYVisionObject*>*)visionObjects withInfo:(nonnull SYVisionObjectsInfo*)info
{
    [roadSigns draw:visionObjects];
    [carDistance draw:visionObjects];
    [[SYVisionLogic sharedVisionLogic] addObjects:visionObjects withLocation:currentLocation];
}

-(void)vision:(nonnull SYVision*)vision didDetectLicensePlates:(nonnull NSArray<SYVisionText*>*)plates
{
    [licensePlates draw:plates];
}

-(void)vision:(nonnull SYVision*)vision shouldDrawARObject:(nullable SYVisionARObject*)arObject;
{
    [arNavigation draw:arObject];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
