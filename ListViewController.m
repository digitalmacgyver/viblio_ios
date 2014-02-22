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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOtherSharingViews:) name:showListSharingVw object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContacts:) name:showContactsScreen object:nil];
    
    if( VCLIENT.cloudVideoList == nil && VCLIENT.cloudVideoList.count <= 0 )
    {
        [APPCLIENT getListOfSharedWithMeVideos:^(NSArray *sharedList)
        {
            VCLIENT.cloudVideoList = [sharedList mutableCopy];
            VCLIENT.resCategorized = [ViblioHelper getDateTimeCategorizedArrayFrom:APPMANAGER.listVideos];
            [self.listView reloadData];
        }failure:^(NSError *error)
        {
            DLog(@"Log : Could not load list of videos.. ");
        }];
    }
}

-(void)removeOtherSharingViews : (NSNotification*)notification
{
    DLog(@"Log : Obtaning the list...");
    listTableCell *list = (listTableCell*)notification.object;
    
    if( self.listCell != nil && (self.listCell.btnShare.tag != list.btnShare.tag) )
       [self.listCell removeShareVw]; //[[NSNotificationCenter defaultCenter] postNotificationName:removeListSharinVw object:nil];
    
    self.listCell = list;
    list = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    //[self.addressesArray removeAllObjects];
    self.address = nil;
    self.dateStamp = nil;
    self.faceIndexes = nil;
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Table View Delegate Mehods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    DLog(@"Log : Coming in number of rows in sections" );
    return ((NSArray*)VCLIENT.resCategorized[[[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)][sectionIndex]]).count-1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DLog(@"Log : Coming in number of sections");
    NSArray *allKeys = [VCLIENT.resCategorized allKeys];
    DLog(@"Log : The count is - %d - %@", allKeys.count, allKeys);
    return allKeys.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DLog(@"Log : view for section header");
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 20)];
    [label setFont:[ViblioHelper viblio_Font_Regular_WithSize:13 isBold:NO]];
    label.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    NSString *string = ((NSArray*)VCLIENT.resCategorized[[[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)][section]])[0]; //[VCLIENT.resCategorized allKeys][section];
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]]; //your background color...
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Log : Cell for section");
    NSString *cellIdentifier = @"listCells";
    
    listTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.btnImage setImage:nil forState:UIControlStateNormal];
    
    DLog(@"Log : Coming into section - %d", indexPath.section);
    if( indexPath.section < VCLIENT.resCategorized.allKeys.count )
    {
        DLog(@"Log : In if for section");
        NSMutableArray *resArrayOfVideoObjects = [VCLIENT.resCategorized[[[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)][indexPath.section]] mutableCopy];
        [resArrayOfVideoObjects removeObjectAtIndex:0];
        
        if( indexPath.row < resArrayOfVideoObjects.count )
        {
            cloudVideos *video = [resArrayOfVideoObjects objectAtIndex:indexPath.row];
            cell.video = video;
            [cell.imgVwThumbnail setImageWithURL:[NSURL URLWithString:video.url]];
            cell.btnPlay.tag = cell.btnShare.tag = indexPath.row;
        }
        
        [cell.lblUploadNow setHidden:YES];
        [cell.lblShareNow setHidden:YES];
        [cell.btnPlay setHidden:NO];
        //[cell.btnShare setHidden:NO];
        cell.lblInfo.text = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(removeShareVw) name:removeListSharinVw object:nil];
        
        // [[NSNotificationCenter defaultCenter] postNotificationName:stopVideo object:nil];
        
        // Logic for Lazy loading
        
        DLog(@"Log : The current section is - %d", indexPath.section);
        //int rowTotalCount = 0;
        
        if( indexPath.section == VCLIENT.resCategorized.allKeys.count-1 )
        {
            if( (indexPath.row == resArrayOfVideoObjects.count-1) && VCLIENT.totalRecordsCount > VCLIENT.cloudVideoList.count )
            {
                DLog(@"Log : Lazy load next set of records...");
                [APPCLIENT getTheListOfMediaFilesOwnedByUserWithOptions:@"poster" pageCount:[NSString stringWithFormat:@"%d",(VCLIENT.cloudVideoList.count/ROW_COUNT.integerValue)+1] rows:ROW_COUNT success:^(NSMutableArray *result)
                 {
                     //NSArray *res = [NSArray arrayWithArray:result];
                     VCLIENT.cloudVideoList = [[VCLIENT.cloudVideoList arrayByAddingObjectsFromArray:result ] mutableCopy];
                     VCLIENT.resCategorized = nil;
                     VCLIENT.resCategorized = [ViblioHelper getDateTimeCategorizedArrayFrom:VCLIENT.cloudVideoList];
                     DLog(@"Log : VClient - %@", VCLIENT.resCategorized);
                     DLog(@"Log : The keys are - %@", [[VCLIENT.resCategorized allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)]);
                     [self.listView reloadData];
                 }failure:^(NSError *error)
                 {
                     DLog(@"Log : Error description - %@", error.localizedDescription);
                 }];
            }
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
             DLog(@"Log : The faces list obtained is - %@ and face list count is - %d", facesList, facesList.count);
             
             // If faces list is empty then make a call to reverse geo coding of address
             
             if( facesList != nil && facesList.count > 0 )
             {
                 [cell.lblInfo setHidden:YES];
                 [cell.scrlFaces setHidden:NO];
                 
                 [self.faceIndexes setValue:facesList forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                 
                 for( int i = 0; i < facesList.count; i++ )
                 {
                     if( i < faceImgList.count )
                     {
                         [((UIImageView*)faceImgList[i]).layer setCornerRadius:((UIImageView*)faceImgList[i]).frame.size.width/2];
                         ((UIImageView*)faceImgList[i]).clipsToBounds = YES;
                         [((UIImageView*)faceImgList[i]) setImageWithURL:[NSURL URLWithString:facesList[i]]];
                         [((UIImageView*)faceImgList[i]) setHidden:NO];
                     }
                     else
                         break;
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
                     displayResultForDateTime = nil;
                     [self.dateStamp setValue:cell.video.createdDate forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                 }
             }
         }failure:^(NSError *error)
         {
             
         }];
        
        faceImgList = nil;
    }
    

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

@end
