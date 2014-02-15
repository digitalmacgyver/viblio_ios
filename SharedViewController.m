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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"sharedvideolist";
    SharedVideo *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblOwnerName.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    cell.lblVwCount.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    
    if( indexPath.row < self.sharedList.count )
    {
        SharedVideos *video = self.sharedList[indexPath.row];
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
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    DLog(@"Log : Coming here .....");
    return self.sharedList.count;
}

@end
