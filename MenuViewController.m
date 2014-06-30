//
//  MenuViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/17/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_menuSections;
}
@end

@implementation MenuViewController

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
    
    [self.slidingViewController setAnchorRightRevealAmount:240.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
    self.lblEmailId.text = APPMANAGER.user.emailId;
    self.lblEmailId.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    
    self.lblSyncNotInProgress.font = [UIFont fontWithName:@"Avenir-Medium" size:14];
    self.lblSyncNotInProgress.numberOfLines = 0;
    _menuSections = @[@"Home", @"Settings", @"Tell A Friend", @"Give Feedback", @"Terms Of Use", @"Rate Us In App Store"];
	// Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    DLog(@"Log : Geting the information of video being uploaded to show in progress bar");
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiConnectivityLost) name:wifiSignalLost object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutUser) name:logoutUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBar) name:refreshProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadDescretion) name:uploadVideoPaused object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadDescretion) name:uploadComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoUploadDescretion) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self videoUploadDescretion];
}

-(void)refreshBar
{
    [self.lblSyncNotInProgress setHidden:YES];
    [self.vwSyncingFile setHidden:NO];
    [self performSelectorOnMainThread:@selector(refreshProgressBar) withObject:nil waitUntilDone:NO];
}

-(void)refreshProgressBar
{
    if( !VCLIENT.isToBePaused )
    {
  //      DLog(@"Log : Refreshing the progress bar for file");
  //      DLog(@"Log : uploaded size is - %f", APPCLIENT.uploadedSize);
  //      DLog(@"Log : File size is - %lld", VCLIENT.asset.defaultRepresentation.size);
  //      DLog(@"Log : Uploaded percentage should be - %f", APPCLIENT.uploadedSize / VCLIENT.asset.defaultRepresentation.size);
        
        if(VCLIENT.totalChunksSent < 1 )
        {
            VCLIENT.totalChunksSent = 1;
        }
        int sentBytes = ((VCLIENT.totalChunksSent - 1)*1024*1024);
        float progressBytes = sentBytes + APPCLIENT.uploadedSize;
        
//        if( progressBytes < 0 )
//        {
//            progressBytes = 0;
//        }
  //      DLog(@"Log : The progress should be - %.2f", progressBytes/(1024*1024));
        
        self.lblSize.text = [NSString stringWithFormat:@"%.2fMb of %.2fMb(%.2f%%)", progressBytes/(1024*1024), (float)VCLIENT.asset.defaultRepresentation.size/(1024*1024), (progressBytes/(float)VCLIENT.asset.defaultRepresentation.size)*100];
        
//        self.lblSize.text = [NSString stringWithFormat:@"%.2fMb of %.2fMb(%.2f%%)", (APPCLIENT.uploadedSize/(1024*1024)), (float)VCLIENT.asset.defaultRepresentation.size/(1024*1024), (APPCLIENT.uploadedSize/VCLIENT.asset.defaultRepresentation.size)*100];
        self.lblSize.adjustsFontSizeToFitWidth = YES;
        
        self.progressView.progress = progressBytes / VCLIENT.asset.defaultRepresentation.size;
        self.uploadingImg.image = [UIImage imageWithCGImage:[VCLIENT.asset thumbnail]];
        self.lblProgressTitle.text = @"Uploading";
    }
    else
    {
        DLog(@"Log : Video has been paused.. Dont update the UI");
        
//        NSMutableArray *videoList = [[DBCLIENT fetchVideoListToBeUploaded] mutableCopy];
//        if( videoList != nil && videoList.count > 0 )
//        {
//            Videos *videoUploading = (Videos*)[videoList objectAtIndex:1];
//            ALAsset *asset = [VCLIENT getAssetFromFilteredVideosForUrl: videoUploading.fileURL];
//            
//            [self.vwSyncingFile setHidden:NO];
//            [self.lblSyncNotInProgress setHidden:YES];
//            
//            self.uploadingImg.image = [UIImage imageWithCGImage:[asset thumbnail]];
//            self.progressView.progress = 0;
//        }
//        else
//        {
//            [self.vwSyncingFile setHidden:YES];
//            [self.lblSyncNotInProgress setHidden:NO];
//            self.lblSyncNotInProgress.text = @"No new videos to upload";
//        }
    }
}

