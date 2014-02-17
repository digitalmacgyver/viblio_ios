//
//  FeedBackViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/29/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

@interface FeedBackViewController : UIViewController<UITextViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnBravo;
@property (weak, nonatomic) IBOutlet UIButton *btnBug;
@property (weak, nonatomic) IBOutlet UIButton *btnIdea;
@property (weak, nonatomic) IBOutlet UITextView *fdbckTxtVw;

@end
