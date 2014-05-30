//
//  VideoCell.m
//  Viblio_v2
//
//  Created by Vinay on 1/18/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        DLog(@"LOG : Cell initialised");

        //self.videoImage.image = [self loadImage:self.asset];
        //[self.vwUpload setHidden:NO];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)playVideo:(id)sender {
    [self playMovieinFullScreen:NO];
}

- (IBAction)stopVideo:(id)sender {
}

-(void)playMovieinFullScreen:(BOOL)fullScreen
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:stopVideo object:nil] ;
    
    [self registerForMovieNotifications];
    
    [APPCLIENT getTheCloudUrlForVideoStreamingForFileWithUUID:self.video.uuid success:^(NSString *cloudURL)
     {
         DLog(@"Log : Cloud url obtained is - %@", cloudURL);
         
         self.cloudURL = cloudURL;
         
         [[NSNotificationCenter defaultCenter] postNotificationName:playVideo object:self];
         
//         self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: [NSURL URLWithString:cloudURL]];
//         self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
//         self.moviePlayer.view.frame = self.vwShare.frame;
//         //self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
//         
//         [self insertSubview:self.moviePlayer.view belowSubview:self.vwPlayShare];
//         [self addSubview:self.spinningWheel];
//         [self bringSubviewToFront:self.vwPlayShare];
//         
//         [[NSNotificationCenter defaultCenter] postNotificationName:playVideo object:self];
//         [self.spinningWheel startAnimating];
//         
//         self.moviePlayer.shouldAutoplay = YES;
//         
//         if( fullScreen )
//             [self playInFullScreen];
//         else
//         {
//             self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
//             self.moviePlayer.scalingMode= MPMovieScalingModeNone;
//         }
//         
//         // Register for the playback finished notification
//         [[NSNotificationCenter defaultCenter] addObserver:self // the object listening / "observing" to the notification
//                                                  selector:@selector(myMovieFinishedCallback:) // method to call when the notification was pushed
//                                                      name:MPMoviePlayerPlaybackDidFinishNotification // notification the observer should listen to
//                                                    object:self.moviePlayer];
//         
//         [self.moviePlayer play];
//         
//         [self.btnPlay setHidden:YES];
//         [self.btnStop setHidden:NO];
         
     }failure:^(NSError *error)
     {
         DLog(@"Log : Error in streaming the video....");
     }];
}


-(void)playInFullScreen
{
    DLog(@"Log : The movie has to be played in full screen...");
    self.moviePlayer.fullscreen = YES;
    self.moviePlayer.scalingMode = MPMovieScalingModeNone;
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
}


-(void)myMovieFinishedCallback:(id)sender
{
    DLog(@"Log : Movie finished...");
 
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.btnPlay setHidden:NO];
    [self.spinningWheel stopAnimating];
//    [self.moviePlayer.view removeFromSuperview];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification
//                                                  object:self.moviePlayer];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerDidExitFullscreenNotification
//                                                  object:self.moviePlayer];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerLoadStateDidChangeNotification
//                                                  object:self.moviePlayer];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMovieDurationAvailableNotification
//                                                  object:self.moviePlayer];
    [self.moviePlayer pause];
    self.moviePlayer.initialPlaybackTime = -1;
    [self.moviePlayer stop];
    self.moviePlayer.initialPlaybackTime = -1;
    [self.moviePlayer.view removeFromSuperview];
  //  [self.moviePlayer release];
    
    
//    [self.spinningWheel stopAnimating];
//    [self.moviePlayer.view removeFromSuperview];
//    self.moviePlayer = nil;
//    
//    [self.btnPlay setHidden:NO];
//    [self.btnStop setHidden:YES];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)registerForMovieNotifications {
    //movie is ready to play notifications
    if ([self.moviePlayer respondsToSelector:@selector(loadState)]) {
        //this is a 3.2+ device
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        [self.moviePlayer prepareToPlay];
    }
}


- (void)moviePlayerLoadStateChanged:(NSNotification*)notification {
    DLog(@"load state changed");
    
    //unless state is unknown, start playback
    if ([self.moviePlayer loadState] != MPMovieLoadStateUnknown) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
        self.moviePlayer.fullscreen = NO;
        [self.moviePlayer play];
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


- (IBAction)shareVideo:(id)sender {

    DLog(@"Log : Share video fired...");
    APPMANAGER.posterImageForVideoSharing = self.videoImage.image;
    APPMANAGER.sharingUUID = self.video.uuid;
    [[NSNotificationCenter defaultCenter] postNotificationName:showingSharingView object:self];
}

-(void)removeShareView
{
    
    [UIView animateWithDuration:0.4 animations:^
     {
         CGRect shareFrame = self.shareVw.frame;
         shareFrame.origin.x = self.frame.origin.x + self.frame.size.width;
         shareFrame.size.width = 0;
         self.shareVw.frame = shareFrame;
         
         CGRect btnTwitterFrame = self.btnTwitter.frame;
         btnTwitterFrame.origin.x = 0;//self.frame.origin.x + self.frame.size.width;
         btnTwitterFrame.size.width = 0;
         self.btnTwitter.frame = btnTwitterFrame;
         
         CGRect btnFBFrame = self.btnFB.frame;
         btnFBFrame.origin.x = 0;//self.frame.origin.x + self.frame.size.width;
         btnFBFrame.size.width = 0;
         self.btnFB.frame = btnFBFrame;
         
         CGRect btnGFrame = self.btnGoogle.frame;
         btnGFrame.origin.x = 0;//self.frame.origin.x  + self.frame.size.width;
         btnGFrame.size.width = 0;
         self.btnGoogle.frame = btnGFrame;
         
         CGRect btnMailFrame = self.btnMail.frame;
         btnMailFrame.origin.x = 0;//self.frame.origin.x  + self.frame.size.width;
         btnMailFrame.size.width = 0;
         self.btnMail.frame = btnMailFrame;
     } completion:^(BOOL isFinished)
     {
         [self.vwPlayShare setHidden:NO];
     }];
}

-(void)handleRightSwipe : (id)sender
{
    DLog(@"Log : Right Swipe detected");
    [self removeShareView];
//    
}

- (IBAction)shareViaFB:(id)sender {
    DLog(@"Log : Share via FB clicked - index - %d", self.btnShare.tag);
}
- (IBAction)shareViaGoogle:(id)sender {
}
- (IBAction)shareViaTwitter:(id)sender {
}
- (IBAction)shareViaMail:(id)sender {
    DLog(@"Log : Share via Mail clicked");
}

@end
