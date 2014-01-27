//
//  SettingsCell.h
//  Viblio_v2
//
//  Created by Vinay on 1/23/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblSettingsHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblSettingsSubTitle;
@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;

@end
