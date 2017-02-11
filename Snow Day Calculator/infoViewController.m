//
//  infoViewController.m
//  Snow Day Calculator
//
//  Created by Daniel Katz on 10/22/16.
//  Copyright © 2016 Stratton Innovations. All rights reserved.
//
#import "detailViewController.h"
#import "infoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+LBBlurredImage.h"
@interface infoViewController ()

@end

@implementation infoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-2350587744441133/9686031600"];
    self.interstitial.delegate = self;
    
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @"98d95013da3554be2504310f7564c968" ];
    [self.interstitial loadRequest:request];
    
    
    [FIRAnalytics logEventWithName:@"Info-Screen-View" parameters:@{
                                                                    kFIRParameterContentType:@"view",
                                                                    }];
    self.adBanner2.adUnitID = @"ca-app-pub-2350587744441133/4058300407";
    self.adBanner2.rootViewController = self;
    GADRequest *req = [GADRequest request];
    req.testDevices = @[ @"98d95013da3554be2504310f7564c968" ];
    [self.adBanner2 loadRequest:req];
    
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:5.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
                                                 [self sendWeatherRequest:currentLocation.coordinate.latitude :currentLocation.coordinate.longitude];
                                                 
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

    
    
//    [UIView animateWithDuration:3.0f animations:^{
//        self.progressView.value = self.chance;
//    }];
    // Do any additional setup after loading the view.
}
-(void)completeAlgorithim:(id)JSON1{
    float percentage = [self calculateChance:JSON1];
    if (percentage < 0.00) {
        percentage = 0.00;
    }
    [UIView animateWithDuration:1.f animations:^{
        self.progressView.value = percentage;
    }];
    NSLog(@"chance of snowday = %f percent",percentage);
    if (percentage >= 0 && percentage <= 30) {
        prediction = @"Little to no chance of a delay or snow day.";
    }
    else if (percentage >30 && percentage <=50){
        prediction = @"Possibility of delay, but small chance of a snow day";
    }
    else if (percentage > 50 && percentage <= 75){
        prediction = @"Possibility of Snow Day, high chance of a delay";
    }
    else{
        prediction = @"Vey high chance of a snow day, get ready to sled!";
    }
    [self.tableView reloadData];
}
-(void)sendWeatherRequest:(float)latidude :(float)longitude{
    forecastr = [Forecastr sharedManager];
    forecastr.apiKey = @"7058717313b4230506c38ea4f86a9c75";
    
    [forecastr getForecastForLatitude:latidude longitude:longitude time:nil exclusions:nil extend:nil language:nil success:^(id JSON) {
        //NSLog(@"JSON Response was: %@", JSON);
        [self completeAlgorithim:JSON];
    } failure:^(NSError *error, id response) {
        NSLog(@"Error while retrieving forecast: %@", [forecastr messageForError:error withResponse:response]);
    }];
}

-(float)calculateChance:(id)json{
    
    float chance = 0.0;
    self.inches = 0;
    self.temp = 0;
    self.windSpeed = 0;
    NSDictionary *daily = [json objectForKey:@"daily"];
    NSArray *data = [daily objectForKey:@"data"];
    
    int forcastDay = [self forcastDayIndex];
    NSDictionary *day = [data objectAtIndex:forcastDay];
    
    

    
    int tempMin = [[day objectForKey:@"temperatureMin"]intValue];
    self.temp = tempMin;
    float percipChance = [[day objectForKey:@"precipProbability"] doubleValue]*100;
    float percipIntensity = [[day objectForKey:@"precipIntensity"] floatValue];
    float accumulation = [[day objectForKey:@"precipAccumulation"] floatValue];
    NSString *inchesSnow = [NSString stringWithFormat:@"%ld", lroundf(ceil(accumulation))];
    self.inches = inchesSnow.intValue;
    
    NSString *pIntensityDescription = [forecastr descriptionForPrecipIntensity:percipIntensity];
    self.windSpeed = lroundf([[day objectForKey:@"windSpeed"] floatValue]);
    NSLog(@"chance: %f, intenstity: %f, accumulation:%@ , description: %@",percipChance,percipIntensity,inchesSnow,pIntensityDescription);
    NSString *precipType = [day objectForKey:@"precipType"];
    if (![precipType  isEqual: @"snow"]) {
        return chance;
    }
    NSArray *inchesArray = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    NSArray *multiplierArray = @[@0,@2,@5.333,@7,@5,@0,@10,@7.5,@3,@2.5];
    NSDictionary *multiplierDictionary = [[NSDictionary alloc]initWithObjects:multiplierArray forKeys: inchesArray];
    
    float multiplier = [[multiplierDictionary objectForKey:inchesSnow] floatValue];
    int difference = 5 - inchesSnow.intValue;
    int mulDifference = multiplier*difference;
    chance = percipChance - mulDifference;
    
    chance += [self warningBonus:json];
    
    chance += [self snowDaysDeductions:0];
    
    chance *= [self monthMultiplier];
    
    return chance;
}
-(int)warningBonus:(id)json{
    NSArray *warningDict = [json objectForKey:@"alerts"];
    if (warningDict.count >0) {
        SnowStormWarning = YES;
    }
    return (int)warningDict.count * 3;
}

