//
//  detailViewController.h
//  Snow Day Calculator
//
//  Created by Daniel Katz on 11/22/16.
//  Copyright © 2016 Stratton Innovations. All rights reserved.
//
@import GoogleMobileAds;
@import Firebase;
#import <UIKit/UIKit.h>
@import MBCircularProgressBar;
@interface detailViewController : UIViewController
@property (nonatomic) int inches;
@property (nonatomic) BOOL warning;
@property (nonatomic) int temp;
@property (nonatomic) float chance;
@property (weak, nonatomic) IBOutlet UILabel *inchesLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet GADBannerView *adBanner2;

@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *progressView;
@end
