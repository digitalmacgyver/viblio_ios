//
//  SignInViewController.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/9/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

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
    
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
    
    
    self.lblTrial.text = @"we promise you";
    self.lblTrial.numberOfLines = 0;
    
   if( self.lblSignUpWith == nil )
       DLog(@"Label is nil");
}

-(void)viewWillAppear:(BOOL)animated
{
//    self.lblSignUpWith.text = @"Sign up";
   // [self.lblSignUpWith setFont:[UIFont fontWithName:@"Avenir-Medium" size:13]];
//    self.lblSignUpWith.font = [UIFont fontWithName:@"Avenir-Medium" size:20];
//    self.lblSignUpWith.font = [ViblioHelper viblio_Font_Light_Italic_WithSize:14 isBold:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
   // [self.lblSignUpWith setFont: [UIFont fontWithName:@"Aleo-LightItalic" size:13]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)LoginClick:(id)sender {
    [self performSegueWithIdentifier:Viblio_wideNonWideSegue(@"LogInNav") sender:self];
}

- (IBAction)FBAccountClick:(id)sender {
}

- (IBAction)EmailAccountClick:(id)sender {
   [self performSegueWithIdentifier:Viblio_wideNonWideSegue(@"SignUpNav") sender:self];
}

@end
