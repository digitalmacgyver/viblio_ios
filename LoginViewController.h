//
//  LoginViewController.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/15/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LandingViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end
