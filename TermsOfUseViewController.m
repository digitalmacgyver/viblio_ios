//
//  TermsOfUseViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/24/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "TermsOfUseViewController.h"

@interface TermsOfUseViewController ()

@end

@implementation TermsOfUseViewController

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
    
    CGRect tempFrame = self.termsView.frame;
    [self.termsView setFrame:CGRectZero];
    [self.termsView setFrame:tempFrame];
}

-(void)viewDidAppear:(BOOL)animated
{
    [APPCLIENT fetchTermsAndConditions:^(NSString *terms)
     {
         DLog(@"Log : Terms fetched is - %@", terms);
     //    self performSelectorOnMainThread:@selector(setText:) withObject:<#(id)#> waitUntilDone:<#(BOOL)#>
//         dispatch_async(dispatch_get_main_queue(), ^{
//         
//             self.termsView.text = @"terms";//terms;
//             self.termsView.textColor = [UIColor whiteColor];
//             
//         
//         });
         self.text = terms;
         [self performSelectorOnMainThread:@selector(setText) withObject:nil waitUntilDone:NO];
         

     }failure:^(NSError *error)
     {
         DLog(@"Log : Could not fetch terms and conditions");
         [(DashBoardNavController*)self.navigationController popViewControllerAnimated:YES];
     }];
}

-(void)setText
{
    self.termsView.text = self.text;
    self.termsView.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
