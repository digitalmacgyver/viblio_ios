//
//  FeedBackViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/29/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "FeedBackViewController.h"

@interface FeedBackViewController ()

@end

@implementation FeedBackViewController

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
    
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationShareTitleView:@"Feedback"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                            [UIButton navigationRightItemWithTarget:self action:@selector(sendFeedback) withImage:@"" withTitle:@"Send" ]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                              [UIButton navigationLeftItemWithTarget:self action:@selector(revealMenu) withImage:@"icon_options" withTitle:@"Cancel"]];
    
    self.fdbckTxtVw.autocorrectionType = UITextAutocorrectionTypeNo;
    self.fdbckTxtVw.layer.borderWidth = 1.0;
    self.fdbckTxtVw.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.fdbckTxtVw.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
}

-(void)revealMenu
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)sendFeedback
{
    DLog(@"Log : About to send feedback");
    
    if( [self.fdbckTxtVw.text isEqualToString:@"Type your feedback here"] )
    {
        [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"The feedback content is not valid. Please enter valid content to proceed" viewController:nil cancelBtnTitle:@"OK"];
    }
    else
    {
        if( [self.fdbckTxtVw.text isValid] && [self.fdbckTxtVw.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0 )
        {
            NSString *categorySelected = [[NSString alloc]init];
            if( self.btnBravo.tag )
                categorySelected = @"Bravo";
            else
                categorySelected = self.btnBug.tag ? @"Bug" : @"Idea";
            
            // self.fdbckTxtVw.tag = 1;
            [APPCLIENT sendFeedbackToServerWithText:self.fdbckTxtVw.text category:categorySelected success:^(NSString *msg)
             {
                 // self.fdbckTxtVw.tag = 1;
                 
             }failure:^(NSError *error)
             {
             }];
            
            [ViblioHelper displayAlertWithTitle:@"Success" messageBody:@"Feedback successfully sent" viewController:self cancelBtnTitle:@"OK"];
        }
        else
        {
            [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"I love feedback but it doesn’t look like you’ve typed any in. Type in your feedback before pressing send." viewController:nil cancelBtnTitle:@"OK"];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"Log : Ok clicked in alert view...");
    
//    if( self.fdbckTxtVw.tag )
//    {
        [self.fdbckTxtVw resignFirstResponder];
        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
//    else{
//        
//        if( buttonIndex == 0 )
//            [self sendFeedback];
//        else
//        {
//            [self.fdbckTxtVw resignFirstResponder];
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
//    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self bravoClicked:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)bravoClicked:(id)sender {
    
    [self.btnIdea setBackgroundColor:[ViblioHelper getVblBlueColor]];
    [self.btnBug setBackgroundColor:[ViblioHelper getVblBlueColor]];
    [self.btnBravo setBackgroundColor:[ViblioHelper getVblRedColor]];
    
    // Reset Tags
    
    self.btnIdea.tag = self.btnBug.tag = 0;
    self.btnBravo.tag = 1;
}

- (IBAction)bugClicked:(id)sender {
    DLog(@"Log : Bug Clicked detected");
    [self.btnIdea setBackgroundColor:[ViblioHelper getVblBlueColor]];
    [self.btnBug setBackgroundColor:[ViblioHelper getVblRedColor]];
    [self.btnBravo setBackgroundColor:[ViblioHelper getVblBlueColor]];
    
    // Reset Tags
    
    self.btnIdea.tag = self.btnBravo.tag = 0;
    self.btnBug.tag = 1;
}

- (IBAction)ideaClicked:(id)sender {
    [self.btnIdea setBackgroundColor:[ViblioHelper getVblRedColor]];
    [self.btnBug setBackgroundColor:[ViblioHelper getVblBlueColor]];
    [self.btnBravo setBackgroundColor:[ViblioHelper getVblBlueColor]];
    
    // Reset Tags
    
    self.btnBug.tag = self.btnBravo.tag = 0;
    self.btnIdea.tag = 1;
}

#pragma textview delegates

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    DLog(@"Log : Text field did begin editing");
    
    if( [textView.text isEqualToString:@"Type your feedback here"] )
        textView.text = @"";
    
    textView.font = [UIFont fontWithName:@"Avenir-Roman" size:14];
    
    CGRect txtVwFrame = self.fdbckTxtVw.frame;
    txtVwFrame.size.height -= 215;
    self.fdbckTxtVw.frame = txtVwFrame;
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        
        if( [textView.text isEqualToString:@""] )
        {
            textView.text = @"Type your feedback here";
            textView.font = [UIFont fontWithName:@"Avenir-Light" size:14];
        }
        
        CGRect txtVwFrame = self.fdbckTxtVw.frame;
        txtVwFrame.size.height += 215;
        self.fdbckTxtVw.frame = txtVwFrame;
        
        [self.fdbckTxtVw resignFirstResponder];
    }
    
    return YES;
}

@end
