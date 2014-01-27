//
//  SignUpViewController.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/15/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LandingViewController.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fName;
@property (weak, nonatomic) IBOutlet UITextField *lName;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivacy;
@property (weak, nonatomic) IBOutlet UILabel *lblTermsOfService;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *sinUpActivity;

@end
