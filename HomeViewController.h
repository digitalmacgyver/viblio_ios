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
#import "ListViewController.h"
#import "SharedViewController.h"
#import "LandingViewController.h"
#import "SharedVideoListViewController.h"

@interface HomeViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *videoList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIButton *btnMyViblio;
@property (weak, nonatomic) IBOutlet UIButton *btnSharedWithMe;
@property (nonatomic, strong) ListViewController *list;
@property (nonatomic, strong) SharedViewController *sharedList;

@property(nonatomic, strong) UIAlertView *errorAlert;
@property (weak, nonatomic) IBOutlet UIView *vwShareAnimate;

@property (nonatomic, strong)VideoCell *cell;
@property (nonatomic, assign) NSInteger indexClicked;

@property (nonatomic, strong)UIView *popUp;
@property (weak, nonatomic) IBOutlet UIView *vwShare;
@property (nonatomic, strong) SharedVideoListViewController *sharedOwnerList;

@property (nonatomic, strong) NSMutableArray *requestQueue;

@end
