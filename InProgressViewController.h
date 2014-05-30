//
//  InProgressViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/24/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "uploadProgress.h"
#import "UIButton+Additions.h"
#import "ECSlidingViewController.h"

@interface InProgressViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tblInProgress;
@property (nonatomic, strong)NSArray *videoList;
@property (nonatomic, retain)NSArray *completedList;

@property (nonatomic, assign) int celIndex;
@end
