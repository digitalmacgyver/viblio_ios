//
//  SettingsViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/23/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.settingsList = [APPMANAGER getSettings];
    [ViblioHelper setUpNavigationBarForController:self withLeftBarButtonSelector:@selector(cancelChanges) andRightBarButtonSelector:@selector(doneChanges)];
}

-(void)cancelChanges
{
    DLog(@"Log : Changes Cancelled initiated");
    // Revert the values in active Session
    
    [DBCLIENT rollbackChanges];
    DLog(@"Log : Default session settings are - %@", [DBCLIENT getSessionSettings]);

    DLog(@"Log : The settings now are - %@", APPMANAGER.activeSession);
    [(DashBoardNavController*)self.slidingViewController.topViewController popViewControllerAnimated:YES];
}

-(void)doneChanges
{
    DLog(@"Log : Changes Done initiated");
    
    NSDictionary *sessionVariables = [APPMANAGER getSessionKeysAndValues];
    NSArray *listAllKeys = [sessionVariables allKeys];
    
    for( NSString *key in listAllKeys )
    {
        [DBCLIENT updateSessionSettingsForKey:key forValue:((NSNumber*)sessionVariables[key]).integerValue];
    }
    
    DLog(@"Log : Check for the changes ---------");
    DLog(@"Log : Session settings now are - %@", [DBCLIENT getSessionSettings]);
    
    // Store the latest values in DB in the Session Manager instance
    
    APPMANAGER.activeSession = [DBCLIENT getSessionSettings];
    
    // Set device idle time based on the latest values
    
    if( APPMANAGER.activeSession.autolockdisable.integerValue )
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    else
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    
    [(DashBoardNavController*)self.slidingViewController.topViewController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma Table View Delegate Mehods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.settingsList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"settingsCell";
    
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.lblSettingsHeading.text = ((NSDictionary*)self.settingsList[indexPath.row])[@"title"];
    cell.lblSettingsSubTitle.text = ((NSDictionary*)self.settingsList[indexPath.row])[@"detail"];
    cell.settingSwitch.tag = indexPath.row;
    [self setSwitchStatusForCell:cell atIndexPath:indexPath];
    cell.lblSettingsHeading.font = [ViblioHelper viblio_Font_Regular_WithSize:18 isBold:NO];
    cell.lblSettingsSubTitle.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    cell.lblSettingsSubTitle.numberOfLines = 0;
 
    return cell;
}

-(void)setSwitchStatusForCell:(SettingsCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
        case 0:
            [cell.settingSwitch setOn:APPMANAGER.activeSession.autoSyncEnabled.boolValue animated:YES] ;
            break;
        case 1:
            [cell.settingSwitch setOn:APPMANAGER.activeSession.wifiupload.boolValue animated:YES];
            break;
        case 2:
            [cell.settingSwitch setOn:APPMANAGER.activeSession.backgroundSyncEnabled.boolValue animated:YES];
            break;
        case 3:
            [cell.settingSwitch setOn:APPMANAGER.activeSession.batterSaving.boolValue animated:YES];
            break;
        case 4:
            [cell.settingSwitch setOn:APPMANAGER.activeSession.autolockdisable.boolValue animated:YES];
            break;
        default:
            break;
    }
}

@end
