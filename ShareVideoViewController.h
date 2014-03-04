//
//  ShareVideoViewController.h
//  Viblio_v2
//
//  Created by Vinay Raj on 25/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "VideoCell.h"
#import "listTableCell.h"

@interface ShareVideoViewController : UIViewController
{
    BOOL m_postingInProgress;
}

@property (weak, nonatomic) IBOutlet UIView *vsSharingOpitons;
@property (weak, nonatomic) IBOutlet UITextView *txtVwBody;
@property (weak, nonatomic) IBOutlet UITextField *txtFiledTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtSubject;
@property (weak, nonatomic) IBOutlet UIView *vwBody;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgVw;


@property (weak, nonatomic) IBOutlet UIButton *btnMail;
@property (weak, nonatomic) IBOutlet UIButton *btnFB;

@property (nonatomic, strong) AFJSONRequestOperation* op;

@property (nonatomic, strong) FBRequestConnection *requestConnection;

@end
