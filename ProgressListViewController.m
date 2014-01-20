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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.uploadArray.count;
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
    
    return progressCell;
}

@end
