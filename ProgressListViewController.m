//
//  ProgressListViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/21/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ProgressListViewController.h"

@interface ProgressListViewController ()

@end

@implementation ProgressListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.uploadArray = [DBCLIENT listAllEntitiesinTheDB];
    DLog(@"Log : The upload array is - %@", self.uploadArray);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshProgressBar) name:refreshProgress object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.uploadArray.count;
}

-(void)refreshProgressBar
{
    DLog(@"Log : progress bar is to be refreshed now...");
    int  index = 0;
    for( Videos *video in self.uploadArray )
    {
        if( [video.fileURL isEqualToString:VCLIENT.videoUploading.fileURL] )
        {
            uploadProgress *cell = [self getCellAt:index];
//            [UIView animateWithDuration:1 animations:^(void)
//             {
            if( cell != nil )
            {
                CGRect progressBarFrame = cell.lblUploadProgress.frame;
                progressBarFrame.size.width = (int) (APPCLIENT.uploadedSize * cell.vwUploadProgress.frame.size.width) / VCLIENT.asset.defaultRepresentation.size ;
                cell.lblUploadProgress.frame = progressBarFrame;
                DLog(@"Log : progress bar width should be - %f", progressBarFrame.size.width);
            }
            else
                DLog(@"Log : The cell is not isible currently");

//             }];
        }
        index++;
    }
}

-(uploadProgress *) getCellAt:(NSInteger)index{
    NSUInteger indexArr[] = {0,index};  // First one is the section, second the row
    
    NSIndexPath *myPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
    
    return (uploadProgress*)[self tableView:self.listTableView cellForRowAtIndexPath:myPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    uploadProgress *progressCell = [tableView dequeueReusableCellWithIdentifier:@"uploadCell" forIndexPath:indexPath];
    
    Videos *video = self.uploadArray[indexPath.row];
    ALAsset *asset = [VCLIENT getAssetFromFilteredVideosForUrl:video.fileURL];
    
    DLog(@"Log : The video details are as follows... %@", video);
    
    progressCell.uploadThumbnail.image = [UIImage imageWithCGImage:[asset thumbnail]];
    progressCell.asset = asset;
    progressCell.video = video;
    
    if([video.isPaused integerValue])
    {
        [progressCell.btnCancel setHidden:NO];
        [progressCell.btnResume setHidden:NO];
        [progressCell.btnPause setHidden:YES];
    }
    else
    {
        DLog(@"Going in here....");
        [progressCell.btnCancel setHidden:YES];
        [progressCell.btnPause setHidden:NO];
        [progressCell.btnResume setHidden:YES];
    }
    
    // Logic for computing the progress bar for individual uploads
    
    if( progressCell != nil )
    {
        CGRect progressBarFrame = progressCell.lblUploadProgress.frame;
        progressBarFrame.size.width = (int) ([video.uploadedBytes doubleValue] * progressCell.vwUploadProgress.frame.size.width) / VCLIENT.asset.defaultRepresentation.size ;
        progressCell.lblUploadProgress.frame = progressBarFrame;
        DLog(@"Log : progress bar width should be - %f", progressBarFrame.size.width);
    }
    
    return progressCell;
}

@end
