//
//  SharedVideo.m
//  Viblio_v2
//
//  Created by Vinay Raj on 13/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SharedVideo.h"

@implementation SharedVideo

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)SeeMoreClicked:(id)sender {
}


- (IBAction)PlayClicked:(id)sender {
    
    DLog(@"Log : Play clicked");
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(moviePlayerPlaybackStateDidChange:)  name:MPMoviePlayerPlaybackStateDidChangeNotification  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:stopVideo object:nil];
    
    [self registerForMovieNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    [APPCLIENT getTheCloudUrlForVideoStreamingForFileWithUUID:self.video.mediaUUID success:^(NSString *cloudURL)
     {
         DLog(@"Log : Cloud url obtained is - %@", cloudURL);
         self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: [NSURL URLWithString:cloudURL]]; //self.asset.defaultRepresentation.url];
         self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
         self.moviePlayer.view.frame = self.imgVwPoster.frame;
         [self.imgVwPoster.superview addSubview:self.moviePlayer.view];
         [self.moviePlayer.view addSubview:self.spinningWheel];
         
         [self.spinningWheel startAnimating];
         //[self bringSubviewToFront:self.moviePlayer.view];
         
         //        self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
         //        self.moviePlayer.shouldAutoplay = YES;
         //        self.moviePlayer.scalingMode= MPMovieScalingModeFill;
         //        self.moviePlayer.controlStyle =MPMovieControlStyleNone;
         
         //        // Registering tap gesture on Movie Player
         //        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playInFullScreen)];
         //        tapGestureRecognizer.numberOfTapsRequired = 1;
         //        [self.moviePlayer.view addGestureRecognizer:tapGestureRecognizer];
         //        self.moviePlayer.view.userInteractionEnabled = YES;
         //        tapGestureRecognizer.delegate = self;
         
         
         // Register for the playback finished notification
         [[NSNotificationCenter defaultCenter] addObserver:self // the object listening / "observing" to the notification
                                                  selector:@selector(myMovieFinishedCallback:) // method to call when the notification was pushed
                                                      name:MPMoviePlayerPlaybackDidFinishNotification // notification the observer should listen to
                                                    object:self.moviePlayer];
         
         [self.moviePlayer play];
         
         [self.btnPlay setHidden:YES];
         //    [self.btnStop setHidden:NO];
     }failure:^(NSError *error)
     {
         DLog(@"Log : Error in streaming the video....");
     }];
}


-(void)myMovieFinishedCallback:(id)sender
{
    DLog(@"Log : Movie finished...");
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.btnPlay setHidden:NO];
    //[self.btnStop setHidden:YES];
}

- (void)registerForMovieNotifications {
    //movie is ready to play notifications
    if ([self.moviePlayer respondsToSelector:@selector(loadState)]) {
        //this is a 3.2+ device
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        [self.moviePlayer prepareToPlay];
    }
    
    //movie has finished notification
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}


- (void)moviePlayerLoadStateChanged:(NSNotification*)notification {
    DLog(@"load state changed");
    
    //unless state is unknown, start playback
    if ([self.moviePlayer loadState] != MPMovieLoadStateUnknown) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        
        //        self.moviePlayer.view.frame = self.vwShare.frame;
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
        //        self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //        [self addSubview:self.moviePlayer.view];
        self.moviePlayer.fullscreen = NO;
        [self.moviePlayer play];
    }
}



- (void) moviePlayerPlaybackStateDidChange:(NSNotification*)notification {
    DLog(@"playbackDidChanged");
    MPMoviePlayerController *moviePlayer = notification.object;
    MPMoviePlaybackState playbackState = moviePlayer.playbackState;
    if(playbackState == MPMoviePlaybackStateStopped) {
        DLog(@"MPMoviePlaybackStateStopped");
    } else if(playbackState == MPMoviePlaybackStatePlaying) {
        [self.spinningWheel stopAnimating];
        DLog(@"MPMoviePlaybackStatePlaying");
    } else if(playbackState == MPMoviePlaybackStatePaused) {
        [self.spinningWheel startAnimating];
        DLog(@"MPMoviePlaybackStatePaused");
    } else if(playbackState == MPMoviePlaybackStateInterrupted) {
        DLog(@"MPMoviePlaybackStateInterrupted");
    } else if(playbackState == MPMoviePlaybackStateSeekingForward) {
        DLog(@"MPMoviePlaybackStateSeekingForward");
    } else if(playbackState == MPMoviePlaybackStateSeekingBackward) {
        DLog(@"MPMoviePlaybackStateSeekingBackward");
    }
}


- (void) moviePlayerLoadStateDidChange:(NSNotification *)notification
{
    MPMoviePlayerController *moviePlayerController = notification.object;
    NSMutableString *loadState = [NSMutableString new];
    MPMovieLoadState state = moviePlayerController.loadState;
    if (state & MPMovieLoadStatePlayable)
    {
        [self.spinningWheel startAnimating];
        [loadState appendString:@" | Playable"];
    }
    //[loadState appendString:@" | Playable"];
    if (state & MPMovieLoadStatePlaythroughOK)
    {
        [self.spinningWheel stopAnimating];
        [loadState appendString:@" | Playthrough OK"];
    }
    //[loadState appendString:@" | Playthrough OK"];
    if (state & MPMovieLoadStateStalled)
    {
        [self.spinningWheel startAnimating];
        [loadState appendString:@" | Stalled"];
    }
    //[loadState appendString:@" | Stalled"];
    
    DLog(@"Load State: %@", loadState.length > 0 ? [loadState substringFromIndex:3] : @"N/A");
}

- (IBAction)StopClicked:(id)sender {
}
@end
