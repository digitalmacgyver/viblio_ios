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
    [APPCLIENT getListOfSharedWithMeVideos:^(NSArray *sharedObjectsArray)
     {
         DLog(@"Log : The list of objects array obtained is - %@", sharedObjectsArray);
         self.sharedList = sharedObjectsArray;
         self.resCategorizedList = [ViblioHelper getDateTimeCategorizedArrayFrom:self.sharedList];
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
    return 240;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DLog(@"Log : Coming in number of sections");
    NSArray *allKeys = [self.resCategorizedList allKeys];
    DLog(@"Log : The count is - %d - %@", allKeys.count, allKeys);
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
    NSString *string = ((NSArray*)self.resCategorizedList[[[self.resCategorizedList allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)][section]])[0]; //[VCLIENT.resCategorized allKeys][section];
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]]; //your background color...
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"sharedvideolist";
    SharedVideo *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.lblOwnerName.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    cell.lblVwCount.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    
    // If movie is being played stop it as the focus shifts on scrolling
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:stopVideo object:nil];
    
    if( indexPath.section < self.resCategorizedList.allKeys.count )
    {
        NSMutableArray *resArrayOfVideoObjects = [self.resCategorizedList[[[self.resCategorizedList allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)][indexPath.section]] mutableCopy];
        [resArrayOfVideoObjects removeObjectAtIndex:0];
        
        if( indexPath.row < resArrayOfVideoObjects.count )
        {
            SharedVideos *video = resArrayOfVideoObjects[indexPath.row];
            cell.lblOwnerName.text = video.ownerName;
            [cell.imgVwPoster setImageWithURL:[ NSURL URLWithString:video.posterURL ]];
            cell.video = video;
            
            [APPCLIENT streamAvatarsImageForUUID:video.ownerUUID success:^(UIImage *image)
             {
                 cell.imgVwOwner.image = image;
             }failure:^(NSError *error)
             {
                 
             }];
        }
    }

    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    DLog(@"Log : Coming here .....");
    return ((NSArray*)self.resCategorizedList[[[self.resCategorizedList allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)][sectionIndex]]).count-1;
    //return self.sharedList.count;
}

@end
