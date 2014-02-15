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
//    cell.videoImage.image = nil;
//   // DLog(@"LOG : filteredVideoList - %@", VCLIENT.filteredVideoList);
//    DLog(@"Log : Asst details are - %@", VCLIENT.filteredVideoList[indexPath.row]);
//    
//    Videos *assetVideo = [DBCLIENT listTheDetailsOfObjectWithURL:[[VCLIENT.filteredVideoList[indexPath.row] defaultRepresentation] url].absoluteString];
//    cell.videoImage.image =  [UIImage imageWithCGImage:[VCLIENT.filteredVideoList[indexPath.row] thumbnail]];
//    cell.video = [DBCLIENT listTheDetailsOfObjectWithURL:[[VCLIENT.filteredVideoList[indexPath.row] defaultRepresentation] url].absoluteString];
//    cell.asset = VCLIENT.filteredVideoList[indexPath.row];
//    
//    if( [assetVideo.sync_status  isEqual: @(0)] && !APPMANAGER.activeSession.autoSyncEnabled.integerValue )
//    {
//        DLog(@"Log : Getting into this if condition");
//        [cell.vwUpload setHidden:NO];
//    }
//    else
//    {
//        DLog(@"Log : Getting into else condition");
//        [cell.vwUpload setHidden:YES];
//    }
    //
    cell.btnShare.tag = indexPath.row;
    
//    CGRect shareFrame = cell.vwShare.frame;
//    shareFrame.origin.x = cell.frame.origin.x + cell.frame.size.width;
//    cell.vwShare.frame = shareFrame;
    
    if( indexPath.row < VCLIENT.cloudVideoList.count )
    {
        cell.video = [VCLIENT.cloudVideoList objectAtIndex:indexPath.row];

//        [ViblioHelper downloadImageWithURLString:cell.video.url completion:^(UIImage *image, NSError *error)
//        {
//            cell.videoImage.image = image;
//            cell.videoImage.contentMode = UIViewContentModeScaleAspectFill;
//        }];
        
        [cell.videoImage setImageWithURL:[NSURL URLWithString:cell.video.url]];
        //cell.videoImage = [self getScaledImage:cell.videoImage.image];
        //[cell addSubview:[self getScaledImage:cell.videoImage.image]];
        
        if( self.cell != nil &&  (self.indexClicked == indexPath.row) )
        {
            DLog(@"Log : Getting in... %ld -- %ld", (long)self.cell.btnShare.tag, (long)indexPath.row);
            [cell.vwShare setHidden:NO];
            [cell.vwPlayShare setHidden:YES];
        }
        else
        {
            [cell.vwShare setHidden:YES];
            [cell.vwPlayShare setHidden:NO];
        }
    }
    
    if( (indexPath.row == VCLIENT.cloudVideoList.count-1) && VCLIENT.totalRecordsCount > VCLIENT.cloudVideoList.count )
    {
        DLog(@"Log : Lazy load next set of records...");
        [APPCLIENT getTheListOfMediaFilesOwnedByUserWithOptions:@"poster" pageCount:[NSString stringWithFormat:@"%d",(int)((indexPath.row+1)/ROW_COUNT.integerValue)+1] rows:ROW_COUNT success:^(NSMutableArray *result)
         {
             //NSArray *res = [NSArray arrayWithArray:result];
             VCLIENT.cloudVideoList = [[VCLIENT.cloudVideoList arrayByAddingObjectsFromArray:result ] mutableCopy];
             [self.videoList reloadData];
         }failure:^(NSError *error)
         {
             
         }];
    }
    
    return cell;
}

//
//-(void)prepa
//

//- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
//{
//    //avoid redundant drawing
//    if (CGSizeEqualToSize(originalImage.size, size))
//    {
//        return originalImage;
//    }
//    
//    //create drawing context
//    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
//    
//    //draw
//    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
//    
//    //capture resultant image
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    //return image
//    return image;
//}


