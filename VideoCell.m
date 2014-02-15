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
         self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: [NSURL URLWithString:cloudURL]];
         self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
         self.moviePlayer.view.frame = self.vwShare.frame;
         
         [self insertSubview:self.moviePlayer.view belowSubview:self.vwPlayShare];
         [self addSubview:self.spinningWheel];
         [self bringSubviewToFront:self.vwPlayShare];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:playVideo object:self];
         [self.spinningWheel startAnimating];
         
         self.moviePlayer.shouldAutoplay = YES;
         
         if( fullScreen )
         {
             [self playInFullScreen];
         }
         else
         {
             self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
             self.moviePlayer.scalingMode= MPMovieScalingModeNone;
         }
         
         // Registering tap gesture on Movie Player
//         UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playInFullScreen)];
//         tapGestureRecognizer.numberOfTapsRequired = 1;
//         [self.moviePlayer.view addGestureRecognizer:tapGestureRecognizer];
//         self.moviePlayer.view.userInteractionEnabled = YES;
//         tapGestureRecognizer.delegate = self;
         
         
         // Register for the playback finished notification
         [[NSNotificationCenter defaultCenter] addObserver:self // the object listening / "observing" to the notification
                                                  selector:@selector(myMovieFinishedCallback:) // method to call when the notification was pushed
                                                      name:MPMoviePlayerPlaybackDidFinishNotification // notification the observer should listen to
                                                    object:self.moviePlayer];
         
         [self.moviePlayer play];
         
         [self.btnPlay setHidden:YES];
         [self.btnStop setHidden:NO];
         
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
    [self.spinningWheel stopAnimating];
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    
    [self.btnPlay setHidden:NO];
    [self.btnStop setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self.vwShare setHidden:NO];
    [UIView animateWithDuration:1 animations:^
    {
        CGRect shareFrame = self.vwShare.frame;
        shareFrame.origin.x = self.frame.origin.x;
        self.vwShare.frame = shareFrame;
    }];
}

//- (IBAction)uploadClicked:(id)sender {
//    DLog(@"LOG : Upload video clicked");
//    
//    // Checking whether an upload is in progress.
//    // If an upload is in progres then we just make an update to the DB
//    // We change the sync_status of the video file to 1 so that its taken on priority
//    
//    DLog(@"Log : Upload initialised for video - %@", self.asset);
//    [DBCLIENT updateSynStatusOfFile:self.video.fileURL syncStatus:1];
//    
//    if( VCLIENT.asset == nil )
//    {
//        DLog(@"Log : No upload is in progress.. We make an update to DB and start upload");
//        [VCLIENT videoUploadIntelligence];
//    }
//}

- (IBAction)shareViaFB:(id)sender {
}
- (IBAction)shareViaGoogle:(id)sender {
}
- (IBAction)shareViaTwitter:(id)sender {
}
- (IBAction)shareViaMail:(id)sender {
}

@end
