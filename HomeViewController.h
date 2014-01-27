//
//  HomeViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/17/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "VideoCell.h"
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *videoList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIButton *btnMyViblio;
@property (weak, nonatomic) IBOutlet UIButton *btnSharedWithMe;

@end