-(int)snowDaysDeductions:(int)numSnowDays{
    return numSnowDays * -3;
}

-(float)monthMultiplier{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMMM"];
    NSString *month = [df stringFromDate:[NSDate date]];
    NSLog(@"month = %@",month);
    if ([month isEqualToString:@"November"]) {
        return 1.15;
    }
    else if ([month isEqualToString:@"December"]){
        return 1.0;
    }
    else if ([month isEqualToString:@"January"]){
        return 1.0;
    }
    else if ([month isEqualToString:@"February"]){
        return 1.05;
    }
    else if ([month isEqualToString:@"March"]){
        return 1.2;
    }
    return 1.0;
}

-(int)forcastDayIndex{
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEEE"];
    NSString *weekdayString = [NSString stringWithFormat:@"%@",[weekday stringFromDate:now]];
    NSLog(@"The day of the week is: %@", [weekday stringFromDate:now]);
    if ([weekdayString isEqualToString:@"Saturday"]){
        NSLog(@"index at staurday");
        return 2;
    }
    else if ([weekdayString isEqualToString:@"Friday"]){
        NSLog(@"index at friday");
        return 3;
    }
    NSLog(@"index other");
    return 1;
}


- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [self.interstitial presentFromRootViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailSeqgue"]) {
        detailViewController *controller = (detailViewController *)segue.destinationViewController;
        controller.chance = self.chance;
        controller.temp = self.temp;
        controller.warning = self.warning;
        controller.inches = self.inches;
    }
}


- (IBAction)shareClicked:(id)sender {
    [FIRAnalytics logEventWithName:kFIREventSelectContent
                        parameters:@{
                                     kFIRParameterItemID:@"Share",
                                     kFIRParameterContentType:@"button"
                                     }];

    NSString *shareText = [NSString stringWithFormat:@"Snow Day Calculator says there's a %ld%% chance of a snow day!",lroundf(self.progressView.value)];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/snow-day-calculator-students/id1182766086?ls=1&mt=8"];
    NSArray *activityItems = @[shareText,url];
    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewControntroller.excludedActivityTypes = @[];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityViewControntroller.popoverPresentationController.sourceView = self.view;
        activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
    }
    [self presentViewController:activityViewControntroller animated:true completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = self.tableView.frame.size.height/3;
    
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Prediction";
        cell.detailTextLabel.text = prediction;
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:15.0 weight:0.3]];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"Predicted Inches Of Snow";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d in",self.inches];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:22.0 weight:0.3]];
        
    }
    if (indexPath.row == 2) {
        cell.textLabel.text = @"Wind Speed";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d mph",self.windSpeed];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:22.0 weight:0.3]];
        
    }
    if (indexPath.row == 4) {
        cell.textLabel.text = @"Snow Storm Warning";
        NSString *warning;
        if (SnowStormWarning == YES) {
            warning = @"Yes";
        }
        else{
            warning = @"No";
        }
        cell.detailTextLabel.text = warning;
        cell.detailTextLabel.textColor = [UIColor redColor];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:22.0 weight:0.3]];
        
    }
    if (indexPath.row == 3) {
        cell.textLabel.text = @"Low Tempurature";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d\u00B0",self.temp];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:22.0 weight:0.3]];
        
    }
    cell.textLabel.textColor = [UIColor grayColor];
    [cell.textLabel setFont:[UIFont systemFontOfSize:15.0]];
    cell.userInteractionEnabled = NO;
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
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
