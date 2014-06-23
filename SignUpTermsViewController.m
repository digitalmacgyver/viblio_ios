//
//  SignUpTermsViewController.m
//  Viblio_v2
//
//  Created by Vinay Raj on 18/06/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SignUpTermsViewController.h"
#import "DashBoardNavController.h"

@interface SignUpTermsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *vwTerms;

@end

@implementation SignUpTermsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (IBAction)btnBackClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    //[self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.vwTerms.opaque = YES;
    [APPCLIENT fetchTermsAndConditions:^(NSString *terms)
     {
         DLog(@"Log : Terms fetched is - %@", terms);
         [self.vwTerms loadHTMLString:terms baseURL:[NSURL URLWithString:nil]];
     }failure:^(NSError *error)
     {
         DLog(@"Log : Could not fetch terms and conditions");
         [(DashBoardNavController*)self.navigationController popViewControllerAnimated:YES];
     }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"Loaded");
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        NSString *urlString = url.absoluteString;
        DLog(@"Log : The url string is - %@", urlString);
    }
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
