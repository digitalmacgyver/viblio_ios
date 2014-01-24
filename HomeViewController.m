//
//  HomeViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/17/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "HomeViewController.h"

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
    
    [VCLIENT videoUploadIntelligence];
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
        self.btnSharedWithMe.titleLabel.textColor = [UIColor whiteColor];
    }
}


- (IBAction)valueOfSegmentChanged:(id)sender {

    UISegmentedControl *segmentView = (UISegmentedControl*)sender;
    DLog(@"Log : Segment value changed...");

    switch (segmentView.selectedSegmentIndex) {
        case 0:
            DLog(@"Log : Thumbnail view");
            [self setSegmentImages:YES];
            
            break;
        case 1:
            DLog(@"Log : List View");
            [self setSegmentImages:NO];
            break;
        default:
            break;
    }
}

- (IBAction)sharedWithMeClicked:(id)sender {
        [self setBackGroundColorsForButtons:NO];
}

- (IBAction)MyViblioClicked:(id)sender {
    [self setBackGroundColorsForButtons:YES];
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
    return VCLIENT.filteredVideoList.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = (VideoCell*)[cv dequeueReusableCellWithReuseIdentifier:@"VideoStaticCell" forIndexPath:indexPath];
    
   // DLog(@"LOG : filteredVideoList - %@", VCLIENT.filteredVideoList);
    DLog(@"Log : Asst details are - %@", VCLIENT.filteredVideoList[indexPath.row]);
    
    Videos *assetVideo = [DBCLIENT listTheDetailsOfObjectWithURL:[[VCLIENT.filteredVideoList[indexPath.row] defaultRepresentation] url].absoluteString];
    cell.videoImage.image =  [UIImage imageWithCGImage:[VCLIENT.filteredVideoList[indexPath.row] thumbnail]];
    cell.video = [DBCLIENT listTheDetailsOfObjectWithURL:[[VCLIENT.filteredVideoList[indexPath.row] defaultRepresentation] url].absoluteString];
    cell.asset = VCLIENT.filteredVideoList[indexPath.row];
    
    if( [assetVideo.sync_status  isEqual: @(0)] )
    {
        DLog(@"Log : Getting into this if condition");
        [cell.vwUpload setHidden:NO];
    }
    else
    {
        DLog(@"Log : Getting into else condition");
        [cell.vwUpload setHidden:YES];
    }
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Item selected at index path - %d", indexPath.row);
    DLog(@"item at index path is - %@", VCLIENT.filteredVideoList[indexPath.row]);
}
//

//- (UIImage*)loadImage : (ALAsset *)videoAsset {
//    
//    DLog(@"Log : URL obtained is - %@", videoAsset.defaultRepresentation.url.absoluteString);
////    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoAsset.defaultRepresentation.url options:nil];
////    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
////    NSError *err = NULL;
////    CMTime time = CMTimeMake(1, 60);
////    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
////    NSLog(@"err==%@, imageRef==%@", err, imgRef);
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
