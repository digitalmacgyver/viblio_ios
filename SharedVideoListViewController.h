//
//  SharedVideoListViewController.h
//  Viblio_v2
//
//  Created by Vinay Raj on 19/03/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedVideo.h"

@interface SharedVideoListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblOwnerName;
@property (weak, nonatomic) IBOutlet UIImageView *imgVwOwner;

@property (weak, nonatomic) IBOutlet UITableView *tblOwnerShared;

@property(nonatomic, strong) NSMutableArray *ownerSharedVideos;
@property (nonatomic, strong)NSDictionary *categorisedSharedList;

@end
