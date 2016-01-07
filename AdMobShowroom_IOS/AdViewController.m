//
//  AdViewController.m
//  AdMobShowroom_IOS
//
//  Created by MinJi Song on 9/16/15.
//  Copyright (c) 2015 MinJi Song. All rights reserved.
//

#import "AdViewController.h"

#import "Constants.h"
#import "SettingViewController.h"
#import "AppDelegate.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface AdViewController () <GADBannerViewDelegate, GADInterstitialDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// AdMob Interstitial type ad
@property(nonatomic) GADInterstitial *admobInterstitial;

// DFP Interstitial type ad
@property (nonatomic) DFPInterstitial *dfpInterstitial;

// Banner type ad
@property (strong, nonatomic) UIView *adUIView;

// Admob banner Ad
@property (nonatomic) GADBannerView *admobBannerView;

// DFP banner Ad
@property (nonatomic) DFPBannerView *dfpBannerView;

// AdUnitId
@property (nonatomic) NSString *adUnitId;

// Map it with sizes
@property (nonatomic, copy) NSDictionary *ads;

// Setting info
@property SettingViewController *sharedSetting;

@end

@implementation AdViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.sharedSetting = [SettingViewController sharedSettingPreferences];
    
    self.ads = @{
                 @"320x50" : NSValueFromGADAdSize(kGADAdSizeBanner),
                 @"320x100" : NSValueFromGADAdSize(kGADAdSizeLargeBanner),
                 @"Smart Banner" : NSValueFromGADAdSize(kGADAdSizeSmartBannerPortrait),
                 @"468x60" : NSValueFromGADAdSize(kGADAdSizeFullBanner),
                 @"300x250" : NSValueFromGADAdSize(kGADAdSizeMediumRectangle),
                 @"728x90" : NSValueFromGADAdSize(kGADAdSizeLeaderboard)
                 };

    if(![_buttonTitle isEqualToString:@"Interstitial"]){
        //Load BannerAd
        [self loadBannerAd];
    } else{
        //Create and load Interstitial
        [self createAndLoadInterstitial];
    }
    
    [self sendGAData];
}

- (void)createAndLoadInterstitial {
    
    [self setAdUnitId];
    
    // AdMob Inventory
    if(![self.sharedSetting isUsingDfpInventroy]){
    self.admobInterstitial =[[GADInterstitial alloc] initWithAdUnitID:self.adUnitId];
    self.admobInterstitial.delegate = self;
    
    GADRequest *request = [GADRequest request];
        [self.admobInterstitial loadRequest:request];
    }
    // DFP Inventory
    else {
        self.dfpInterstitial = [[DFPInterstitial alloc] initWithAdUnitID:self.adUnitId];
        self.dfpInterstitial.delegate = self;
        
        DFPRequest *request;
        
        // Targeting field is not empty.
        if(![[self.sharedSetting getCustomTargeting] isEqualToString:@""]){
            request = [self setTargeting:[self.sharedSetting getCustomTargeting]];
        }else{
        request = [DFPRequest request];
        }
        
        [self.dfpInterstitial loadRequest:request];
    }
    
}

#pragma - mark GADBannerView delegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    [self printingLogWith:@"successfully loaded"];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSString * __weak errorMsg = @"adView:didFailToReceiveAdWithError: ";
    errorMsg = [errorMsg stringByAppendingFormat:@"%@",[error localizedDescription]];
    
    [self printingLogWith:errorMsg];
}

#pragma mark GADInterstitialDelegate implementation

- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {

    // Using AdMob inventory
    if(![self.sharedSetting isUsingDfpInventroy]){
    [self.admobInterstitial presentFromRootViewController:self];
    }
    // Using DFP inventory
    else{
        [self.dfpInterstitial presentFromRootViewController:self];
    }
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    [self printingLogWith:@"Closed."];
}

-(NSString*)getCurrentTime {
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [timeFormatter setDateFormat:@"HH:mm:ss.SSS"];
    
    NSString *currentTime = @"";
    currentTime = [currentTime stringByAppendingFormat:@"[%@ %@]",[dateFormatter stringFromDate:today],[timeFormatter stringFromDate:today]];
 
    return currentTime;
}

-(void)printingLogWith:(NSString *)logStr{
    
    _logTextView.text = [_logTextView.text stringByAppendingFormat:@"\r%@ %@",[self getCurrentTime],logStr];
}

