//
//  InProgressViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/24/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "InProgressViewController.h"

@interface InProgressViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation InProgressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)revealMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.celIndex = -1;
    APPMANAGER.listVideos = [DBCLIENT listAllEntitiesinTheDB];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                           [UIButton navigationItemWithTarget:self action:@selector(revealMenu) withImage:@"icon_options"]];
    
    UIView *vwTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 201, 20)];
    UILabel *lblTitle = [[ UILabel alloc ]initWithFrame:CGRectMake(10, 0, 201, 20)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.text = @"Uploads In Progress";
    lblTitle.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [vwTitle addSubview:lblTitle];
    
    [self.navigationItem setTitleView : vwTitle];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBar) name:refreshProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList) name:uploadComplete object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma Table View Delegate Mehods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return APPMANAGER.listVideos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"progressCell";
    
    uploadProgress *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.video = APPMANAGER.listVideos[indexPath.row];
    cell.asset = [VCLIENT getAssetFromFilteredVideosForUrl:cell.video.fileURL];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.lblMetaData.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
    cell.lblMetaData.textColor = [UIColor lightGrayColor];
    cell.thumbImg.image = [UIImage imageWithCGImage:[cell.asset thumbnail]];
    cell.btnCancel.tag = cell.btnPause.tag = cell.btnPlay.tag = indexPath.row;
    
    if( cell.video.isPaused.integerValue )
    {
        //DLog(@"Log : Video is paused");
        cell.lblMetaData.text = @"Paused";
        [cell.btnPause setHidden:YES];
        [cell.btnPlay setHidden:NO];
        [cell.btnCancel setHidden:NO];
    }
    else
    {
        cell.lblMetaData.text = @"Uploading";
        [cell.btnPlay setHidden:YES];
        [cell.btnCancel setHidden:YES];
        [cell.btnPause setHidden:NO];
    }
    
    if( cell.video.uploadedBytes.doubleValue > 0 )
        cell.progressBar.progress = cell.video.uploadedBytes.doubleValue/cell.asset.defaultRepresentation.size;
    else
        cell.progressBar.progress = 0;

    
    if([cell.video.fileURL isEqualToString:VCLIENT.videoUploading.fileURL])
        self.celIndex = indexPath.row;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(void)refreshBar
{
    [self performSelectorOnMainThread:@selector(refreshProgressBar) withObject:nil waitUntilDone:NO];
}

-(void)refreshProgressBar
{
    if( self.celIndex != -1 )
    {
        uploadProgress *cell = (uploadProgress*)[self.tblInProgress cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.celIndex inSection:0]];
        
        if( [cell.video.fileURL isEqualToString:VCLIENT.videoUploading.fileURL] )
            cell.progressBar.progress = APPCLIENT.uploadedSize/VCLIENT.asset.defaultRepresentation.size;
    }
}

-(void)reloadList
{
    [self performSelectorOnMainThread:@selector(reloadListProgress) withObject:nil waitUntilDone:NO];
}

-(void)reloadListProgress
{
    DLog(@"Log : ReloadList progress called....");
    APPMANAGER.listVideos = [DBCLIENT listAllEntitiesinTheDB];
    [self.tblInProgress reloadData];
}

@end
