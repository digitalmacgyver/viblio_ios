//
//  TellAFriendViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/29/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

@interface TellAFriendViewController : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnGoogle;
@property (weak, nonatomic) IBOutlet UIButton *btnMail;
@property (weak, nonatomic) IBOutlet UITextView *txtVwTellAFriend;

@property (nonatomic, strong) AFJSONRequestOperation *op;
@property (weak, nonatomic) IBOutlet UIView *vwSharingOptions;

@end
