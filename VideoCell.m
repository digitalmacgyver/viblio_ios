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
        self.videoImage.image = [self loadImage:self.asset];
        [self.vwUpload setHidden:NO];
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
}

- (IBAction)shareVideo:(id)sender {
}

- (IBAction)uploadClicked:(id)sender {
    DLog(@"LOG : Upload video clicked");
    
    // Checking whether an upload is in progress.
    // If an upload is in progres then we just make an update to the DB
    // We change the sync_status of the video file to 1 so that its taken on priority
    
    [DBCLIENT updateSynStatusOfFile:self.video.fileURL syncStatus:1];
    
    if( VCLIENT.asset == nil )
    {
        DLog(@"Log : No upload is in progress.. We make an update to DB and start upload");
        [VCLIENT videoUploadIntelligence];
    }
}

- (IBAction)shareViaFB:(id)sender {
}
- (IBAction)shareViaGoogle:(id)sender {
}
- (IBAction)shareViaTwitter:(id)sender {
}
- (IBAction)shareViaMail:(id)sender {
}

- (UIImage*)loadImage : (ALAsset *)videoAsset {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoAsset.defaultRepresentation.url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    NSLog(@"err==%@, imageRef==%@", err, imgRef);
    
    return [[UIImage alloc] initWithCGImage:imgRef];
    
}

@end