-(void)loadBannerAd {

    if([_buttonTitle isEqualToString:@"Custom Size"]){
        //DFP inventory에서만 가능
        self.dfpBannerView = [[DFPBannerView alloc] init];
        self.dfpBannerView.delegate = self;
        
        NSString *customSize = [self.sharedSetting getCustomAdSize];
        NSLog(@"size : %@",customSize);
        
        if(![customSize isEqualToString:@""]){
        GADAdSize customGADAdSize = GADAdSizeFromCGSize([self parsingAdSize:customSize]);
        self.dfpBannerView.adSize = customGADAdSize;
        self.dfpBannerView.rootViewController = self;
        _adUIView = self.dfpBannerView;
        }
        //custom size is not defined in the setting page so defalt is 300x300
        else{
            [self printingLogWith:@"Custom size is not defined."];
            [self printingLogWith:@"Show default custom size 300x300."];
            GADAdSize customGADAdSize = GADAdSizeFromCGSize([self parsingAdSize:@"300x300"]);
            self.dfpBannerView.adSize = customGADAdSize;
            self.dfpBannerView.rootViewController = self;
            _adUIView = self.dfpBannerView;        }
        
    }else{
        
        if([self.sharedSetting isUsingDfpInventroy]){
            self.dfpBannerView = [[DFPBannerView alloc] init];
            self.dfpBannerView.delegate = self;
            self.dfpBannerView.adSize = GADAdSizeFromNSValue(self.ads[_buttonTitle]);
            self.dfpBannerView.rootViewController = self;
            _adUIView = self.dfpBannerView;
            
        }else{
            self.admobBannerView = [[GADBannerView alloc] init];
            self.admobBannerView.delegate = self;
            self.admobBannerView.adSize = GADAdSizeFromNSValue(self.ads[_buttonTitle]);
            self.admobBannerView.rootViewController = self;
            _adUIView = self.admobBannerView;
        }
    }
    
    // Add bannerAd view
    [self.view addSubview:_adUIView];
    _adUIView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Layout constraints that align the banner view to the bottom center of the screen.
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_adUIView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_adUIView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self setAdUnitId];
    
    if([self.adUIView isKindOfClass:[self.dfpBannerView class]]) {
        
        self.dfpBannerView.adUnitID = self.adUnitId;
        DFPRequest *request = [DFPRequest request];
        
        // Targeting field is not empty.
        if(![[self.sharedSetting getCustomTargeting] isEqualToString:@""]){
            request = [self setTargeting:[self.sharedSetting getCustomTargeting]];
        }else{
            request = [DFPRequest request];
        }
        
        [self.dfpBannerView loadRequest:request];
    }
    
    if([self.adUIView isKindOfClass:[self.admobBannerView class]]) {
        
        self.admobBannerView.adUnitID = self.adUnitId;
        GADRequest *request = [GADRequest request];
        [self.admobBannerView loadRequest:request];
    }
}

-(CGSize)parsingAdSize: (NSString*)size {
    NSArray *widthAndHeight = [size componentsSeparatedByString:@"x"];
    float width;
    float height;
    
    if(widthAndHeight.count != 2){
        [self printingLogWith:@"Invalid customsize ad."];
        [self printingLogWith:@"Show 200x200 size ad by default."];
        return CGSizeMake(200,200);
    }
    else{
        width = [[widthAndHeight objectAtIndex:0] floatValue];
        height = [[widthAndHeight objectAtIndex:1] floatValue];
    
        return CGSizeMake(width, height);
    }
}

-(void)setAdUnitId {
    
    if([self.sharedSetting isUsingDefaultId]){
        
        [self printingLogWith:@"Start loading with default ad unit id..."];
        NSString *sizeStr = @"Set ad size - ";
        sizeStr = [sizeStr stringByAppendingFormat:@"%@",_buttonTitle];
        [self printingLogWith:sizeStr];
        
        if([self.buttonTitle isEqualToString:@"Interstitial"]){
            self.adUnitId = defaultInterstitialAdunitId;
        }else{
            self.adUnitId = defaultAdMobAdUnitId;
        }
        
    }else{
        
        NSString *adUnitIdStr = @"Start loading with ";
        adUnitIdStr = [adUnitIdStr stringByAppendingFormat:@"%@",[self.sharedSetting getCustomAdUnitId]];
        [self printingLogWith:adUnitIdStr];
        NSString *sizeStr = @"Set ad size - ";
        sizeStr = [sizeStr stringByAppendingFormat:@"%@",_buttonTitle];
        [self printingLogWith:sizeStr];
        
        self.adUnitId = [self.sharedSetting getCustomAdUnitId];
    }
    
    NSLog(@"%@",self.adUnitId);
}

#pragma mark - Set key-value for customTargeting
-(DFPRequest*)setTargeting:(NSString*)targetingData{
    
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableArray *values  = [[NSMutableArray alloc] init];
    
    NSArray *pares = [targetingData componentsSeparatedByString:@","];
    for(int i=0;i<pares.count;i++)
    {
        NSString *temp = [pares objectAtIndex:i];
        NSArray *onePare = [temp componentsSeparatedByString:@"="];
        [keys addObject:[onePare objectAtIndex:0]];
        [values addObject:[onePare objectAtIndex:1]];
    }

    DFPRequest *request = [DFPRequest request];
    
    // Imangine that (key : value) set is 1:1 relationship.
    for(int i=0;i<keys.count;i++){
        request.customTargeting = @{[keys objectAtIndex:i] : [values objectAtIndex:i]};
    }
    return request;
}

- (void)sendGAData{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    

    // AdUnitType
    NSString *type;
    if([self.sharedSetting isUsingDefaultId]){type = @"Default";}
    else if([self.sharedSetting isUsingDfpInventroy]){type = @"DFP";}
    else{type = @"AdMob";}
    [tracker set:[GAIFields customDimensionForIndex:2] value:type];
    
    // AdSize
    [tracker set:[GAIFields customDimensionForIndex:3] value:self.buttonTitle];
    
    // Set this ScreenName and send it 
    [tracker set:kGAIScreenName value:@"AdViewScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

@end
