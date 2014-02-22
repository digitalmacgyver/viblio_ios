//
//  ListViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/24/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "listTableCell.h"
#import "ECSlidingViewController.h"

@interface ListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UITableView *listView;

@property (nonatomic, strong) listTableCell *listCell;
@property (nonatomic, strong) NSMutableDictionary *address,*dateStamp, *faceIndexes;
@property (nonatomic, strong) NSMutableDictionary *result;

@end
