//
//  ViewController.h
//  Snow Day Calculator
//
//  Created by Daniel Katz on 10/22/16.
//  Copyright © 2016 Stratton Innovations. All rights reserved.
//
@import INTULocationManager;
@import GoogleMobileAds;
#import <UIKit/UIKit.h>
#import "Forecastr.h"
#import "infoViewController.h"
@interface ViewController : UIViewController{
    Forecastr *forecastr;
}

@property (weak, nonatomic) IBOutlet GADBannerView *adBanner;
@property (nonatomic) float percentChance;
@property (nonatomic) int inchesOfSnow;
@property (nonatomic) BOOL snowWarining;
@property (nonatomic) int temperature;
- (IBAction)facebookClicked:(id)sender;

@end

