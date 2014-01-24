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
    
    self.lblSyncNotInProgress.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    _menuSections = @[@"Home", @"Settings", @"Help/FAQ", @"Tell A Friend", @"Give Feedback", @"Legal & Privacy", @"Rate Us In App Store"];
	// Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    DLog(@"Log : Geting the information of video being uploaded to show in progress bar");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBar) name:refreshProgress object:nil];
    
    if( VCLIENT.asset != nil )
    {
        DLog(@"Log : Upload in progress....");
       
        [self.lblSyncNotInProgress setHidden:YES];
        [self.vwSyncingFile setHidden:NO];
        [self performSelectorOnMainThread:@selector(refreshProgressBar) withObject:nil waitUntilDone:YES];
    }
    else
    {
        [self.vwSyncingFile setHidden:YES];
        [self.lblSyncNotInProgress setHidden:NO];
        
        if( [DBCLIENT getTheCountOfRecordsInDB] > 0 )
        {
            if( [APPMANAGER.activeSession.autoSyncEnabled isEqual:@(1)] )
            {
                if( [DBCLIENT getTheListOfPausedVideos].count > 0 )
                {
                    self.lblSyncNotInProgress.text = @"Please consider syncing paused uploadss";
                }
                else
                    self.lblSyncNotInProgress.text = @"All videos are uploaded !!";
            }
            else
                self.lblSyncNotInProgress.text = @"Enable Auto Sync to upload all your videos !!";
        }
        else
        {
            self.lblSyncNotInProgress.text = @"No videos found to upload !!";
        }
    }
}

-(void)refreshBar
{
    [self performSelectorOnMainThread:@selector(refreshProgressBar) withObject:nil waitUntilDone:NO];
}

-(void)refreshProgressBar
{
    DLog(@"Log : Refreshing the progress bar for file");
    DLog(@"Log : uploaded size is - %f", APPCLIENT.uploadedSize);
    DLog(@"Log : File size is - %lld", VCLIENT.asset.defaultRepresentation.size);
    DLog(@"Log : Uploaded percentage should be - %f", APPCLIENT.uploadedSize / VCLIENT.asset.defaultRepresentation.size);

    self.progressView.progress = APPCLIENT.uploadedSize / VCLIENT.asset.defaultRepresentation.size;
    self.uploadingImg.image = [UIImage imageWithCGImage:[VCLIENT.asset thumbnail]];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[VCLIENT.asset valueForProperty:ALAssetPropertyDate]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    dateString = (NSString*)[[dateString componentsSeparatedByString:@" "] firstObject];
    DLog(@"Log : The date sring about to be set is - %@", dateString);
    self.lblProgressTitle.text = dateString;
}

- (IBAction)progressBarClicked:(id)sender {
    DLog(@"Log : Progress bar clicked.. Show list of uploading screens...");
    [self.slidingViewController resetTopView];
    
    DLog(@"Log : The class of top view controlelr is - %@", NSStringFromClass([self.slidingViewController.topViewController class]));
    [(DashBoardNavController*)self.slidingViewController.topViewController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"uploadList"] animated:YES];
}

- (IBAction)vwInProgessClicked:(id)sender {
    DLog(@"Log : List of uploads under progress needs to be shown here...");
    
    
}


- (IBAction)pauseSyncingFileClicked:(id)sender {
    DLog(@"Log : File Syncing has to be paused now");
    [APPCLIENT invalidateFileUploadTask];
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    self.slidingViewController.topViewController.view.userInteractionEnabled = NO;
//}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    self.slidingViewController.topViewController.view.userInteractionEnabled = YES;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showUploadList:(id)sender {
}

- (IBAction)logoutAction:(id)sender {
    DLog(@"Log : Logout button tapped");
    
    [ViblioHelper clearSessionVariables];
    
    LandingViewController *lvc = (LandingViewController*)self.presentingViewController;
    [self.presentingViewController dismissViewControllerAnimated:NO completion:^(void)
     {
         [lvc performSegueWithIdentifier: Viblio_wideNonWideSegue( @"signInNav" ) sender:self];
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
    
    cell.textLabel.text = _menuSections[indexPath.row];
    cell.textLabel.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    cell.textLabel.textColor = [UIColor grayColor];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Log : Option %@ selected....", _menuSections[indexPath.row]);
    
    if( [_menuSections[indexPath.row] isEqualToString:@"Home"] )
    {
        DLog(@"Log : In Progress clicked");
        
        [self.slidingViewController resetTopView];
        
        [(DashBoardNavController*)self.slidingViewController.topViewController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"list")] animated:YES];
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Settings"])
    {
        DLog(@"Log : setting clicked");
        
        [self.slidingViewController resetTopView];
        
        [(DashBoardNavController*)self.slidingViewController.topViewController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"settings")] animated:YES];
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Help/FAQ"])
    {
        
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Tell A Friend"])
    {
        
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Give Feedback"])
    {
        
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Legal & Privacy"])
    {
        
    }
    else if ([_menuSections[indexPath.row] isEqualToString:@"Rate Us In App Store"])
    {
        
    }
}

@end
