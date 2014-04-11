//
//  HomeViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/17/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "HomeViewController.h"
#import "AssetsCollectionReusableView.h"

//#define PAGE_COUNT @"01"
#define ROW_COUNT @"12"

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
	// Do any additional setup after loading the view.
    
    APPMANAGER.indexOfSharedListSelected = nil;
    [ViblioHelper MailSharingClicked:self];
   // [[VblLocationManager sharedClient] setUp];
    [[VblLocationManager sharedClient] fetchLatitudeAndLongitude];
    
    [self.navigationController.navigationBar setBackgroundImage:[ViblioHelper setUpNavigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationTitleView]];
    self.segment.tag = 0;
    [self setSegmentImages:YES];
    [self setBackGroundColorsForButtons:YES];
    
    self.btnMyViblio.titleLabel.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    self.btnSharedWithMe.titleLabel.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    self.list = (ListViewController*)[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"list")];
    
    if( [DBCLIENT getTheCountOfRecordsInDB] > 0 )
    {
        [VCLIENT videoUploadIntelligence];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    // Get the list of videos in cloud and render them in the UI
    // The fetched list of videos are mapped to the cloudVideoList model and are stored in an cloudList array in VCLIENT
    
    self.requestQueue = [NSMutableArray new];
    
    [APPCLIENT postDeviceTokenToTheServer:APPCLIENT.dataModel.deviceToken success:^(NSString *msg)
     {
         
     }failure:^(NSError *error)
     {
         DLog(@"Log : Sending device token to the server failed with error - %@", error);
     }];
    
    [APPCLIENT getTheListOfMediaFilesOwnedByUserWithOptions:@"poster" pageCount:[NSString stringWithFormat:@"%d", VCLIENT.pageCount] rows:ROW_COUNT success:^(NSMutableArray *result)
     {
         if( self.errorAlert.tag == 1 )
         {
             self.errorAlert.tag = 0;
             [self.errorAlert dismissWithClickedButtonIndex:0 animated:NO];
             self.errorAlert = nil;
         }
         
         if( VCLIENT.cloudVideoList != nil )
         {
             [VCLIENT.cloudVideoList removeAllObjects];
             VCLIENT.cloudVideoList = nil;
         }
         
         VCLIENT.cloudVideoList = result;
         VCLIENT.resCategorized = [ViblioHelper getDateTimeCategorizedArrayFrom:VCLIENT.cloudVideoList];
         
         APPMANAGER.orderedKeys = [[ViblioHelper getReOrderedListOfKeys:[[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)]] mutableCopy];
         
  //       DLog(@"Log : Sorted list of keys obtained are ************************* %@", APPMANAGER.orderedKeys);
         
         // If list view was pushed on then publish notification and dont reload the home view
         if( self.segment.tag )
             [[NSNotificationCenter defaultCenter] postNotificationName:reloadListView object:nil];
         else
             [self.videoList reloadData];
         
     }failure:^(NSError *error)
     {
         
         DLog(@"Log : Error obtained is - %@", error.localizedDescription);
         if ( error.code == 401 )
         {
             APPMANAGER.errorCode = 1002;
             //APPMANAGER.turnOffUploads = YES;
             [APPCLIENT invalidateUploadTaskWithoutPausing];
             [ViblioHelper clearSessionVariables];
             LandingViewController *lvc = (LandingViewController*)self.presentingViewController;
             [self.presentingViewController dismissViewControllerAnimated:NO completion:^(void)
              {
                  [lvc performSegueWithIdentifier: Viblio_wideNonWideSegue( @"signInNav" ) sender:self];
              }];
         }
         else
         {
             [self performSelector:@selector(viewDidAppear:) withObject:Nil afterDelay:7];
             if( !self.errorAlert.tag )
             {
                 self.errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Connecting to server..."
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
                 [self.errorAlert show];
                 self.errorAlert.tag = 1;
             }
         }
     }];
    
    
    // Get the count of media files uploaded by the user as a reference to create the records and lazy load..
    [APPCLIENT getCountOfMediaFilesUploadedByUser:^(int count)
     {
         VCLIENT.totalRecordsCount = count;
         if( count == 0 )
         {
             self.popUp = [[UIView alloc]initWithFrame:CGRectMake(20, 140, 280, 150)];
             self.popUp.backgroundColor = [UIColor whiteColor];
             [self.view addSubview:self.popUp];
             self.popUp.clipsToBounds = YES;
             [self.popUp.layer setCornerRadius:10];
             
             UILabel *lblMsg = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, 270, 100)];
             lblMsg.text = @"Hi, I'm VIBLIO!  Right now, I am uploading and processing your videos.  This will take me a while depending on how many videos you have.  I'll let you know as soon as I'm done.";
             lblMsg.textColor = [ViblioHelper getVblBlueColor];
             lblMsg.numberOfLines = 0;
             lblMsg.font = [UIFont fontWithName:@"Avenir-Roman" size:14];
             [self.popUp addSubview:lblMsg];
             lblMsg.backgroundColor = [UIColor clearColor];
             lblMsg.textAlignment = NSTextAlignmentCenter;
             
             UIButton *ok = [UIButton buttonWithType:UIButtonTypeSystem];
             ok.titleLabel.text = @"OK";
             ok.titleLabel.textColor = [ViblioHelper getVblBlueColor];
             [ok setFrame:CGRectMake(100, 110, 80, 30)];
             [ok setTitle:@"OK" forState:UIControlStateNormal];
             [ok addTarget:self action:@selector(okTapped) forControlEvents:UIControlEventTouchUpInside];
             [self.popUp addSubview:ok];
             
             [self.videoList reloadData];
         }
         
     }failure:^(NSError *error)
     {
     }];
    
    // Inform the server to clear the badge count
    
    [APPCLIENT clearBadge:APPCLIENT.dataModel.deviceToken success:^(NSString *msg)
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
    }failure:^(NSError *error)
    {
        DLog(@"Log : Clear badge failed-----");
    }];
    
    if( APPMANAGER.restoreMyViblio )
        [self MyViblioClicked:nil];
    
    APPMANAGER.restoreMyViblio = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshScreen) name:newVideoAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSharingScreen:) name:showingSharingView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOwnerSharedList) name:showSharingView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOwnerShareView) name:removeOwnerSharingView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshScreenOnComingToFGFromBG) name:UIApplicationDidBecomeActiveNotification object:nil];
}

