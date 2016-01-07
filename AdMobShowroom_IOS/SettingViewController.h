//
//  SettingViewController.h
//  AdMobShowroom_IOS
//
//  Created by MinJi Song on 11/6/15.
//  Copyright (c) 2015 MinJi Song. All rights reserved.
//

@import UIKit;

@interface SettingViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

+ (SettingViewController*)sharedSettingPreferences;

// Switch event
- (IBAction)switchChanged:(id)sender;

// Get typed values from textFields
- (NSString*)getCustomAdUnitId;
- (NSString*)getCustomTargeting;
- (NSString*)getCustomAdSize;

// AdUnitId checking
- (Boolean)isUsingDefaultId;

// Inventory type checking
- (Boolean)isUsingDfpInventroy;

@end
