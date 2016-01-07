//
//  ViewController.m
//  AdMobShowroom_IOS
//
//  Created by MinJi Song on 9/16/15.
//  Copyright (c) 2015 MinJi Song. All rights reserved.
//

#import "MasterViewController.h"

#import "Constants.h"
#import "AdViewController.h"

@interface MasterViewController () 

@property (weak, nonatomic) IBOutlet UIButton *button_320x50;
@property (weak, nonatomic) IBOutlet UIButton *button_320x100;
@property (weak, nonatomic) IBOutlet UIButton *button_300x250;
@property (weak, nonatomic) IBOutlet UIButton *button_468x60;
@property (weak, nonatomic) IBOutlet UIButton *button_728x90;
@property (weak, nonatomic) IBOutlet UIButton *button_smartBanner;
@property (weak, nonatomic) IBOutlet UIButton *button_interstitial;
@property (weak, nonatomic) IBOutlet UIButton *button_customSize;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Button bg color /*#e6e6e6*/
    [self.button_320x50 setBackgroundColor:buttonColor];
    [self.button_320x100 setBackgroundColor:buttonColor];
    [self.button_300x250 setBackgroundColor:buttonColor];
    [self.button_468x60 setBackgroundColor:buttonColor];
    [self.button_728x90 setBackgroundColor:buttonColor];
    [self.button_smartBanner setBackgroundColor:buttonColor];
    [self.button_interstitial setBackgroundColor:buttonColor];
    [self.button_customSize setBackgroundColor:buttonColor];
}

// Send button's title to the next view
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = sender;
        AdViewController *vc = segue.destinationViewController;
        vc.buttonTitle = btn.titleLabel.text;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
