//
//  SettingViewController.m
//  AdMobShowroom_IOS
//
//  Created by MinJi Song on 11/6/15.
//  Copyright (c) 2015 MinJi Song. All rights reserved.
//

#import "SettingViewController.h"

#import "CellWithSwitch.h"
#import "CellWithTextField.h"

@interface SettingViewController ()

@property(nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SettingViewController

#pragma mark - Singleton Methods

+ (SettingViewController*)sharedSettingPreferences {
    static SettingViewController *sharedSettingController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettingController = [[self alloc] init];
    });
    return sharedSettingController;
}

- (id)init {
    if (self = [super init]) {
        NSLog(@"setting init called");
        
        [self loadSectionData];
    }
    return self;
}

UISwitch *defaultAdUnitSwitch; // Section1 switch
UISwitch *dfpInventorySwitch; // Section2 switch

static NSMutableDictionary *firstSectionData; // First section data
static NSMutableDictionary *secondSectionData; // Second section data

// Bundle path - 프로그램 최초 시작시 설정 상태를 초기화 시키는데 사용
NSString *section1_bundle_path;
NSString *section2_bundle_path;

// Document path - 상태를 저장해 놓은 파일 path (Bundle에 write할 수 없음으로 폴더 및 write할 수 있는 파일을 생성)
NSString *section1_documentsPath;
NSString *section2_documentsPath;

- (NSString*)getCustomAdUnitId {
    return [[firstSectionData objectForKey:@"value"] objectAtIndex:1];
}

- (NSString*)getCustomTargeting {
    return [[secondSectionData objectForKey:@"value"] objectAtIndex:1];
}

- (NSString*)getCustomAdSize {
    return [[secondSectionData objectForKey:@"value"] objectAtIndex:2];
}

-(Boolean)isUsingDefaultId {
    return defaultAdUnitSwitch.isOn;
}

-(Boolean)isUsingDfpInventroy {
    return dfpInventorySwitch.isOn;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadSectionData];
    
   //[self deleteSectionFiles];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Check switches' status
    
    switch (section) {
            // First section
        case 0:
            if([defaultAdUnitSwitch isOn]) return [[firstSectionData objectForKey:@"title"] count]-1;
            else return [[firstSectionData objectForKey:@"title"] count];
            break;
            // Second section
        case 1:
            if([dfpInventorySwitch isOn]) return [[secondSectionData objectForKey:@"title"] count];
            else return [[secondSectionData objectForKey:@"title"] count]-2;
        default:
            return 1;
            break;
    }
}

#pragma mark - Return section header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
(NSInteger)section {
    
    NSString *header = [[[self.dataArray objectAtIndex:section] objectForKey:@"header"] objectAtIndex:0];
    
    return header;
}

#pragma mark - Return footers depending on showing cells.
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    NSString *footer;
    
    if(section == 0) {
        footer = [[firstSectionData objectForKey:@"footer"] objectAtIndex:0];
        if(![self isUsingDefaultId]) {
            footer = [footer stringByAppendingFormat:@"\r%@",[[firstSectionData objectForKey:@"footer"] objectAtIndex:1]];
        }
    }
    else {
        footer = [[secondSectionData objectForKey:@"footer"] objectAtIndex:0];
        if([self isUsingDfpInventroy]) {
            footer = [footer stringByAppendingFormat:@"\r%@",[[secondSectionData objectForKey:@"footer"] objectAtIndex:1]];
            footer =[footer stringByAppendingFormat:@"\r%@",[[secondSectionData objectForKey:@"footer"] objectAtIndex:2]];
        }
    }
    return footer;
}

