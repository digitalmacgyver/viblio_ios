//
//  uploadProgress.m
//  Viblio_v2
//
//  Created by Vinay on 1/21/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "uploadProgress.h"

@implementation uploadProgress

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

- (IBAction)pauseVideoUploadClicked:(id)sender {
    DLog(@"Log : pause at index %d clicked", self.btnPause.tag);
    
    if( [self.video.fileURL isEqualToString:VCLIENT.videoUploading.fileURL] )
    {
        DLog(@"Log : Pausing the uploading file..");
        [APPCLIENT invalidateFileUploadTask];
    }
    else
    {
        [DBCLIENT updateIsPausedStatusOfFile:self.asset.defaultRepresentation.url forPausedState:0];
        [ViblioHelper displayAlertWithTitle:@"Resume" messageBody:@"Video Upload paused" viewController:nil cancelBtnTitle:@"OK"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:uploadComplete object:nil];
}


- (IBAction)resumeVideoUploadClicked:(id)sender {
    DLog(@"Log : resume at index %d clicked", self.btnPause.tag);
    
    [DBCLIENT updateIsPausedStatusOfFile:self.asset.defaultRepresentation.url forPausedState:0];
    [ViblioHelper displayAlertWithTitle:@"Resume" messageBody:@"Video queued for resuming upload" viewController:nil cancelBtnTitle:@"OK"];
    [[NSNotificationCenter defaultCenter] postNotificationName:uploadComplete object:nil];
}


- (IBAction)cancelVideoUpload:(id)sender {
    DLog(@"Log : cancel at index %d clicked", self.btnPause.tag);
    [DBCLIENT deleteOperationOnDB:self.video.fileURL];
    [[NSNotificationCenter defaultCenter] postNotificationName:uploadComplete object:nil];
}


@end