-(UIImageView*)getScaledImage :(UIImage*)image
{
    @try {
        UIImageView *scaledImageView = [[UIImageView alloc] init];
        CGRect scaledImageFrame;
        scaledImageFrame.origin.x = 0;
        scaledImageFrame.origin.y = 0;
        
//        if( image.size.width < 160 )
//        {
            scaledImageFrame.size.width = 160;
            scaledImageFrame.size.height = ( (160 - image.size.width) * (9/16) ) + image.size.height;
//        }
//        else
//        {
//            scaledImageFrame.size.width = 320;
//            scaledImageFrame.size.height = ( 320 * ( image.size.height  / image.size.width ) );
//        }
        scaledImageView.image = image;
        scaledImageView.frame = scaledImageFrame;
        return scaledImageView;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
    }
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    DLog(@"Item selected at index path - %d", indexPath.row);
//    DLog(@"item at index path is - %@", VCLIENT.filteredVideoList[indexPath.row]);
}
//

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (IBAction)leftSwipeDetected:(id)sender {
    
    VideoCell *cell = (VideoCell*)sender;
    DLog(@"Log : Left swipe detected on cell at index - %d", cell.btnShare.tag);
}


- (IBAction)rightSwipeDetected:(id)sender {
    
    VideoCell *cell = (VideoCell*)sender;
    DLog(@"Log : Right swipe detected on cell at index - %d", cell.btnShare.tag);
}


- (IBAction)playClicked:(id)sender {
}


- (IBAction)shareClicked:(id)sender {

    UIButton *btnClicked = (UIButton*)sender;
    DLog(@"Log : The item clicked is at index - %d", btnClicked.tag);
    NSIndexPath *path = [NSIndexPath indexPathForRow:btnClicked.tag   inSection:0];
    
    
    if( self.cell == nil )
    {
        self.indexClicked = btnClicked.tag;
        self.cell = (VideoCell*)[self.videoList cellForItemAtIndexPath:path];
        [self.cell.vwShare setHidden:NO];
        [self.cell.vwPlayShare setHidden:YES];
    }
    else
        DLog(@"Log : Focus already exists on a different cell...");
    
    
//    int origin = 160;
//    if( (btnClicked.tag % 2) != 0 )
//    {
//        origin = 320;
//    }
//        
//    UIView *shareView = [[UIView alloc]initWithFrame:CGRectMake(origin , cell.frame.origin.y, 160, cell.frame.size.height)];
//    shareView.backgroundColor = [UIColor redColor]; //[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
//    [cell addSubview:shareView];
    
//    CGRect shareFrame = cell.vwShare.frame;
//    shareFrame.origin.x = cell.frame.origin.x + cell.frame.size.width;
//    DLog(@"Log : The origin of share frame is - %lf", shareFrame.origin.x);
//    cell.vwShare.frame = shareFrame;
    
//    
//    [UIView animateWithDuration:1 animations:^{
//    
//        CGRect shareFrame = cell.vwShare.frame;
//        shareFrame.origin.x = cell.frame.origin.x;
//        cell.vwShare.frame = shareFrame;
//        
//    }];
    
}



//- (UIImage*)loadImage : (ALAsset *)videoAsset {
//    
//    DLog(@"Log : URL obtained is - %@", videoAsset.defaultRepresentation.url.absoluteString);
////    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoAsset.defaultRepresentation.url options:nil];
////    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
////    NSError *err = NULL;
////    CMTime time = CMTimeMake(1, 60);
////    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
////    DLog(@"err==%@, imageRef==%@", err, imgRef);
////    
////    return [[UIImage alloc] initWithCGImage:imgRef];
//
//    return [UIImage imageNamed:@"share.png"];
//    
//}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    DLog(@"Being called now");
//    // 2
////    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
////    retval.height += 35; retval.width += 35; return retval;
//    CGSize retVal = CGSizeMake(155, 142);
//    return retVal;
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 10; // This is the minimum inter item spacing, can be more
//}


//// 3
//- (UIEdgeInsets)collectionView:
//(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(50, 20, 50, 20);
//}

@end
