//
//  ListViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/24/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ListViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Table View Delegate Mehods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    DLog(@"Log : Coming here .....");
    return VCLIENT.filteredVideoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"listCells";
    
    listTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Videos *assetVideo = [DBCLIENT listTheDetailsOfObjectWithURL:[[VCLIENT.filteredVideoList[indexPath.row] defaultRepresentation] url].absoluteString];
    ALAsset *asset = VCLIENT.filteredVideoList[indexPath.row];
    cell.asset = asset;
    cell.video = assetVideo;
    
    cell.lblUploadNow.font = [ViblioHelper viblio_Font_Regular_WithSize:12 isBold:NO];
    
    [cell.btnImage setImage:[UIImage imageWithCGImage:[asset thumbnail]] forState:UIControlStateNormal];
    
    if( [assetVideo.sync_status  isEqual: @(0)] && !APPMANAGER.activeSession.autoSyncEnabled.integerValue )
    {
        DLog(@"Log : Sync not initialised..");
        [cell.lblUploadNow setHidden:NO];
        [cell.btnPlay setHidden:YES];
        [cell.btnShare setHidden:YES];
        [cell.lblInfo setHidden:YES];
    }
    else
    {
        DLog(@"Log : Sync already in progress...");
        [cell.lblShareNow setHidden:YES];
        [cell.lblUploadNow setHidden:YES];
        [cell.btnPlay setHidden:NO];
        [cell.btnShare setHidden:NO];
        [cell.lblInfo setHidden:NO];
        
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[cell.asset valueForProperty:ALAssetPropertyDate]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterFullStyle];
        dateString = (NSString*)[[dateString componentsSeparatedByString:@" "] firstObject];
        cell.lblInfo.text = dateString;
        cell.lblInfo.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
        dateString = nil;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}



@end
