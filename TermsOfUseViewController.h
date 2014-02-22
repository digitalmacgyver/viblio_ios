//
//  TermsOfUseViewController.h
//  Viblio_v2
//
//  Created by Vinay on 1/24/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashBoardNavController.h"

@interface TermsOfUseViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *wvTerms;
@property (weak, nonatomic) IBOutlet UITextView *termsView;
@property (nonatomic, strong) NSString *text;
@end
