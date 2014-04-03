//
//  SharedVideoListViewController.m
//  Viblio_v2
//
//  Created by Vinay Raj on 19/03/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SharedVideoListViewController.h"

@interface SharedVideoListViewController ()

@end

@implementation SharedVideoListViewController

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

}

-(void)viewDidAppear:(BOOL)animated
{
    int section = APPMANAGER.indexOfSharedListSelected.section;
    NSMutableArray *sortedList = APPMANAGER.sharedSortedList[ APPMANAGER.sharedOrderedKeys[section]];
    
    DLog(@"LOg : ******************************* Section is  ***************** %@", sortedList);
    
    NSMutableDictionary *ownerSharedList = sortedList[APPMANAGER.indexOfSharedListSelected.row];
    
    DLog(@"LOg : ******************************* Row is  ***************** %@", ownerSharedList);
    
    self.categorisedSharedList = [ViblioHelper getDateTimeCategorizedArrayFrom:ownerSharedList[@"media"]];
    APPMANAGER.sharedOwnerOrderedKeys = [[ViblioHelper getReOrderedListOfKeys:[[self.categorisedSharedList allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)]] mutableCopy];
    
    DLog(@"LOg : ******************************* Categorised list is  ***************** %@", self.categorisedSharedList);
    
    [self.tblOwnerShared reloadData];
    self.lblOwnerName.text = ownerSharedList[@"owner"][@"displayname"];
    [APPCLIENT streamAvatarsImageForUUID:ownerSharedList[@"owner"][@"uuid"] success:^(UIImage *image)
     {
         self.imgVwOwner.image = image;
         [self.view bringSubviewToFront:self.imgVwOwner];
         
     }failure:^(NSError *error)
     {
         
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Table View Delegate Mehods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSArray *allKeys = [APPMANAGER.sharedSortedList allKeys];
    return APPMANAGER.sharedOwnerOrderedKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    DLog(@"Log : Coming in a owner delegate - %d", self.ownerSharedVideos.count);
    return ((NSArray*)self.categorisedSharedList[APPMANAGER.sharedOwnerOrderedKeys[sectionIndex]]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(IS_IPHONE_5)
        return 201;
    else
        return 201;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DLog(@"Log : view for section header");
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 20)];
    [label setFont:[UIFont fontWithName:@"Avenir-Roman" size:14]];
    label.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    
    /* Section header is in 0th index... */
    [label setText:APPMANAGER.sharedOwnerOrderedKeys[section]];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]]; //your background color...
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"sharedvideolist";
    SharedVideo *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblVwCount.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];

    if( indexPath.section < APPMANAGER.sharedOwnerOrderedKeys.count )
    {
        NSArray *sharedObj = self.categorisedSharedList[APPMANAGER.sharedOwnerOrderedKeys[indexPath.section]];
        
//        NSArray *videoBySpecificOwner = sharedObj[0][@"media"];
//        NSString *ownerName = sharedObj[0][@"owner"][@"displayname"];
//        NSString *ownerUUID = sharedObj[0][@"owner"][@"uuid"];
        
        SharedVideos *video = [[SharedVideos alloc]init];
        NSDictionary *mediaObj = (NSDictionary*)sharedObj[indexPath.row];
        //        video.createdDate = mediaObj[@"created_date"];
        //        video.sharedDate = mediaObj[@"shared_date"];
        video.mediaUUID = mediaObj[@"uuid"];
        video.viewCount = (NSNumber*)mediaObj[@"view_count"] ;
        video.posterURL = mediaObj[@"views"][@"poster"][@"url"];
//        video.ownerName = ownerName;
//        video.ownerUUID = ownerUUID;
        
        cell.indexPath = indexPath;
        cell.btnSeeMore.tag = indexPath.row;
        cell.lblOwnerName.text = video.ownerName;
        [cell.imgVwPoster setImageWithURL:[ NSURL URLWithString:video.posterURL ]];
        cell.video = video;
        cell.lblVwCount.text = [NSString stringWithFormat:@"%d", video.viewCount.integerValue];
        
        
//        DLog(@"Log : The video data is - %@", video);
//        [APPCLIENT streamAvatarsImageForUUID:video.ownerUUID success:^(UIImage *image)
//         {
//             cell.imgVwOwner.image = image;
//             
//         }failure:^(NSError *error)
//         {
//             
//         }];
        //        }
    }
    return cell;
}

-(void)viewWillDisappear:(BOOL)animated
{
    APPMANAGER.indexOfSharedListSelected = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (IBAction)gotoAllShared:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:removeOwnerSharingView object:nil];
}
@end
