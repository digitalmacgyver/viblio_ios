//
//  SettingsViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/23/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsCell.h"
#import "ECSlidingViewController.h"
#import "DashBoardNavController.h"

@interface SettingsViewController : UIViewController

@property(strong, nonatomic) NSArray *settingsList;
@property (strong, nonatomic) IBOutlet UITableView *settingTblVw;

@end
