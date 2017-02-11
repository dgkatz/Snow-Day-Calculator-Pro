//
//  detailViewController.m
//  Snow Day Calculator
//
//  Created by Daniel Katz on 11/22/16.
//  Copyright © 2016 Stratton Innovations. All rights reserved.
//

#import "detailViewController.h"

@interface detailViewController ()

@end

@implementation detailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adBanner2.adUnitID = @"ca-app-pub-2350587744441133/5786028008";
    self.adBanner2.rootViewController = self;
    GADRequest *req = [GADRequest request];
    req.testDevices = @[ @"98d95013da3554be2504310f7564c968" ];
    [self.adBanner2 loadRequest:req];
    [UIView animateWithDuration:3.0f animations:^{
        self.progressView.value = self.chance;
    }];
    
    self.inchesLabel.text = [NSString stringWithFormat:@"It's going to snow %d inches",self.inches];
    if (_warning == YES) {
        self.warningLabel.text = @"A snow storm warning has been issued";
    }
    else{
        self.warningLabel.text = @"A snow storm warning has been issued";
    }
    self.tempLabel.text = [NSString stringWithFormat:@"Temperatures are going to drop to %d° F",self.temp];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
