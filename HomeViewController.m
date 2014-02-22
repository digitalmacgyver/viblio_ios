//
//  HomeViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/17/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "HomeViewController.h"

//#define PAGE_COUNT @"01"
#define ROW_COUNT @"100"

@interface HomeViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation HomeViewController

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
  //  self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"menu")];
	// Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundImage:[ViblioHelper setUpNavigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationTitleView]];
    [self setSegmentImages:YES];
    [self setBackGroundColorsForButtons:YES];
    
    self.btnMyViblio.titleLabel.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    self.btnSharedWithMe.titleLabel.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    self.list = (ListViewController*)[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"list")];
    
    if( [DBCLIENT getTheCountOfRecordsInDB] > 0 )
    {
        [VCLIENT videoUploadIntelligence];
    }
    else
    {
        [ViblioHelper displayAlertWithTitle:@"No Videos" messageBody:@"No videos found in the camera roll to upload" viewController:self cancelBtnTitle:@"OK"];
    }
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreListView) name:removeContactsScreen object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    self.indexClicked = -1;
    
    // Get the list of videos in cloud and render them in the UI
    // The fetched list of videos are mapped to the cloudVideoList model and are stored in an cloudList array in VCLIENT
    
    [APPCLIENT getTheListOfMediaFilesOwnedByUserWithOptions:@"poster" pageCount:[NSString stringWithFormat:@"%d", VCLIENT.pageCount] rows:ROW_COUNT success:^(NSMutableArray *result)
     {
         if( VCLIENT.cloudVideoList != nil )
         {
             DLog(@"Flushing the objects from cloud...");
             [VCLIENT.cloudVideoList removeAllObjects];
             VCLIENT.cloudVideoList = nil;
         }
         
         VCLIENT.cloudVideoList = result;
         VCLIENT.resCategorized = [ViblioHelper getDateTimeCategorizedArrayFrom:VCLIENT.cloudVideoList];
         
         [self.videoList reloadData];
     }failure:^(NSError *error)
     {
         [ViblioHelper displayAlertWithTitle:@"Error" messageBody:error.localizedDescription viewController:self cancelBtnTitle:@"OK"];
     }];

    
    // Get the count of media files uploaded by the user as a reference to create the records and lazy load..
    [APPCLIENT getCountOfMediaFilesUploadedByUser:^(int count)
     {
         DLog(@"Log : The count obtained is - %d", count);
         VCLIENT.totalRecordsCount = count;
     }failure:^(NSError *error)
     {
         
     }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSharingScreen:) name:showingSharingView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContacts:) name:showContactsScreen object:nil];
}

-(void)showContacts:(NSNotification*)notification
{
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"contacts")] animated:YES];
    DLog(@"Log : The parent class is - %@", NSStringFromClass([self.slidingViewController.topViewController class]));
}

-(void)showSharingScreen : (NSNotification*)notification
{
    VideoCell *cell = (VideoCell*)notification.object;
    if( self.cell.btnShare.tag != cell.btnShare.tag )
        [self.cell handleRightSwipe:self.cell];
    self.cell = cell;
}


-(void)dealloc
{
    self.list = nil;
}

