//
//  SharedVideo.h
//  Viblio_v2
//
//  Created by Vinay Raj on 13/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharedVideo : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblOwnerName;
@property (weak, nonatomic) IBOutlet UIButton *btnSeeMore;
@property (weak, nonatomic) IBOutlet UIImageView *imgVwOwner;
@property (weak, nonatomic) IBOutlet UIImageView *imgVwPoster;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;
@property (weak, nonatomic) IBOutlet UILabel *lblVwCount;

@property (nonatomic, strong)SharedVideos *video;

@property (nonatomic, strong)MPMoviePlayerController *moviePlayer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinningWheel;

@end
