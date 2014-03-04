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
    else
    {
//        [ViblioHelper displayAlertWithTitle:@"No Videos" messageBody:@"No videos found in the camera roll to upload" viewController:self cancelBtnTitle:@"OK"];
    }
//    
//    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.videoList.collectionViewLayout;
//    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
}

//- (IBAction)shareClicked:(id)sender {
//
//    UIButton *btnShare = (UIButton*)sender;
//    DLog(@"Log : Share clicked on index - %d", btnShare.tag);
//}

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
         
         // If list vie wis pushed on then publish notification and dont reload the home view
         if( self.segment.tag )
         {
             DLog(@"Log : In if - ");
             [[NSNotificationCenter defaultCenter] postNotificationName:reloadListView object:nil];
         }
         else
         {
             DLog(@"Log : In else - ");
            [self.videoList reloadData];
         }
         
     }failure:^(NSError *error)
     {
         if ( error.code == 401 )
         {
             APPMANAGER.turnOffUploads = YES;
             [APPCLIENT invalidateFileUploadTask];
             [ViblioHelper clearSessionVariables];
             LandingViewController *lvc = (LandingViewController*)self.presentingViewController;
             [self.presentingViewController dismissViewControllerAnimated:NO completion:^(void)
              {
                  [lvc performSegueWithIdentifier: Viblio_wideNonWideSegue( @"signInNav" ) sender:self];
              }];
         }
         else
             [ViblioHelper displayAlertWithTitle:@"Error" messageBody:error.localizedDescription viewController:nil cancelBtnTitle:@"OK"];
     }];

    
    // Get the count of media files uploaded by the user as a reference to create the records and lazy load..
    [APPCLIENT getCountOfMediaFilesUploadedByUser:^(int count)
     {
         DLog(@"Log : The count obtained is - %d", count);
         VCLIENT.totalRecordsCount = count;
     }failure:^(NSError *error)
     {
     }];
    
    [self MyViblioClicked:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSharingScreen:) name:showingSharingView object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContacts:) name:showContactsScreen object:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"Log : alert index is - %d", buttonIndex);
    if( buttonIndex == 0 )
        [[NSNotificationCenter defaultCenter] postNotificationName:logoutUser object:nil];
}

//-(void)showContacts:(NSNotification*)notification
//{
//    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"contacts")] animated:YES];
//    DLog(@"Log : The parent class is - %@", NSStringFromClass([self.slidingViewController.topViewController class]));
//}

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

    DLog(@"Log : Coming in number of rows in sections" );
    return ((NSArray*)VCLIENT.resCategorized[[[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)][section]]).count-1;
    
//    DLog(@"LOG : Count being returned is - %d", VCLIENT.filteredVideoList.count);
//    return VCLIENT.totalRecordsCount;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    DLog(@"Log : Number of sections would be - %d", VCLIENT.resCategorized.allKeys.count);
    return VCLIENT.resCategorized.allKeys.count;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        AssetsCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        headerView.lblTitle.text = [VCLIENT.resCategorized[[[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)][indexPath.section]] firstObject];
        headerView.lblTitle.font = [UIFont fontWithName:@"Avenir-Light" size:14];
        headerView.lblTitle.textColor = [UIColor colorWithRed:0.6156 green:0.6274 blue:0.6745 alpha:1];
        
        reusableview = headerView;
    }
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    VideoCell *cell = (VideoCell*)[cv dequeueReusableCellWithReuseIdentifier:@"VideoStaticCell" forIndexPath:indexPath];
    //cell.btnShare.tag = indexPath; //indexPath.row;
    
    NSMutableArray *resArrayOfVideoObjects = [VCLIENT.resCategorized[[[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)][indexPath.section]] mutableCopy];
    [resArrayOfVideoObjects  removeObjectAtIndex:0];
    
    DLog(@"Log : The resultant array obtained is - %@", resArrayOfVideoObjects);
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
    
    [APPCLIENT hasAMediaFileBeenSharedByTheUSerWithUUID:cell.video.uuid success:^(BOOL isShared)
     {
         if( !isShared )
            [cell.btnShare setImage:[UIImage imageNamed:@"icon_share_selected"] forState:UIControlStateNormal];
         else
            [cell.btnShare setImage:[UIImage imageNamed:@"icon_share_grid"] forState:UIControlStateNormal];
             
     }failure:^(NSError *error)
     {
         
     }];
    
    
    if( indexPath.section == VCLIENT.resCategorized.allKeys.count-1 )
    {
        DLog(@"Log : Coming into section....");
        DLog(@"Log : Index path row is - %d and count is - %d", indexPath.row, resArrayOfVideoObjects.count);
        if( (indexPath.row == resArrayOfVideoObjects.count-1) && VCLIENT.totalRecordsCount > VCLIENT.cloudVideoList.count )
        {
            DLog(@"Log : Lazy load next set of records...");
            [APPCLIENT getTheListOfMediaFilesOwnedByUserWithOptions:@"poster" pageCount:[NSString stringWithFormat:@"%d",(int)(VCLIENT.cloudVideoList.count/ROW_COUNT.integerValue)+1] rows:ROW_COUNT success:^(NSMutableArray *result)
             {
                 VCLIENT.cloudVideoList = [[VCLIENT.cloudVideoList arrayByAddingObjectsFromArray:result ] mutableCopy];
                 VCLIENT.resCategorized = [ViblioHelper getDateTimeCategorizedArrayFrom:VCLIENT.cloudVideoList];
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