#pragma mark - Return a custom cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CellWithSwitch *switchCell = [tableView dequeueReusableCellWithIdentifier:@"CellWithSwitch"];
    CellWithTextField *textFieldCell = [tableView dequeueReusableCellWithIdentifier:@"CellWithTextField"];
    
    // IndexPath.row 가 0이면 switch가 있는 cell
    if(indexPath.row==0){
        
        // 재사용 셀
        if(switchCell == nil){
            switchCell = [[CellWithSwitch alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellWithSwitch"];
        }
        
        // 스위치 객체 연결
        if(indexPath.section==0){[switchCell.settingSwitch setOn:[defaultAdUnitSwitch isOn]];
            defaultAdUnitSwitch = switchCell.settingSwitch;
        }
        else{[switchCell.settingSwitch setOn:[dfpInventorySwitch isOn]];
            dfpInventorySwitch = switchCell.settingSwitch;
        }
        
        // 내용 연결
        switchCell.boldText.text = [[[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"title"] objectAtIndex:0];
        
        return switchCell;
    }else{
        
        // 재사용 셀
        if(textFieldCell == nil){
            textFieldCell = [[CellWithTextField alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellWithTextField"];
        }
        
        // 내용 연결
        textFieldCell.title.text = [[[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"title"] objectAtIndex:indexPath.row];
        textFieldCell.editableField.text = [[[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"value"] objectAtIndex:indexPath.row];
        
        // TextField tag설정, textField순서대로 1, 2, 3
        textFieldCell.editableField.tag = indexPath.section + indexPath.row;
        
        return textFieldCell;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 56;
}

- (IBAction)switchChanged:(id)sender {
    
    NSString *switchStatus;
    NSMutableDictionary *targetDictionary;
    
    [sender self]==defaultAdUnitSwitch.self?(targetDictionary=firstSectionData):(targetDictionary=secondSectionData);
    [sender isOn]?(switchStatus=@"YES"):(switchStatus=@"NO");
    
    // Change the value in the dictionary
    [[targetDictionary objectForKey:@"value"]replaceObjectAtIndex:0 withObject:switchStatus];
    
    [_tableView reloadData];
}

#pragma mark - TextField Delegate Methods

// Read the values from textfields and put them into the extern values.
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"tag : %ld",(long)textField.tag);
    
    switch (textField.tag) {
            // Custom Ad Unit ID.
        case 1: [[firstSectionData objectForKey:@"value"] replaceObjectAtIndex:1 withObject:textField.text];
            break;
            // Custom Targeting.
        case 2: [[secondSectionData objectForKey:@"value"] replaceObjectAtIndex:1 withObject:textField.text];
            break;
            // Custom Ad Size.
        case 3: [[secondSectionData objectForKey:@"value"] replaceObjectAtIndex:2 withObject:textField.text];
            break;
        default:
            break;
    }
}

#pragma mark - Back button is clicked
- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        [self saveSectionFiles];
    }
}

#pragma mark - Load sectionData from plist files and make editable copies
-(void)loadSectionData
{
    // plist bundle path
    section1_bundle_path = [[NSBundle mainBundle] pathForResource:@"section1" ofType:@"plist"];
    section2_bundle_path = [[NSBundle mainBundle] pathForResource:@"section2" ofType:@"plist"];
    
    // Writable folder path
    NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    // Append Directory's name to writable folder path
    NSString *directoryPath = [docsFolder stringByAppendingPathComponent:@"AdMobShowroomDirectory"];
    // Append files' name to dictionaryPath
    section1_documentsPath = [directoryPath stringByAppendingString:@"section1.plist"];
    section2_documentsPath = [directoryPath stringByAppendingString:@"section2.plist"];
    
    // The copes are already existing?
    if ([[NSFileManager defaultManager] fileExistsAtPath:section1_documentsPath] && [[NSFileManager defaultManager] fileExistsAtPath:section2_documentsPath]  )
    {
        // If "Yes", load exsting files.
        NSLog(@"files exist");
        firstSectionData = [NSMutableDictionary dictionaryWithContentsOfFile:section1_documentsPath];
        secondSectionData = [NSMutableDictionary dictionaryWithContentsOfFile:section2_documentsPath];
    }
    else{
        // If there are no copies which means it's the very first time to start this app.
        NSLog(@"make copies from bundle .plist files");
        
        // Check directory Path is correct.
        if(![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
        {
            NSError *error;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                           withIntermediateDirectories:NO
                                                            attributes:nil
                                                                 error:&error])
            {
                NSLog(@"Create directory error: %@", error);
            }
        }
        
        // Read .plist from bundle.
        
        // Load data and put them into arrays
        firstSectionData = [[NSMutableDictionary alloc] initWithContentsOfFile:section1_bundle_path];
        secondSectionData = [[NSMutableDictionary alloc] initWithContentsOfFile:section2_bundle_path];
        
        // save files (just to make it sure)
        [self saveSectionFiles];
    }
    
    // Add each of section data to an array
    self.dataArray = [[NSMutableArray alloc] init];
    [self.dataArray addObject:firstSectionData];
    [self.dataArray addObject:secondSectionData];
    
    // alloc UISwitches
    defaultAdUnitSwitch = [[UISwitch alloc] init];
    dfpInventorySwitch = [[UISwitch alloc] init];
    
    // Default - switches' status are 'off'
    [defaultAdUnitSwitch setOn:NO];
    [dfpInventorySwitch setOn:NO];
    
    // Set switches' status in regard to saved setting info
    if([[[firstSectionData objectForKey:@"value"] objectAtIndex:0] isEqualToString:@"YES"]){
        [defaultAdUnitSwitch setOn:YES];}
    if([[[secondSectionData objectForKey:@"value"] objectAtIndex:0] isEqualToString:@"YES"]){
        [dfpInventorySwitch setOn:YES];}
}

#pragma mark - Save setting status into a file
-(void)saveSectionFiles
{
    [firstSectionData writeToFile:section1_documentsPath atomically:YES];
    [secondSectionData writeToFile:section2_documentsPath atomically:YES];
    NSLog(@"file saved");
}

#pragma mark - Delete the file which is holding setting info
-(void)deleteSectionFiles
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:section1_documentsPath]&&[[NSFileManager defaultManager] fileExistsAtPath:section2_documentsPath ])		//Does file exist?
    {
        NSError *error;
        
        if (![[NSFileManager defaultManager] removeItemAtPath:section1_documentsPath error:&error] || [[NSFileManager defaultManager] removeItemAtPath:section2_documentsPath error:&error] )	//Delete them
        {
            NSLog(@"Delete file error: %@", error);
        }
        NSLog(@"files are deleted");
    }
}


@end
