//
//  TellAFriendViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/29/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "TellAFriendViewController.h"

@interface TellAFriendViewController ()

@end

@implementation TellAFriendViewController

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
    
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationTellAFriendTitleView]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                              [UIButton navigationItemWithTarget:self action:@selector(tellAFriend) withImage:@"" withTitle:@"Send"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                             [UIButton navigationItemWithTarget:self action:@selector(revealMenu) withImage:@"icon_options"]];
    
    self.txtVwTellAFriend.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtVwTellAFriend.layer.borderWidth = 1.0;
    self.txtVwTellAFriend.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.txtVwTellAFriend.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
}

-(void)tellAFriend
{
    
}

-(void)revealMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)twitterClicked:(id)sender {
    
    if( self.btnTwitter.tag )
    {
        self.btnTwitter.tag = 0;
        [self.btnTwitter setImage:[UIImage imageNamed:@"bttn_twitter_normal"] forState:UIControlStateNormal];
    }
    else
    {
        self.btnTwitter.tag = 1;
        [self.btnTwitter setImage:[UIImage imageNamed:@"bttn_twitter_tap"] forState:UIControlStateNormal];
    }
}


- (IBAction)facebookClicked:(id)sender {
    if( self.btnFacebook.tag )
    {
        self.btnFacebook.tag = 0;
        [self.btnFacebook setImage:[UIImage imageNamed:@"bttn_facebook_normal"] forState:UIControlStateNormal];
    }
    else
    {
        self.btnFacebook.tag = 1;
        [self.btnFacebook setImage:[UIImage imageNamed:@"bttn_facebook_tap"] forState:UIControlStateNormal];
    }
}


- (IBAction)googleClicked:(id)sender {
    if( self.btnGoogle.tag )
    {
        self.btnGoogle.tag = 0;
        [self.btnGoogle setImage:[UIImage imageNamed:@"bttn_google_plus_normal"] forState:UIControlStateNormal];
    }
    else
    {
        self.btnGoogle.tag = 1;
        [self.btnGoogle setImage:[UIImage imageNamed:@"bttn_google_plus_tap"] forState:UIControlStateNormal];
    }
}


- (IBAction)mailClicked:(id)sender {
    if( self.btnMail.tag )
    {
        self.btnMail.tag = 0;
        [self.btnMail setImage:[UIImage imageNamed:@"bttn_mail_normal"] forState:UIControlStateNormal];
    }
    else
    {
        self.btnMail.tag = 1;
        [self.btnMail setImage:[UIImage imageNamed:@"bttn_mail_tap"] forState:UIControlStateNormal];
    }
}


#pragma textview delegates

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if( [textView.text isEqualToString:@"Type your message here"] )
        textView.text = @"";
    
    CGRect txtVwFrame = self.txtVwTellAFriend.frame;
    txtVwFrame.size.height -= 215;
    self.txtVwTellAFriend.frame = txtVwFrame;
    
    CGRect vwSharingFrame = self.vwSharingOptions.frame;
    vwSharingFrame.origin.y -= 215;
    self.vwSharingOptions.frame = vwSharingFrame;
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        
        if( [textView.text isEqualToString:@""] )
            textView.text = @"Type your message here";
        
        CGRect txtVwFrame = self.txtVwTellAFriend.frame;
        txtVwFrame.size.height += 215;
        self.txtVwTellAFriend.frame = txtVwFrame;
        
        CGRect vwSharingFrame = self.vwSharingOptions.frame;
        vwSharingFrame.origin.y += 215;
        self.vwSharingOptions.frame = vwSharingFrame;
        
        [self.txtVwTellAFriend resignFirstResponder];
    }
    
    return YES;
}


@end
