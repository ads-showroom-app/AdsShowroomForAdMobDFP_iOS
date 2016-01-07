//
//  AppDelegate.h
//  AdMobShowroom_IOS
//
//  Created by MinJi Song on 9/16/15.
//  Copyright (c) 2015 MinJi Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// GA Tracker
@property(nonatomic, strong) id<GAITracker> tracker;
@end