//-(void)reloadViews
//{
//    [self.videoList reloadData];
//}

-(void)removeOwnerShareView
{
    [self.sharedOwnerList.view removeFromSuperview];
    self.sharedOwnerList = nil;
}

-(void)showOwnerSharedList
{
    if(self.sharedOwnerList != nil)
    {
        self.sharedOwnerList = nil;
    }
    
    self.sharedOwnerList = (SharedVideoListViewController*)[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"sharedOwnerList")];
    self.sharedOwnerList.view.frame = CGRectMake(0, self.btnMyViblio.frame.size.height, 320, self.view.frame.size.height - self.btnMyViblio.frame.size.height);
    
    [self.view addSubview:self.sharedOwnerList.view];
}


-(void)refreshScreenOnComingToFGFromBG
{
  //  [self viewDidAppear:YES];
    

    [APPCLIENT getTheListOfMediaFilesOwnedByUserWithOptions:@"poster" pageCount:[NSString stringWithFormat:@"%d", VCLIENT.pageCount] rows:ROW_COUNT success:^(NSMutableArray *result)
     {
         if( self.errorAlert.tag == 1 )
         {
             self.errorAlert.tag = 0;
             [self.errorAlert dismissWithClickedButtonIndex:0 animated:NO];
             self.errorAlert = nil;
         }
         
         if( VCLIENT.cloudVideoList != nil )
         {
             [VCLIENT.cloudVideoList removeAllObjects];
             VCLIENT.cloudVideoList = nil;
         }
         
         VCLIENT.cloudVideoList = result;
         VCLIENT.resCategorized = [ViblioHelper getDateTimeCategorizedArrayFrom:VCLIENT.cloudVideoList];
         
         APPMANAGER.orderedKeys = [[ViblioHelper getReOrderedListOfKeys:[[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)]] mutableCopy];
         
         DLog(@"Log : Sorted list of keys obtained are ************************* %@", APPMANAGER.orderedKeys);
         
         // If list view was pushed on then publish notification and dont reload the home view
         if( self.segment.tag )
             [[NSNotificationCenter defaultCenter] postNotificationName:reloadListView object:nil];
         else
             [self.videoList reloadData];
         
         [self refreshScreen];
         
     }failure:^(NSError *error)
     {
         DLog(@"Log : Error obtained is - %@", error.localizedDescription);
     }];
}