-(void)setSegmentImages:(BOOL)isThumbnail
{
    if( isThumbnail )
    {
        [self.segment setImage:[[UIImage imageNamed:@"bttn_grid_view_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
        [self.segment setImage:[[UIImage imageNamed:@"bttn_list_view_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
    }
    else
    {
        [self.segment setImage:[[UIImage imageNamed:@"bttn_grid_view_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
        [self.segment setImage:[[UIImage imageNamed:@"bttn_list_view_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
    }
}

-(void)setBackGroundColorsForButtons : (BOOL)isMyViblio
{
    if( isMyViblio )
    {
        self.btnSharedWithMe.backgroundColor = [UIColor clearColor];
        self.btnMyViblio.backgroundColor = [ViblioHelper getVblRedColor];
        
        self.btnMyViblio.titleLabel.textColor = [UIColor whiteColor];
        self.btnSharedWithMe.titleLabel.textColor = [ViblioHelper getVblGrayColor];
    }
    else
    {
        self.btnMyViblio.backgroundColor = [UIColor clearColor];
        self.btnSharedWithMe.backgroundColor = [ViblioHelper getVblRedColor];
        
        self.btnMyViblio.titleLabel.textColor = [ViblioHelper getVblGrayColor];
        [self.btnSharedWithMe setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnSharedWithMe setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        //self.btnSharedWithMe.titleLabel.textColor = [UIColor greenColor];
    }
}

- (IBAction)valueOfSegmentChanged:(id)sender {

    UISegmentedControl *segmentView = (UISegmentedControl*)sender;
    DLog(@"Log : Segment value changed...");

    switch (segmentView.selectedSegmentIndex) {
        case 0:
            DLog(@"Log : Thumbnail view");
            [self setSegmentImages:YES];
            [self.list.view removeFromSuperview];
            [self.videoList reloadData];
            break;
        case 1:
            DLog(@"Log : List View");
            [self setSegmentImages:NO];
            
            if(self.list != nil)
            {
                self.list = nil;
            }

                DLog(@"Log : List object does not exist... Create it...");
                self.list = (ListViewController*)[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"listDash")];
                self.list.view.frame = CGRectMake(0, 34, 320, self.view.frame.size.height - 34);
            
            [self.view addSubview:self.list.view];
            break;
        default:
            break;
    }
}

- (IBAction)sharedWithMeClicked:(id)sender {
        [self setBackGroundColorsForButtons:NO];
    
    if( self.sharedList == nil )
    {
        self.sharedList = (SharedViewController*)[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"sharedList")];
        self.sharedList.view.frame = CGRectMake(0, 34, 320, self.view.frame.size.height - 34);
    }
    [self.view addSubview:self.sharedList.view];
    [self.segment setHidden:YES];
}

- (IBAction)MyViblioClicked:(id)sender {
    [self setBackGroundColorsForButtons:YES];
    [self.segment setHidden:NO];
    
    if( self.sharedList != nil )
    {
        [self.sharedList.view removeFromSuperview];
        self.sharedList = nil;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreListView) name:removeContactsScreen object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenuList:(id)sender {
    
    DLog(@"Log : Reveal sliding menu");
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    DLog(@"LOG : Count being returned is - %d", VCLIENT.filteredVideoList.count);
    return VCLIENT.totalRecordsCount;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    VideoCell *cell = (VideoCell*)[cv dequeueReusableCellWithReuseIdentifier:@"VideoStaticCell" forIndexPath:indexPath];
    cell.btnShare.tag = indexPath.row;
    
    if( indexPath.row < VCLIENT.cloudVideoList.count )
    {
        cell.video = [VCLIENT.cloudVideoList objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:stopVideo object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(handleRightSwipe:) name:removeSharingView object:nil];
        
        [APPCLIENT hasAMediaFileBeenSharedByTheUSerWithUUID:cell.video.uuid success:^(BOOL isShared)
        {
           if( isShared )
               [cell.vwShareTag setHidden:YES];
            else
                [cell.vwShareTag setHidden:NO];
        }failure:^(NSError *error)
        {
            
        }];
        
        [cell.videoImage setImageWithURL:[NSURL URLWithString:cell.video.url]];
    }
    
    if( (indexPath.row == VCLIENT.cloudVideoList.count-1) && VCLIENT.totalRecordsCount > VCLIENT.cloudVideoList.count )
    {
        DLog(@"Log : Lazy load next set of records...");
        [APPCLIENT getTheListOfMediaFilesOwnedByUserWithOptions:@"poster" pageCount:[NSString stringWithFormat:@"%d",(int)((indexPath.row+1)/ROW_COUNT.integerValue)+1] rows:ROW_COUNT success:^(NSMutableArray *result)
         {
             VCLIENT.cloudVideoList = [[VCLIENT.cloudVideoList arrayByAddingObjectsFromArray:result ] mutableCopy];
             [self.videoList reloadData];
         }failure:^(NSError *error)
         {
             
         }];
    }
    
    return cell;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
