//
//  MenuViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/17/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_menuSections;
}
@end

@implementation MenuViewController

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
    
//    self.menuList.dataSource = self;
//    self.menuList.delegate = self;
    
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
    self.menuList.backgroundColor = [UIColor redColor];
    _menuSections = @[@"Settings", @"Help/FAQ", @"Tell A Friend", @"Give Feedback", @"Legal & Privacy", @"Rate Us In App Store"];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshProgressBar) name:refreshProgress object:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
    DLog(@"Log : Geting the information of video being uploaded to show in progress bar");
    
    if( VCLIENT.asset != nil )
    {
        DLog(@"Log : Upload in progress....");
        [self.vwProgressBar setHidden:NO];
        //self.uploadingImg.image = [UIImage imageWithCGImage:[VCLIENT.asset thumbnail]];
        [self refreshProgressBar];
    }
    else
    {
        DLog(@"Log : No Upload in progress....");
        [self.vwProgressBar setHidden:YES];
        self.uploadingImg.image = nil;
        self.lblProgressTitle.text = @"All uploads have finished";
    }
}

-(void)refreshProgressBar
{
    DLog(@"Log : Refreshing the progress bar for file");
    DLog(@"Log : uploaded size is - %f", APPCLIENT.uploadedSize);
    DLog(@"Log : File size is - %lld", VCLIENT.asset.defaultRepresentation.size);
    DLog(@"Log : Uploaded percentage should be - %f", APPCLIENT.uploadedSize / VCLIENT.asset.defaultRepresentation.size);
    
    double percentageUploaded = APPCLIENT.uploadedSize / VCLIENT.asset.defaultRepresentation.size;
    CGRect progressBarFrame = self.lblProgressBar.frame;
    progressBarFrame.size.width = self.vwProgressBar.frame.size.width * percentageUploaded;
    self.lblProgressBar.frame = progressBarFrame;
    self.uploadingImg.image = [UIImage imageWithCGImage:[VCLIENT.asset thumbnail]];
    
    
    DLog(@"Log : progress bar width should be - %f", progressBarFrame.size.width);
}

- (IBAction)progressBarClicked:(id)sender {
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    self.slidingViewController.topViewController.view.userInteractionEnabled = NO;
//}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    self.slidingViewController.topViewController.view.userInteractionEnabled = YES;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma Table View Delegate Mehods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _menuSections.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MenuCell";
    
    tableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor clearColor];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Change the background color for selection background color
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = myBackView;
    
    cell.textLabel.text = _menuSections[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14];
    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;
}

@end
