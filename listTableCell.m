//
//  listTableCell.m
//  Viblio_v2
//
//  Created by Vinay on 1/28/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "listTableCell.h"

@implementation listTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       // self.lblUploadNow.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnPlayClicked:(id)sender {
    DLog(@"Log : the url is - %@", self.asset.defaultRepresentation.url);
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.asset.defaultRepresentation.url]; //self.asset.defaultRepresentation.url];
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.moviePlayer.view.frame = self.btnImage.frame;
    [self addSubview:self.moviePlayer.view];
    
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    self.moviePlayer.shouldAutoplay = YES;
    self.moviePlayer.scalingMode= MPMovieScalingModeFill;
    self.moviePlayer.controlStyle =MPMovieControlStyleNone;
    
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter] addObserver:self // the object listening / "observing" to the notification
                                             selector:@selector(myMovieFinishedCallback:) // method to call when the notification was pushed
                                                 name:MPMoviePlayerPlaybackDidFinishNotification // notification the observer should listen to
                                               object:self.moviePlayer];
    
    [self.moviePlayer play];
    
    [self.btnPlay setHidden:YES];
    [self.btnStop setHidden:NO];
}

-(void)myMovieFinishedCallback:(id)sender
{
    DLog(@"Log : Movie finished...");
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    
    [self.btnPlay setHidden:NO];
    [self.btnStop setHidden:YES];
}


- (IBAction)imfThumbTapped:(id)sender {
    DLog(@"Log : Image tapped");
    
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.asset.defaultRepresentation.url]; //self.asset.defaultRepresentation.url];
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.moviePlayer.view.frame = self.superview.frame;
    [self.superview addSubview:self.moviePlayer.view];
    
    //self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    self.moviePlayer.shouldAutoplay = YES;
    self.moviePlayer.fullscreen = YES;
    
    // self.moviePlayer.scalingMode= MPMovieScalingModeFill;
   // self.moviePlayer.controlStyle =MPMovieControlStyleNone;
    
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter] addObserver:self // the object listening / "observing" to the notification
                                             selector:@selector(myMovieFinishedCallback:) // method to call when the notification was pushed
                                                 name:MPMoviePlayerPlaybackDidFinishNotification // notification the observer should listen to
                                               object:self.moviePlayer];
    
    //Register for the Done button clicked notification
    [[NSNotificationCenter defaultCenter] addObserver:self // the object listening / "observing" to the notification
                                             selector:@selector(myMovieFinishedCallback:) // method to call when the notification was pushed
                                                 name:MPMoviePlayerDidExitFullscreenNotification // notification the observer should listen to
                                               object:self.moviePlayer];
    

    
    [self.moviePlayer play];
}

//-(void)myMoviePlayerDoneClicked:(NSNotification*)notification
//{
//    DLog(@"Log : Done clicked -1");
//    [self myMovieFinishedCallback:nil];
//    
////    NSNumber *reason = [notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
////    
////    if ([reason intValue] == MPMovieFinishReasonUserExited) {
////        
////        // done button clicked!
////        DLog(@"Log : Done button clicked");
////        
////    }
//}


- (IBAction)btnShareClicked:(id)sender {
}

- (IBAction)btnStopClicked:(id)sender {
    DLog(@"Log : Movie is to be stopped");
    [self.btnStop setHidden:YES];
    [self.btnPlay setHidden:NO];
    
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
}
@end
