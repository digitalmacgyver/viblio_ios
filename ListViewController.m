//
//  ListViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/24/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ListViewController.h"
#define ROW_COUNT @"12"

@interface ListViewController ()

@end

@implementation ListViewController

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
    
    self.address = [[NSMutableDictionary alloc]init];
    self.dateStamp = [[NSMutableDictionary alloc]init];
    self.faceIndexes = [[NSMutableDictionary alloc]init];
}

-(void)viewDidAppear:(BOOL)animated
{
}

-(void)viewWillDisappear:(BOOL)animated
{
    //[self.addressesArray removeAllObjects];
    self.address = nil;
    self.dateStamp = nil;
    self.faceIndexes = nil;
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
    DLog(@"Log : Coming here .....%@", VCLIENT.cloudVideoList);
    return VCLIENT.cloudVideoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"listCells";
    
    listTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.btnImage setImage:nil forState:UIControlStateNormal];
    if( indexPath.row < VCLIENT.cloudVideoList.count )
    {
        cloudVideos *video = [VCLIENT.cloudVideoList objectAtIndex:indexPath.row];
        cell.video = video;
        [cell.imgVwThumbnail setImageWithURL:[NSURL URLWithString:video.url]];
        cell.btnPlay.tag = indexPath.row;
    }
    
    [cell.lblUploadNow setHidden:YES];
    [cell.lblShareNow setHidden:YES];
    [cell.btnPlay setHidden:NO];
    [cell.btnShare setHidden:NO];
    cell.lblInfo.text = nil;

    [[NSNotificationCenter defaultCenter] postNotificationName:stopVideo object:nil];
    if( (indexPath.row == VCLIENT.cloudVideoList.count-1) && VCLIENT.totalRecordsCount > VCLIENT.cloudVideoList.count )
    {
        DLog(@"Log : Lazy load next set of records...");
        [APPCLIENT getTheListOfMediaFilesOwnedByUserWithOptions:@"poster" pageCount:[NSString stringWithFormat:@"%d",(int)((indexPath.row+1)/ROW_COUNT.integerValue)+1] rows:ROW_COUNT success:^(NSMutableArray *result)
         {
             //NSArray *res = [NSArray arrayWithArray:result];
             VCLIENT.cloudVideoList = [[VCLIENT.cloudVideoList arrayByAddingObjectsFromArray:result ] mutableCopy];
             [self.listView reloadData];
         }failure:^(NSError *error)
         {
             DLog(@"Log : Error description - %@", error.localizedDescription);
         }];
    }
    
    // Logic to decide whether share tag is to be shown or not
    
    [APPCLIENT hasAMediaFileBeenSharedByTheUSerWithUUID:cell.video.uuid success:^(BOOL isShared)
    {
       if( isShared )
          [cell.lblShareNow setHidden:YES];
        else
            [cell.lblShareNow setHidden:NO];
        
    }failure:^(NSError *error)
    {
        
    }];

    // Logic for filling the information data in list view here
    NSArray *faceImgList = @[cell.face1, cell.face2, cell.face3, cell.face4];
    for( UIImageView *face in faceImgList )
    {
        face.image = nil;
        [face setHidden:YES];
    }
    
    // Implement proper caching mechanism here...
    
