//
//  ViewController.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/13/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

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


- (IBAction)getVideosToBeUploaded:(id)sender {
    
    VCLIENT.asset = VCLIENT.filteredVideoList[VCLIENT.filteredVideoList.count - 1];
//    [VCLIENT otherServices];
//    [VCLIENT startNewFileUpload];
//    [VCLIENT getOffsetFromTheHeadService];
    [VCLIENT videoFromNSData];
}


@end