-(void)refreshScreen
{
    DLog(@"Log : An upload has been completed... Refresh the screen now...");
    
    if( [VCLIENT.Videouuid isValid] )
    {
        [APPCLIENT getMetadataOfTheMediaFileWithUUID:VCLIENT.Videouuid success:^(cloudVideos *resultObj)
         {
             DLog(@"Log : The result obj is - %@", resultObj);
             [VCLIENT.cloudVideoList insertObject:resultObj atIndex:0];
             VCLIENT.resCategorized = [ViblioHelper getDateTimeCategorizedArrayFrom:VCLIENT.cloudVideoList];
             
             if( self.segment.tag )
                 [[NSNotificationCenter defaultCenter] postNotificationName:reloadListView object:nil];
             else
                 [self.videoList reloadData];
             
         }failure:^(NSError *error)
         {
             DLog(@"LOg : Could not get the details of new video");
         }];
    }
    
    
    [APPCLIENT clearBadge:APPCLIENT.dataModel.deviceToken success:^(NSString *msg)
     {
         
     }failure:^(NSError *error)
     {
         
     }];
    
//    if( VCLIENT.cloudVideoList.count < ROW_COUNT.integerValue )
//    {
//        [self viewDidAppear:YES];
//    }
//    else
//    {
//        if( self.segment.tag )
//            [[NSNotificationCenter defaultCenter] postNotificationName:reloadListView object:nil];
//        else
//            [self.videoList reloadData];
//    }
}

-(void)okTapped
{
    DLog(@"Log : Ok tapped");
    if( self.popUp != nil )
    {
        DLog(@"Log : Ok tapped - In");
        [self.popUp removeFromSuperview];
        self.popUp = nil;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 )
        [[NSNotificationCenter defaultCenter] postNotificationName:logoutUser object:nil];
}

-(void)showSharingScreen : (NSNotification*)notification
{
    APPMANAGER.videoToBeShared = (VideoCell*)notification.object;
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier: Viblio_wideNonWideSegue(@"Share")] animated:YES];
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
    self.btnMyViblio.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
    self.btnSharedWithMe.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
    
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
    }
}

- (IBAction)valueOfSegmentChanged:(id)sender {

    if( VCLIENT.cloudVideoList == nil || VCLIENT.cloudVideoList.count <= 0 )
    {
        if( APPMANAGER.signalStatus != 0 )
        {
            [self viewDidAppear:YES];
        }
    }
     //   [self viewDidAppear:YES];
    
    UISegmentedControl *segmentView = (UISegmentedControl*)sender;

    switch (segmentView.selectedSegmentIndex) {
        case 0:
            DLog(@"Log : Thumbnail view");
            [self setSegmentImages:YES];
            [self.list.view removeFromSuperview];
            self.list = nil;
            [self.videoList reloadData];
            self.segment.tag = 0;
            break;
        case 1:
            DLog(@"Log : List View");
            [self setSegmentImages:NO];
            self.segment.tag = 1;
            if(self.list != nil)
            {
                self.list = nil;
            }
            
                self.list = (ListViewController*)[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"listDash")];
                self.list.view.frame = CGRectMake(0, self.btnMyViblio.frame.size.height, 320, self.view.frame.size.height - self.btnMyViblio.frame.size.height);
            
            [self.view addSubview:self.list.view];
            break;
        default:
            break;
    }
}

- (IBAction)sharedWithMeClicked:(id)sender {
    
  //  APPMANAGER.restoreMyViblio = YES;
        [self setBackGroundColorsForButtons:NO];
    
    if( self.sharedList == nil )
    {
        self.sharedList = (SharedViewController*)[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"sharedList")];
        self.sharedList.view.frame = CGRectMake(0, self.btnMyViblio.frame.size.height, 320, self.view.frame.size.height - self.btnMyViblio.frame.size.height);
    }
    [self.view addSubview:self.sharedList.view];
    [self.segment setHidden:YES];
}

