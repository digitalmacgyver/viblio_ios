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
    
    [self.navigationController.navigationBar setBackgroundImage:[ViblioHelper setUpNavigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationTitleView]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                             [UIButton navigationItemWithTarget:self action:@selector(revealMenu) withImage:@"icon_options"]];
}

-(void)revealMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)viewDidAppear:(BOOL)animated
{
    [APPCLIENT fetchTermsAndConditions:^(NSString *terms)
     {
         DLog(@"Log : Terms fetched is - %@", terms);
         [self.wvTerms loadHTMLString:terms baseURL:[NSURL URLWithString:@"http://toto.com"]];
     }failure:^(NSError *error)
     {
         DLog(@"Log : Could not fetch terms and conditions");
         [(DashBoardNavController*)self.navigationController popViewControllerAnimated:YES];
     }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DLog(@"Log : Start loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //[self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLog(@"Log : Finish loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   // [self updateButtons];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"Log : Finish loading - error - %@", error.localizedDescription);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   // [self updateButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
