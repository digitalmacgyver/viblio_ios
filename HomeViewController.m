//
//  HomeViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/17/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "HomeViewController.h"

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
         [self.videoList reloadData];
     }failure:^(NSError *error)
     {
         
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
}

-(void)showSharingScreen : (NSNotification*)notification
{
    DLog(@"Log : Showing sharing screen...");
    
//    if( self.cell != nil )
//    {
//        [self.cell.shareVw removeFromSuperview];
//        self.cell.shareVw = nil;
//        
//        
//    }
    
    VideoCell *cell = (VideoCell*)notification.object;
    if( self.cell.btnShare.tag != cell.btnShare.tag )
    {
        DLog(@"Log : Remove the previous sharing screen");
        [self.cell handleRightSwipe:self.cell];
       // [[NSNotificationCenter defaultCenter] postNotificationName:removeSharingView object:nil];
//        [self.cell.shareVw removeFromSuperview];
//        self.cell.shareVw = nil;
    }
    self.cell = cell; //(VideoCell*)notification.object;
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
            
//            if( self.list == nil )
//            {
                DLog(@"Log : List object does not exist... Create it...");
                self.list = (ListViewController*)[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"listDash")];
                self.list.view.frame = CGRectMake(0, 34, 320, self.view.frame.size.height - 34);
//            }
            
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
    
    //[ViblioHelper displayAlertWithTitle:@"Progress" messageBody:@"Developem" viewController:<#(UIViewController *)#> cancelBtnTitle:<#(NSString *)#>];
    
//    [APPCLIENT getCountOfMediaFilesUploadedByUser:^(int count)
//     {
//         DLog(@"Log : The count obtained is - %d", count);
//     }failure:^(NSError *error)
//     {
//         DLog(@"Log : Error call back with error - %@", [error localizedDescription]);
//     }];
//
//    
//    if( self.list != nil )
//    {
//        [self.list.view removeFromSuperview];
//    }
    
    [self.segment setHidden:YES];
    //self.navigationItem.rightBarButtonItem = nil;
    
//    DLog(@"Log : Coming here at least for hoem view controller shared with me");
//    [APPCLIENT getCountOfMediaFilesUploadedByUser:^(int count)
//    {
//        DLog(@"Log : The count obtained is - %d", count);
//    }failure:^(NSError *error)
//    {
//        DLog(@"Log : Error call back with error - %@", [error localizedDescription]);
//    }];
}

- (IBAction)MyViblioClicked:(id)sender {
    [self setBackGroundColorsForButtons:YES];
    [self.segment setHidden:NO];
    
    if( self.sharedList != nil )
    {
        [self.sharedList.view removeFromSuperview];
        self.sharedList = nil;
    }
//    if( self.navigationItem.rightBarButtonItem == nil )
//    {
//        DLog(@"Log : Entering into bar button nil condition");
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.segment];
//    }
}

- (IBAction)stopMe:(id)sender {
    [APPCLIENT invalidateFileUploadTask];
}

- (IBAction)touchMeClicked:(id)sender {
    
    DLog(@"LOG : Touch Me detected");
  
//    [APPCLIENT invalidateFileUploadTask];
//    [DBCLIENT updateSynStatusOfFile:@"assets-library://asset/asset.MOV?id=81A618BF-5E75-4EB9-B186-F247CF0EB4B8&ext=MOV" syncStatus:0];
//    [DBCLIENT updateSynStatusOfFile:@"assets-library://asset/asset.MOV?id=3CB0B4EA-D6E0-4454-942D-4FAD79660304&ext=MOV" syncStatus:0];
    
    [DBCLIENT listAllEntitiesinTheDB];
//    [VCLIENT videoUploadIntelligence];
//    [APPCLIENT getCountOfMediaFilesUploadedByUser:^(int count)
//    {
//        DLog(@"Log : The count obtained is - %d", count);
//    }failure:^(NSError *error)
//    {
//        
//    }];
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

- (IBAction)showMenuList:(id)sender {
    
    DLog(@"Log : Reveal sliding menu");
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    DLog(@"LOG : Count being returned is - %d", VCLIENT.filteredVideoList.count);
    return VCLIENT.cloudVideoList.count;
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
        
//        if( self.cell != nil &&  (self.indexClicked == indexPath.row) )
//        {
//            DLog(@"Log : Getting in... %ld -- %ld", (long)self.cell.btnShare.tag, (long)indexPath.row);
//            [cell.vwPlayShare setHidden:YES];
//        }
//        else
//        {
//            [cell.vwPlayShare setHidden:NO];
//        }
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

//- (IBAction)leftSwipeDetected:(id)sender {
//    
//    VideoCell *cell = (VideoCell*)sender;
//    DLog(@"Log : Left swipe detected on cell at index - %d", cell.btnShare.tag);
//}
//
//
//- (IBAction)rightSwipeDetected:(id)sender {
//    
//    VideoCell *cell = (VideoCell*)sender;
//    DLog(@"Log : Right swipe detected on cell at index - %d", cell.btnShare.tag);
//}

@end