//    if( self.address[[NSString stringWithFormat:@"%d",indexPath.row]] != nil )
//    {
//        DLog(@"Log : Show address for index path - %d   ---    %@", indexPath.row, self.address[[NSString stringWithFormat:@"%d",indexPath.row]]);
//        // Already a cached address for the index exists. Need not make a web service call
//        cell.lblInfo.text = self.address[[NSString stringWithFormat:@"%d",indexPath.row]];
//        cell.lblInfo.font = [ViblioHelper viblio_Font_Regular_WithSize:12 isBold:NO];
//    }
//    else if( self.faceIndexes[[NSString stringWithFormat:@"%d", indexPath.row]]  != nil )
//    {
//        DLog(@"LOg : Faces aleady cached.. Do not do anything..");
//        
//        NSArray *facesList = self.faceIndexes[[NSString stringWithFormat:@"%d", indexPath.row]];
//        for( int i = 0; i < facesList.count; i++ )
//        {
//            [((UIImageView*)faceImgList[i]).layer setCornerRadius:((UIImageView*)faceImgList[i]).frame.size.width/2];
//            ((UIImageView*)faceImgList[i]).clipsToBounds = YES;
//            [((UIImageView*)faceImgList[i]) setImageWithURL:[NSURL URLWithString:facesList[i]]];
//            [((UIImageView*)faceImgList[i]) setHidden:NO];
//        }
//        facesList = nil;
//    }
//    else if (self.dateStamp[[NSString stringWithFormat:@"%d", indexPath.row]] != nil)
//    {
//        DLog(@"Log : Show date time for index path - %d", indexPath.row);
//        cell.lblInfo.text = self.dateStamp[[NSString stringWithFormat:@"%d", indexPath.row]];
//        cell.lblInfo.font = [ViblioHelper viblio_Font_Regular_WithSize:16 isBold:NO];
//    }
//    else
//    {
    
    // Non cached direct working mode
    
        [APPCLIENT getFacesInAMediaFileWithUUID:cell.video.uuid success:^(NSArray *facesList)
         {
             DLog(@"Log : The faces list obtained is - %@", facesList);
             
             // If faces list is empty then make a call to reverse geo coding of address
             
             if( facesList != nil && facesList.count > 0 )
             {
                 [cell.lblInfo setHidden:YES];
                 [cell.scrlFaces setHidden:NO];
                 
                 [self.faceIndexes setValue:facesList forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                 
                 for( int i = 0; i < facesList.count; i++ )
                 {
                     [((UIImageView*)faceImgList[i]).layer setCornerRadius:((UIImageView*)faceImgList[i]).frame.size.width/2];
                     ((UIImageView*)faceImgList[i]).clipsToBounds = YES;
                     [((UIImageView*)faceImgList[i]) setImageWithURL:[NSURL URLWithString:facesList[i]]];
                     [((UIImageView*)faceImgList[i]) setHidden:NO];
                 }
             }
             else
             {
                 // Check wheteher latitude and longitude info available or not
                 
                 [cell.lblInfo setHidden:NO];
                 [cell.scrlFaces setHidden:YES];
                 
                 if( [cell.video.lat isValid] && [cell.video.longitude isValid] )
                 {
                     DLog(@"Log : Faces returned an empty set.. Fetching the lat and longitude now");

                         // We do not have cached address. Make a web service call to get the address
                         [APPCLIENT getAddressWithLat:cell.video.lat andLong:cell.video.longitude success:^(NSString *address)
                          {
                              cell.lblInfo.text = address;
                              [self.address setValue:address forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                              cell.lblInfo.font = [ViblioHelper viblio_Font_Regular_WithSize:12 isBold:NO];
                          }failure:^(NSError *error)
                          {
                              
                          }];
                 }
                 else
                 {
                     DLog(@"Log : No Faces and No lat and Long found.. Displaying the created date field now...");
                     [cell.lblUploadNow setHidden:NO];
                     cell.lblInfo.font = [ViblioHelper viblio_Font_Regular_WithSize:16 isBold:NO];
                     NSArray *displayResultForDateTime = [ViblioHelper getDateTimeStampToReadableFormat:cell.video.createdDate];
                     cell.lblInfo.text = [displayResultForDateTime firstObject];
                     //cell.lblUploadNow.font = [ViblioHelper viblio_Font_Italic_WithSize:12 isBold:NO];
                     //cell.lblUploadNow.text = [displayResultForDateTime lastObject];
                     //cell.lblUploadNow.backgroundColor = [UIColor redColor];
                     displayResultForDateTime = nil;
                     //cell.video.createdDate;
                     [self.dateStamp setValue:cell.video.createdDate forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                 }
             }
         }failure:^(NSError *error)
         {
             
         }];
        
        faceImgList = nil;
    //}
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}



@end
