//
//  infoViewController.h
//  Snow Day Calculator
//
//  Created by Daniel Katz on 10/22/16.
//  Copyright © 2016 Stratton Innovations. All rights reserved.
//
@import INTULocationManager;
#import <UIKit/UIKit.h>
@import MBCircularProgressBar;
@import GoogleMobileAds;
@import Firebase;
#import "Forecastr.h"
@interface infoViewController : UIViewController<GADInterstitialDelegate,UITableViewDelegate,UITableViewDataSource>{
    Forecastr *forecastr;
    NSString *prediction;
    BOOL SnowStormWarning;
}

@property (weak, nonatomic) IBOutlet GADBannerView *adBanner2;
@property(nonatomic, strong) GADInterstitial *interstitial;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *progressView;
@property (nonatomic) float chance;
@property (nonatomic) int inches;
@property (nonatomic) BOOL warning;
@property (nonatomic) int windSpeed;
@property (nonatomic) int temp;
- (IBAction)shareClicked:(id)sender;
- (IBAction)facebookClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
