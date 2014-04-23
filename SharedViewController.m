//
//  SharedViewController.m
//  Viblio_v2
//
//  Created by Vinay Raj on 13/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SharedViewController.h"

@interface SharedViewController ()

@end

@implementation SharedViewController

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
    [APPCLIENT getListOfSharedWithMeVideos:^(NSMutableArray *sharedObjectsArray)
     {
         DLog(@"Log : The list of objects array obtained is - %@", sharedObjectsArray);
         
         APPMANAGER.sharedVideoList = sharedObjectsArray;

         APPMANAGER.sharedSortedList = [ViblioHelper getDateTimeCategorizedArrayFrom:APPMANAGER.sharedVideoList];
      
         DLog(@"Log : categorized list is - %@", self.resCategorizedList);
         
         APPMANAGER.sharedOrderedKeys = [[ViblioHelper getReOrderedListOfKeys:[[APPMANAGER.sharedSortedList allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)]] mutableCopy];
         
         DLog(@"Log : ey ordered list is - %@", APPMANAGER.sharedOrderedKeys);
         [self.tblSharedList reloadData];
     }failure:^(NSError *error)
     {
         DLog(@"Log : Error - %@", [error localizedDescription]);
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma table view delegate functions

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 280;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *allKeys = [APPMANAGER.sharedSortedList allKeys];
    return allKeys.count;
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
    [label setText:APPMANAGER.sharedOrderedKeys[section]];
    
    if( [label.text isEqualToString:@"1970"] )
    {
        label.text = @"No Date";
    }
    
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
    
    if( indexPath.section < APPMANAGER.sharedOrderedKeys.count )
    {
        NSArray *sharedObj = APPMANAGER.sharedSortedList[APPMANAGER.sharedOrderedKeys[indexPath.section]];
        DLog(@"LOg : Main object obtained is - %@", sharedObj);//APPMANAGER.sharedVideoList[indexPath.row];
//        NSMutableArray *sectionItem
//        
//        if( indexPath.row < APPMANAGER.sharedVideoList.count )
//        {
            NSArray *videoBySpecificOwner = sharedObj[0][@"media"];
            NSString *ownerName = sharedObj[0][@"owner"][@"displayname"];
            NSString *ownerUUID = sharedObj[0][@"owner"][@"uuid"];

            SharedVideos *video = [[SharedVideos alloc]init];
            NSDictionary *mediaObj = (NSDictionary*)[videoBySpecificOwner objectAtIndex:indexPath.row];
            //        video.createdDate = mediaObj[@"created_date"];
            //        video.sharedDate = mediaObj[@"shared_date"];
            video.mediaUUID = mediaObj[@"uuid"];
            video.viewCount = (NSNumber*)mediaObj[@"view_count"] ;
            video.posterURL = mediaObj[@"views"][@"poster"][@"url"];
            video.ownerName = ownerName;
            video.ownerUUID = ownerUUID;
        
            cell.indexPath = indexPath;
            cell.btnSeeMore.tag = indexPath.row;
            cell.lblOwnerName.text = video.ownerName;
            [cell.imgVwPoster setImageWithURL:[ NSURL URLWithString:video.posterURL ]];
            cell.video = video;
            cell.lblVwCount.text = [NSString stringWithFormat:@"%d", video.viewCount.integerValue];
        
        
        DLog(@"Log : The video data is - %@", video);
            [APPCLIENT streamAvatarsImageForUUID:video.ownerUUID success:^(UIImage *image)
             {
                 cell.imgVwOwner.image = image;
                 
             }failure:^(NSError *error)
             {
                 
             }];
//        }
    }

    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    DLog(@"Log : Coming here .....");
   // return ((NSArray*)self.resCategorizedList[[[self.resCategorizedList allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)][sectionIndex]]).count-1;
    return 1;//APPMANAGER.sharedVideoList.count;
}

@end
