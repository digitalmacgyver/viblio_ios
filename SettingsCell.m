//
//  SettingsCell.m
//  Viblio_v2
//
//  Created by Vinay on 1/23/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SettingsCell.h"

@implementation SettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)switchValueAltered:(id)sender {
    
    NSArray *settings = [APPMANAGER getSettings];
    UISwitch *settingSwitch = (UISwitch*)sender;
    
    DLog(@"Log : Switch value altered for --- %@", ((NSDictionary*)settings[settingSwitch.tag])[@"title"]);
    
    switch (settingSwitch.tag) {
        case 0:
            DLog(@"Log : The value of wifiupload now is - %d", APPMANAGER.activeSession.wifiupload.boolValue);
            APPMANAGER.activeSession.wifiupload = @(settingSwitch.on);
            break;
        case 1:
            APPMANAGER.activeSession.backgroundSyncEnabled = @(settingSwitch.on);
            break;
        case 2:
            APPMANAGER.activeSession.batterSaving = @(settingSwitch.on);
            break;
        case 3:
            APPMANAGER.activeSession.autolockdisable = @(settingSwitch.on);
            break;
        default:
            break;
    }
}

@end
