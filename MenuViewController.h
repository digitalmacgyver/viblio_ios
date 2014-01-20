//
//  MenuViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/17/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

@interface MenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *menuList;

@property (weak, nonatomic) IBOutlet UIImageView *uploadingImg;
@property (weak, nonatomic) IBOutlet UIView *vwProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *lblProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *lblProgressTitle;
@end
