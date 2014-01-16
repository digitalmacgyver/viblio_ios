//
//  SignUpViewController.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/15/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

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

- (IBAction)SignUpClick:(id)sender {
}

- (IBAction)BackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma text field delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Shift the editable frame upwards
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = self.view.frame.origin.y - KeyBoardShiftSize;
    self.view.frame = viewFrame;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    // Shift the editable frame downwards
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = self.view.frame.origin.y + KeyBoardShiftSize;
    self.view.frame = viewFrame;
}

@end
