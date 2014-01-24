//
//  MenuViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/17/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "DashBoardNavController.h"
#import "LandingViewController.h"

//typedef NS_ENUM(NSInteger, Settings) {
//    VblHome = 0,
//    VblSetings,
//    VblHelp,
//    VblTellFriend,
//    VblFeedback,
//    VblPrivacy,
//    VblRate
//};


@interface MenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *menuList;
@property (weak, nonatomic) IBOutlet UIImageView *uploadingImg;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *lblProgressTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSyncNotInProgress;
@property (weak, nonatomic) IBOutlet UILabel *lblStatusBarBkgrnd;
@property (weak, nonatomic) IBOutlet UIView *vwSyncingFile;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailId;
//@property (nonatomic)Settings selectedOption;

@end
