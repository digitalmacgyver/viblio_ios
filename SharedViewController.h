//
//  SharedViewController.h
//  Viblio_v2
//
//  Created by Vinay Raj on 13/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedVideo.h"

@interface SharedViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tblSharedList;
@property (nonatomic, strong) NSArray *sharedList;
@property (nonatomic, strong) NSDictionary *resCategorizedList;

@end