- (IBAction)MyViblioClicked:(id)sender {
    
    if( VCLIENT.cloudVideoList == nil || VCLIENT.cloudVideoList.count <= 0 )
    {
        if( APPMANAGER.signalStatus != 0 )
        {
            [self viewDidAppear:YES];
        }
    }
    
    [self setBackGroundColorsForButtons:YES];
    [self.segment setHidden:NO];
    
    if( self.sharedList != nil )
    {
        [self.sharedList.view removeFromSuperview];
        self.sharedList = nil;
    }
    
    if( self.sharedOwnerList != nil )
    {
        [self.sharedOwnerList.view removeFromSuperview];
        self.sharedOwnerList = nil;
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

    DLog(@"Log : Coming in number of rows in sections" );
    NSArray *sectionList = VCLIENT.resCategorized[APPMANAGER.orderedKeys[section]];
    return sectionList.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    DLog(@"Log : Number of sections would be - %d", VCLIENT.resCategorized.allKeys.count);
    return VCLIENT.resCategorized.allKeys.count;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        AssetsCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
      //  DLog(@"Log : Not crashing before this...");
        
        headerView.lblTitle.text = APPMANAGER.orderedKeys[indexPath.section]; //([[(NSArray*)[[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)] reverseObjectEnumerator] allObjects])[indexPath.section];
      //  DLog(@"Log : Crashing after this....");
        
        headerView.lblTitle.font = [UIFont fontWithName:@"Avenir-Light" size:14];
        headerView.lblTitle.textColor = [UIColor colorWithRed:0.6156 green:0.6274 blue:0.6745 alpha:1];
        
      //  DLog(@"Log : Crashing somewhere in between");
        reusableview = headerView;
    }
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    VideoCell *cell = (VideoCell*)[cv dequeueReusableCellWithReuseIdentifier:@"VideoStaticCell" forIndexPath:indexPath];
    
//    NSArray *sortedArrayOfKeys = [[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
//    NSArray *sortedReversedArray = [[sortedArrayOfKeys reverseObjectEnumerator] allObjects];
    NSMutableArray *resArrayOfVideoObjects = [VCLIENT.resCategorized[APPMANAGER.orderedKeys[indexPath.section]] mutableCopy];
    
  //  sortedReversedArray = nil; sortedArrayOfKeys = nil;
    
   // [resArrayOfVideoObjects  removeObjectAtIndex:0];
    
  //  DLog(@"Log : The resultant array obtained is - %@", resArrayOfVideoObjects);
    if( indexPath.section < VCLIENT.resCategorized.allKeys.count )
    {
        if( indexPath.row < resArrayOfVideoObjects.count )
        {
            cell.video = [resArrayOfVideoObjects objectAtIndex:indexPath.row]; //[VCLIENT.cloudVideoList objectAtIndex:indexPath.row];
            DLog(@"Log : the video info is - %@", cell.video);
            [[NSNotificationCenter defaultCenter] postNotificationName:stopVideo object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(handleRightSwipe:) name:removeSharingView object:nil];
            [cell.videoImage setImageWithURL:[NSURL URLWithString:cell.video.url]];
        }
    }

    
    // Logic to decide whether share tag is to be shown or not
    
    if( cell.video.shareCount > 0 )
        [cell.btnShare setImage:[UIImage imageNamed:@"icon_share_grid"] forState:UIControlStateNormal];
    else
        [cell.btnShare setImage:[UIImage imageNamed:@"icon_share_selected"] forState:UIControlStateNormal];
    
//    [APPCLIENT hasAMediaFileBeenSharedByTheUSerWithUUID:cell.video.uuid success:^(BOOL isShared)
//     {
//         if( !isShared )
//            [cell.btnShare setImage:[UIImage imageNamed:@"icon_share_selected"] forState:UIControlStateNormal];
//         else
//            [cell.btnShare setImage:[UIImage imageNamed:@"icon_share_grid"] forState:UIControlStateNormal];
//             
//     }failure:^(NSError *error)
//     {
//         
//     }];
    
    
    if( indexPath.section == VCLIENT.resCategorized.allKeys.count-1 )
    {
   //     DLog(@"Log : Coming into section....");
   //     DLog(@"Log : Index path row is - %d and count is - %d", indexPath.row, resArrayOfVideoObjects.count);
        if( (indexPath.row == resArrayOfVideoObjects.count-1) && VCLIENT.totalRecordsCount > VCLIENT.cloudVideoList.count )
        {
  //          DLog(@"Log : Lazy load next set of records...");
            [APPCLIENT getTheListOfMediaFilesOwnedByUserWithOptions:@"poster" pageCount:[NSString stringWithFormat:@"%d",(int)(VCLIENT.cloudVideoList.count/ROW_COUNT.integerValue)+1] rows:ROW_COUNT success:^(NSMutableArray *result)
             {
                 DLog(@"Log : Coming in response");
                 VCLIENT.cloudVideoList = [[VCLIENT.cloudVideoList arrayByAddingObjectsFromArray:result ] mutableCopy];
                 VCLIENT.resCategorized = [ViblioHelper getDateTimeCategorizedArrayFrom:VCLIENT.cloudVideoList];
                 
                 APPMANAGER.orderedKeys = [[ViblioHelper getReOrderedListOfKeys:[[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)]] mutableCopy];
                 
   //              DLog(@"Log : Sorted list of keys obtained are ************************* %@", APPMANAGER.orderedKeys);
                 
                 [self.videoList reloadData];
             }failure:^(NSError *error)
             {
                 
             }];
        }
    }

    return cell;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
