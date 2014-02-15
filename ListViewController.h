//
//  ListViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/24/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "listTableCell.h"

@interface ListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UITableView *listView;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;

@property (nonatomic, strong)MPMoviePlayerController *moviePlayer;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinningWheel;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;

@property (nonatomic, strong) NSMutableDictionary *address,*dateStamp, *faceIndexes;

@end
