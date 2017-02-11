//
//  ViewController.m
//  Snow Day Calculator
//
//  Created by Daniel Katz on 10/22/16.
//  Copyright © 2016 Stratton Innovations. All rights reserved.
//
#import "ViewController.h"
@import Firebase;
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Home Screen View" parameters:@{
                                kFIRParameterContentType:@"view",
                                }];
    self.adBanner.adUnitID = @"ca-app-pub-2350587744441133/7430569204";
    self.adBanner.rootViewController = self;
    GADRequest *req = [GADRequest request];
    req.testDevices = @[ @"98d95013da3554be2504310f7564c968" ];
    [self.adBanner loadRequest:req];
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:5.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                 // However, currentLocation contains the best location available (if any) as of right now,
                                                 // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                             }
                                             else {
                                                 // An error occurred, more info is available by looking at the specific status returned.
                                             }
                                         }];
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"calculateSegue"]) {
        [FIRAnalytics logEventWithName:kFIREventSelectContent
                            parameters:@{
                                         kFIRParameterItemID:@"Calculate",
                                         kFIRParameterContentType:@"button"
                                         }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)facebookClicked:(id)sender {
    [FIRAnalytics logEventWithName:kFIREventSelectContent
                        parameters:@{
                                     kFIRParameterItemID:@"Like on Facebook",
                                     kFIRParameterContentType:@"button"
                                     }];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:[NSURL URLWithString:@"fb://profile/800956333350158"] options:@{} completionHandler:nil];
        
    }
    else {
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:[NSURL URLWithString:@"https://www.facebook.com/SnowDayApp"] options:@{} completionHandler:nil];
    }
}
@end
