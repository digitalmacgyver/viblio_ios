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
    
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationShareTitleView:@"Tell A Friend"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                             [UIButton navigationLeftItemWithTarget:self action:@selector(cancel) withImage:@"" withTitle:@"Cancel" ]];
    
    self.txtVwTellAFriend.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtVwTellAFriend.layer.borderWidth = 1.0;
    self.txtVwTellAFriend.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.txtVwTellAFriend.font = [UIFont fontWithName:@"Avenir-Roman" size:14];
    self.txtVwTellAFriend.text = @"If you join VIBLIO, we can privately share videos together.  Create your free personal account at \nhttps://viblio.com/";
}


-(void)viewDidAppear:(BOOL)animated
{
    DLog(@"Log : The contact list is - %@", APPMANAGER.selectedContacts);
    
    if( APPMANAGER.selectedContacts != nil && APPMANAGER.selectedContacts.count > 0 )
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                                  [UIButton navigationRightItemWithTarget:self action:@selector(tellAFriend) withImage:@"" withTitle:@"Send" ]];
        [self.btnMail setImage:[UIImage imageNamed:@"bttn_mail"] forState:UIControlStateNormal];
        self.btnMail.tag = 1;
    }
    else
    {
        if( self.btnFacebook.tag == 0 )
            self.navigationItem.rightBarButtonItem = nil;
        [self.btnMail setImage:[UIImage imageNamed:@"bttn_mail_normal"] forState:UIControlStateNormal];
        self.btnMail.tag = 0;
    }
}

-(void)sendAppRequestTOAFriendOnFB : (NSString*)messgae
{
    NSMutableDictionary* params = nil;
    FBSession *session;
    if( [[FBSession activeSession] isOpen] )
    {
        session = [FBSession activeSession];
    }
    else
    {
        session = nil;
    }
    
    DLog(@"Log : The message obtained for telel a friend is - %@", messgae);
    // Display the requests dialog
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:session
     message:messgae
     title:nil
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 }
                 else {
                     // User clicked the Send button
                                 [ViblioHelper displayAlertWithTitle:@"Success" messageBody:@"Friend has been successfully invited!" viewController:self cancelBtnTitle:@"OK"];
                     
                    // [ViblioHelper displayAlertWithTitle:@"Success" messageBody:@"Friend has been successfully invited!" viewController:self cancelBtnTitle:@"OK"];
                     //NSLog(@"Log : The ids of the user to whom request has been sent is - %@", fbId);
                 }
             }
         }
     }];
}

- (NSDictionary*)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    return params;
}

-(void)tellAFriend
{
    if( self.btnFacebook.tag )
    {
        [self sendAppRequestTOAFriendOnFB:self.txtVwTellAFriend.text];
    }
    
    if( self.btnMail.tag )
    {
        DLog(@"Log : Tell A Friend via Mail..");
        
        self.op = [APPCLIENT tellAFriendAboutViblioWithMessage:self.txtVwTellAFriend.text success:^(BOOL hasBeenTold)
           {
               
           }failure:^(NSError *error)
           {
               
           }];
        
        if( !self.btnFacebook.tag )
            [ViblioHelper displayAlertWithTitle:@"Success" messageBody:@"Friend has been successfully invited!" viewController:self cancelBtnTitle:@"OK"];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if( self.txtVwTellAFriend.tag )
    {
        CGRect txtVwFrame = self.txtVwTellAFriend.frame;
        txtVwFrame.size.height += 215;
        self.txtVwTellAFriend.frame = txtVwFrame;
        
        CGRect vwSharingFrame = self.vwSharingOptions.frame;
        vwSharingFrame.origin.y += 215;
        self.vwSharingOptions.frame = vwSharingFrame;
        
        [self.txtVwTellAFriend resignFirstResponder];
    }
}

-(void)cancel
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.op cancel];
    //[self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [APPMANAGER.selectedContacts removeAllObjects];
    APPMANAGER.selectedContacts = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)MailSharingClicked : (id)sender
{
    DLog(@" Log : Mail Clicked - 2");
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            ABAddressBookRef addressBook = ABAddressBookCreate( );
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        DLog(@" Log : Mail Clicked - 3");
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        if( APPMANAGER.contacts != nil )
        {
            [APPMANAGER.contacts removeAllObjects];
            APPMANAGER.contacts = nil;
        }
        
        DLog(@" Log : Mail Clicked - 4 - count - %ld", numberOfPeople);
        APPMANAGER.contacts = [NSMutableArray new];
        
        for(int i = 0; i < numberOfPeople; i++) {
            
            //DLog(@"Log : In processing contact - %d", i);
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            
            ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSMutableArray *emailIds = [NSMutableArray new];
            
            DLog(@" Log : Mail Clicked 6 - %@", email);
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(email); i++) {
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(email, i);
                DLog(@" Log : Mail Clicked 7 - %@", phoneNumber);
                [emailIds addObject:phoneNumber];
            }
            
            if( emailIds.count > 0 )
            {
                DLog(@" Log : Mail Clicked 8 - %@ - %@ - %@", emailIds, firstName, lastName);
                
                if( [firstName isValid] && [lastName isValid] )
                    [APPMANAGER.contacts addObject:@{ @"fname" : firstName, @"lname" : lastName, @"email" : emailIds}];
                else
                    [APPMANAGER.contacts addObject:@{ @"email" : emailIds}];
                
            }
            
            // DLog(@" Log : Mail Clicked 9 - %@", APPMANAGER.contacts);
        }
        
        DLog(@" Log : Mail Clicked - 5");
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"contacts")] animated:YES];
    }
    else {
        // Send an alert telling user to change privacy setting in settings app
        
        [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Viblio could not access your contacts. Please enable access in settings" viewController:nil cancelBtnTitle:@"OK"];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)facebookClicked:(id)sender {
    
    if( self.btnFacebook.tag )
    {
        [self.btnFacebook setImage:[UIImage imageNamed:@"bttn_facebook_normal"] forState:UIControlStateNormal];
        self.btnFacebook.tag = 0;
        
        if( self.btnMail.tag == 0 )
            self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        [self.btnFacebook setImage:[UIImage imageNamed:@"bttn_facebook"] forState:UIControlStateNormal];
        self.btnFacebook.tag = 1;
        
        if( self.navigationItem.rightBarButtonItem == nil )
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                                      [UIButton navigationRightItemWithTarget:self action:@selector(tellAFriend) withImage:@"" withTitle:@"Send" ]];
    }
    
}

- (IBAction)mailClicked:(id)sender {
    
    [self.btnMail setImage:[UIImage imageNamed:@"bttn_mail"] forState:UIControlStateNormal];
    [self MailSharingClicked:self];
    
}


#pragma textview delegates

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if( [textView.text isEqualToString:@"Type your message here"] )
        textView.text = @"";
    
    CGRect txtVwFrame = self.txtVwTellAFriend.frame;
    txtVwFrame.size.height -= 215;
    self.txtVwTellAFriend.frame = txtVwFrame;
    self.txtVwTellAFriend.tag = 1;
    
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