- (IBAction)progressBarClicked:(id)sender {
    DLog(@"Log : Progress bar clicked.. Show list of uploading screens...");
    [self.slidingViewController resetTopView];
    
    DLog(@"Log : The class of top view controlelr is - %@", NSStringFromClass([self.slidingViewController.topViewController class]));
    [(DashBoardNavController*)self.slidingViewController.topViewController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"uploadList"] animated:YES];
}

- (IBAction)vwInProgessClicked:(id)sender {
    DLog(@"Log : List of uploads under progress needs to be shown here...");
    
    DLog(@"Log : In Progress clicked");
    
    [self.slidingViewController resetTopView];
    
    [(DashBoardNavController*)self.slidingViewController.topViewController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"list")] animated:YES];
}

- (IBAction)resumeSyncingFileClicked:(id)sender {
    DLog(@"Log : Resume syncing file clicked");

    [self.btnUploadPause setHidden:NO];
    [self.btnUploadResume setHidden:YES];
    APPMANAGER.turnOffUploads = NO;
    [VCLIENT videoUploadIntelligence];
}

-(void)videoUploadDescretion
{
    //DLog(@"Log : ");
    if( APPMANAGER.signalStatus != 0 )
    {
        if( APPMANAGER.turnOffUploads )
        {
            // Check for error codes
            
            [self.vwSyncingFile setHidden:YES];
            [self.lblSyncNotInProgress setHidden:NO];
            
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
            
            DLog(@"Log : Coming here --- 2");
            if( APPMANAGER.errorCode == 1000 )
                self.lblSyncNotInProgress.text = @"Battery less than 20%. Uploads have been stopped";
            else if( APPMANAGER.errorCode == 1001 )
                self.lblSyncNotInProgress.text = @"Internet connection appears to be offline";
            else if ( APPMANAGER.errorCode == 1003 )
                self.lblSyncNotInProgress.text = @"Server not reachable at the moment.. Reconnecting..";
        }
        else
        {
            if( VCLIENT.asset != nil )
            {
                DLog(@"Log : Upload in progress....");
                
                [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
                
                [self.lblSyncNotInProgress setHidden:YES];
                [self.vwSyncingFile setHidden:NO];
                [self performSelectorOnMainThread:@selector(refreshProgressBar) withObject:nil waitUntilDone:YES];
            }
            else
            {
                [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
                
                [self.vwSyncingFile setHidden:YES];
                [self.lblSyncNotInProgress setHidden:NO];
                
                if( [DBCLIENT getTheCountOfRecordsInDB] > 0 )
                {
                    if( [APPMANAGER.activeSession.autoSyncEnabled isEqual:@(1)] )
                    {
                        if( [DBCLIENT getTheListOfPausedVideos].count > 0 )
                        {
                            self.lblSyncNotInProgress.text = @"Please consider syncing paused uploads";
                            self.lblSyncNotInProgress.numberOfLines = 0;
                            self.lblSyncNotInProgress.font = [ViblioHelper viblio_Font_Regular_WithSize:12 isBold:NO];
                        }
                        else
                            self.lblSyncNotInProgress.text = @"All videos are uploaded !!";
                    }
                    else
                        self.lblSyncNotInProgress.text = @"Enable Auto Sync to upload all your videos !!";
                }
                else
                {
                    self.lblSyncNotInProgress.text = @"No new videos to upload !!";
                }
            }
        }
        
        if( APPMANAGER.activeSession.wifiupload.integerValue && APPMANAGER.signalStatus != 2 )
        {
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
            
            [self.vwSyncingFile setHidden:YES];
            [self.lblSyncNotInProgress setHidden:NO];
            
            self.lblSyncNotInProgress.text = @"Uploader Paused. Not on Wifi";
        }
    }
    else
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        
        DLog(@"Log : Coming here --- 1");
        [self.vwSyncingFile setHidden:YES];
        [self.lblSyncNotInProgress setHidden:NO];
        self.lblSyncNotInProgress.text = @"Internet Connection appears to be offline.";
    }
}

- (IBAction)pauseSyncingFileClicked:(id)sender {
    DLog(@"Log : File Syncing has to be paused now");
    
    [APPCLIENT invalidateFileUploadTask];
    [self videoUploadDescretion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showUploadList:(id)sender {
    
    DLog(@"Log : In Progress clicked");
    
    [self.slidingViewController resetTopView];
    
    [(DashBoardNavController*)self.slidingViewController.topViewController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"list")] animated:YES];
}

- (IBAction)logoutAction:(id)sender {
    DLog(@"Log : Logout button tapped");
    
    if( VCLIENT.asset == nil )
      [ self logoutUser];
    else{
       
        self.logoutAlert = [[UIAlertView alloc] initWithTitle:@"Logout"
                                                        message:@"An upload in progress. Do you wish to Logout ?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK",nil];
        [self.logoutAlert show];
        self.logoutAlert = nil;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"Log : Clicked button at index - %d", buttonIndex);
    if( buttonIndex == 1 )
        [  self logoutUser];
}

-(void)logoutUser
{
    [APPCLIENT logoutTheUser:^(NSString *msg)
    {
        APPMANAGER.turnOffUploads = YES;
        [APPCLIENT invalidateUploadTaskWithoutPausing];
        [ViblioHelper clearSessionVariables];
        LandingViewController *lvc = (LandingViewController*)self.presentingViewController;
        [self.presentingViewController dismissViewControllerAnimated:NO completion:^(void)
         {
             [lvc performSegueWithIdentifier: Viblio_wideNonWideSegue( @"signInNav" ) sender:self];
         }];
    }failure:^(NSError *error)
    {
        DLog(@"Log : Could not clear the session....");
    }];
}

#pragma Table View Delegate Mehods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _menuSections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(IS_IPHONE_5)
      return 50;
    else
        return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Change the background color for selection background color
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = myBackView;
    
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", _menuSections[indexPath.row]]];
    cell.textLabel.text = _menuSections[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
    cell.textLabel.textColor = [UIColor colorWithRed:0.3686 green:0.3803 blue:0.4431 alpha:1];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Log : Option %@ selected....", _menuSections[indexPath.row]);
     [self.slidingViewController resetTopView];
    
    APPMANAGER.restoreMyViblio = YES;
    
    if( [_menuSections[indexPath.row] isEqualToString:@"Home"] )
    {
        DLog(@"Log : Show home screen");
        [(DashBoardNavController*)self.slidingViewController.topViewController popToRootViewControllerAnimated:YES];
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Settings"])
    {
        DLog(@"Log : setting clicked");
        
        [(DashBoardNavController*)self.slidingViewController.topViewController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"settings")] animated:YES];
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Help/FAQ"])
    {
        
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Tell A Friend"])
    {
        DLog(@"Log : Tell A Friend clicked");
        
        [(DashBoardNavController*)self.slidingViewController.topViewController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"TAF")] animated:YES];
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Give Feedback"])
    {
        DLog(@"Log : Feedback clicked");
        
        [(DashBoardNavController*)self.slidingViewController.topViewController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"feedback")] animated:YES];
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Terms Of Use"])
    {
        DLog(@"Log : Terms clicked");
        
        [(DashBoardNavController*)self.slidingViewController.topViewController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"terms")] animated:YES];
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Rate Us In App Store"])
    {
        NSString* url = [NSString stringWithFormat:  @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8", AppStoreId];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url ]];
        url = nil;
    }
}

@end
