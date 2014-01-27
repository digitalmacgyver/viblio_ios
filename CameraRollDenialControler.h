//
//  CameraRollDenialControlelrViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/23/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InitialSlidingViewController.h"
#import "LandingViewController.h"

@interface CameraRollDenialControler : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblContent1;
@property (weak, nonatomic) IBOutlet UILabel *lblContent2;

@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@end
