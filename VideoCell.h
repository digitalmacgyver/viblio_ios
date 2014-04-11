//
//  VideoCell.h
//  Viblio_v2
//
//  Created by Vinay on 1/18/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *videoImage;

@property (weak, nonatomic) IBOutlet UIView *vwShareTag;
@property (weak, nonatomic) IBOutlet UIView *vwPlayShare;
@property (weak, nonatomic) IBOutlet UIView *vwShare;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinningWheel;

@property (nonatomic, strong) UIView *shareVw;
@property (weak, nonatomic) IBOutlet UIButton *btnFB;
@property (weak, nonatomic) IBOutlet UIButton *btnGoogle;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;
@property (weak, nonatomic) IBOutlet UIButton *btnMail;


@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;

@property (weak, nonatomic) NSString *cloudURL;

@property (nonatomic, strong) cloudVideos *video;

@property (nonatomic, strong)MPMoviePlayerController *moviePlayer;


-(void)handleRightSwipe : (id)sender;
@end
