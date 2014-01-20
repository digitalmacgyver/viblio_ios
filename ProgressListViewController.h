//
//  ProgressListViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/21/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "uploadProgress.h"

@interface ProgressListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (nonatomic, strong) NSArray *uploadArray;

@end
