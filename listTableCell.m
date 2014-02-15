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
    [self playMovieinFullScreen:NO];
}

// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)playMovieinFullScreen:(BOOL)fullScreen
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:stopVideo object:nil] ;
    
    [self registerForMovieNotifications];
    
    [APPCLIENT getTheCloudUrlForVideoStreamingForFileWithUUID:self.video.uuid success:^(NSString *cloudURL)
     {
         DLog(@"Log : Cloud url obtained is - %@", cloudURL);
         self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: [NSURL URLWithString:cloudURL]];
         self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
         self.moviePlayer.view.frame = self.btnImage.frame;
         [self addSubview:self.moviePlayer.view];
         [self addSubview:self.spinningWheel];
         
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
             self.moviePlayer.scalingMode= MPMovieScalingModeFill;
             self.moviePlayer.controlStyle =MPMovieControlStyleNone;
         }
         
         // Registering tap gesture on Movie Player
         UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playInFullScreen)];
         tapGestureRecognizer.numberOfTapsRequired = 1;
         [self.moviePlayer.view addGestureRecognizer:tapGestureRecognizer];
         self.moviePlayer.view.userInteractionEnabled = YES;
         tapGestureRecognizer.delegate = self;
         
         
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
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    [self.spinningWheel stopAnimating];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.btnPlay setHidden:NO];
    [self.btnStop setHidden:YES];
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
    if (state & MPMovieLoadStatePlaythroughOK)
    {
        [self.spinningWheel stopAnimating];
        [loadState appendString:@" | Playthrough OK"];
    }
    if (state & MPMovieLoadStateStalled)
    {
        [self.spinningWheel startAnimating];
        [loadState appendString:@" | Stalled"];
    }
    DLog(@"Load State: %@", loadState.length > 0 ? [loadState substringFromIndex:3] : @"N/A");
}


- (IBAction)imfThumbTapped:(id)sender {
    [self playMovieinFullScreen:YES];
}

- (IBAction)btnShareClicked:(id)sender {
}

- (IBAction)btnStopClicked:(id)sender {
    DLog(@"Log : Movie is to be stopped");
    [self myMovieFinishedCallback:nil];
}
@end
