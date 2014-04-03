//
//  ShareVideoViewController.m
//  Viblio_v2
//
//  Created by Vinay Raj on 25/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ShareVideoViewController.h"

#define TitleText @"Title"

@interface ShareVideoViewController ()

@end

@implementation ShareVideoViewController

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
    
    //self.txtVwBody.editable = NO;
    self.txtFiledTitle.text = TitleText;
    self.txtVwBody.text = @"Check out my new video on Viblio ! \n https://staging.viblio.com/";
    self.txtVwBody.dataDetectorTypes = UIDataDetectorTypeLink;
    
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationShareTitleView:@"Share with VIBLIO"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIButton navigationLeftItemWithTarget:self action:@selector(cancelSharing) withImage:@"" withTitle:@"Cancel"]];

    
    self.txtFiledTitle.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.txtFiledTitle.layer.borderWidth = 1.0f;
    self.txtFiledTitle.font = [UIFont fontWithName:@"Avenir-Light" size:14];
    
    self.txtSubject.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.txtSubject.layer.borderWidth = 1.0f;
    self.txtSubject.font = [UIFont fontWithName:@"Avenir-Roman" size:14];
    self.txtSubject.text = [NSString stringWithFormat:@"%@ has shared a video with you", APPMANAGER.user.userName];
    
    self.vwBody.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.vwBody.layer.borderWidth = 1.0f;
    self.txtVwBody.font = [UIFont fontWithName:@"Avenir-Roman" size:14];
    
    self.vwToList.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.vwToList.layer.borderWidth = 1.0f;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [self.emailList reloadData];
    self.thumbImgVw.image = APPMANAGER.posterImageForVideoSharing;
    //[self.thumbImgVw setImageWithURL:[NSURL URLWithString:((SharedVideos*)APPMANAGER.videoToBeShared).posterURL]];
    
    DLog(@"Log : The contact list is - %@", APPMANAGER.selectedContacts);
    
    if( APPMANAGER.selectedContacts != nil && APPMANAGER.selectedContacts.count > 0 )
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                                  [UIButton navigationRightItemWithTarget:self action:@selector(send) withImage:@"" withTitle:@"Send" ]];
        [self.btnMail setImage:[UIImage imageNamed:@"bttn_mail"] forState:UIControlStateNormal];
        self.btnMail.tag = 1;
        
        NSMutableDictionary *contact = [APPMANAGER.selectedContacts firstObject];
        
        if( APPMANAGER.selectedContacts.count > 1 )
        {
            if( APPMANAGER.selectedContacts.count > 2 )
                    self.lblToList.text = [NSString stringWithFormat:@"%@ and %d others",[[contact[@"fname"] stringByAppendingString:@" "] stringByAppendingString:contact[@"lname"]], APPMANAGER.selectedContacts.count-1 ];
            else
                    self.lblToList.text = [NSString stringWithFormat:@"%@ and %d other",[[contact[@"fname"] stringByAppendingString:@" "] stringByAppendingString:contact[@"lname"]], APPMANAGER.selectedContacts.count-1 ];
        }
        else
            self.lblToList.text = [[contact[@"fname"] stringByAppendingString:@" "] stringByAppendingString:contact[@"lname"]];

        contact = nil;
        
    }
    else
    {
        self.lblToList.text = @"Select People";
        if( self.btnFB.tag == 0 )
            self.navigationItem.rightBarButtonItem = nil;
        //[self.btnFB setImage:[UIImage imageNamed:@"bttn_facebook_normal"] forState:UIControlStateNormal];
        [self.btnMail setImage:[UIImage imageNamed:@"bttn_mail_normal"] forState:UIControlStateNormal];
        self.btnMail.tag = 0;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if( self.txtVwBody.tag )
    {
        DLog(@"Log : Entering in if condition...");
        
            self.txtVwBody.tag = 0;
            
            CGRect txtVwFrame = self.vwBody.frame;
            txtVwFrame.size.height += 215;
            self.vwBody.frame = txtVwFrame;
            
            CGRect txtBodyframe = self.txtVwBody.frame;
            txtBodyframe.origin.y += 66;
            txtBodyframe.size.height -= 66;
            self.txtVwBody.frame = txtBodyframe;
            
            CGRect shareVwFrame = self.vsSharingOpitons.frame;
            shareVwFrame.origin.y += 215;
            self.vsSharingOpitons.frame = shareVwFrame;
        
        [self.thumbImgVw setHidden:NO];
        [self.txtVwBody resignFirstResponder];
    }
}

-(void)send
{
    

    NSString *fileId ;
    
    if( self.btnFB.tag )
    {
        DLog(@"Log : Has to be shared via FB too...");
        [self likeButtonPressed:self];
    }
    
    if( self.btnMail.tag )
    {
        DLog(@"Log : Has to be shared via Mail too...");
        if( [APPMANAGER.VideoToBeShared isKindOfClass:[VideoCell class] ] )
            fileId = ((VideoCell*)APPMANAGER.VideoToBeShared).video.uuid;
        else
            fileId = ((listTableCell*)APPMANAGER.VideoToBeShared).video.uuid;
        
        self.op = [APPCLIENT sharingToUsersWithSubject:self.txtSubject.text  title:self.txtFiledTitle.text body:self.txtVwBody.text fileId:fileId success:^(BOOL sharingSuccess)
                   {
                       DLog(@"Log : Success callback...");
                   }failure:^(NSError *error)
                   {
                       DLog(@"Log : Error - %@", error);
                   }];
        
        if( !self.btnFB.tag )
        {
            [ViblioHelper displayAlertWithTitle:@"Success" messageBody:@"Video has been successfully shared!" viewController:self cancelBtnTitle:@"OK"];
        }
    }

        }



-(void)cancelSharing
{
    //[self.slidingViewController anchorTopViewTo:ECRight];
    
    APPMANAGER.posterImageForVideoSharing = nil;
    APPMANAGER.videoToBeShared = nil;
    
    [APPMANAGER.selectedContacts removeAllObjects];
    APPMANAGER.selectedContacts = nil;
    
    [self.op cancel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)titleEditingStarted:(id)sender {
    
    if( APPMANAGER.selectedContacts != nil && APPMANAGER.selectedContacts.count > 0 )
        [self.emailList setHidden:NO];
    
    DLog(@"Log : title editing started...");
    self.txtFiledTitle.text = nil;
    self.txtFiledTitle.font = [UIFont fontWithName:@"Avenir-Roman" size:14];
    
}


- (IBAction)titleEditingDidEnd:(id)sender {
    
    [self.emailList setHidden:YES];
    
    DLog(@"Log : title editing end");
    if( ![self.txtFiledTitle.text isValid] )
    {
        self.txtFiledTitle.text = TitleText;
        self.txtFiledTitle.font = [UIFont fontWithName:@"Avenir-Light" size:14];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma textview delegates

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if( textView == self.txtVwBody )
    {
        self.txtVwBody.tag = 1;
        [self.thumbImgVw setHidden:YES];
        [self.txtFiledTitle setHidden:YES];
        
        CGRect txtVwFrame = self.vwBody.frame;
        txtVwFrame.size.height -= 215;
        self.vwBody.frame = txtVwFrame;
        
        
        CGRect txtBodyframe = self.txtVwBody.frame;
        txtBodyframe.origin.y -= 66;
        txtBodyframe.size.height += 66;
        self.txtVwBody.frame = txtBodyframe;
        
        
        CGRect shareVwFrame = self.vsSharingOpitons.frame;
        shareVwFrame.origin.y -= 215;
        self.vsSharingOpitons.frame = shareVwFrame;
    }
}

- (IBAction)fbCLicked:(id)sender {

    DLog(@"Log : Facebook clicked");
    
    if( self.btnFB.tag )
    {
        [self.btnFB setImage:[UIImage imageNamed:@"bttn_facebook_normal"] forState:UIControlStateNormal];
        self.btnFB.tag = 0;
        
        if( self.btnMail.tag == 0 )
            self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        [self.btnFB setImage:[UIImage imageNamed:@"bttn_facebook"] forState:UIControlStateNormal];
        self.btnFB.tag = 1;
        
        if( self.navigationItem.rightBarButtonItem == nil )
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                                      [UIButton navigationRightItemWithTarget:self action:@selector(send) withImage:@"" withTitle:@"Send" ]];
    }
}

-(void)postSharingVideoToFBTimeline
{
    [self likeButtonPressed:self];
}


-(IBAction)likeButtonPressed:(id)sender
{
    NSLog(@"likeButtonPressed: called");
    // FBSample logic
    // Check to see whether we have already opened a session.
    if (FBSession.activeSession.isOpen)
    {
        // login is integrated with the send button -- so if open, we send
        [self postOnWall];
    }
    else
    {
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"publish_stream", nil] defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      
                                          // if login fails for any reason, we alert
                                          if (error)
                                          {
                                              NSLog(@"    login failed");
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                              message:error.localizedDescription
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil];
                                              [alert show];
                                              // if otherwise we check to see if the session is open, an alternative to
                                              // to the FB_ISSESSIONOPENWITHSTATE helper-macro would be to check the isOpen
                                              // property of the session object; the macros are useful, however, for more
                                              // detailed state checking for FBSession objects
                                          }
                                          else if (FB_ISSESSIONOPENWITHSTATE(status))
                                          {
                                              NSLog(@"    sending post on wall request...");
                                              // send our requests if we successfully logged in
                                              [self postOnWall];
                                          }
                                      
                                      }];
    };
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    APPMANAGER.posterImageForVideoSharing = nil;
    APPMANAGER.videoToBeShared = nil;
    
    [APPMANAGER.selectedContacts removeAllObjects];
    APPMANAGER.selectedContacts = nil;

    [self.navigationController popViewControllerAnimated:YES];
}


- (void)postOnWall
{
    NSNumber *testMessageIndex=[[NSNumber alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"testMessageIndex"]==nil)
    {
        testMessageIndex=[NSNumber numberWithInt:100];
    }
    else
    {
        testMessageIndex=[[NSUserDefaults standardUserDefaults] objectForKey:@"testMessageIndex"];
    };
    testMessageIndex=[NSNumber numberWithInt:[testMessageIndex intValue]+1];
    [[NSUserDefaults standardUserDefaults] setObject:testMessageIndex forKey:@"testMessageIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // create the connection object
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    
    // create a handler block to handle the results of the request for fbid's profile
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        // output the results of the request
        [self requestCompleted:connection forFbID:@"me" result:result error:error];
    };
    
    // create the request object, using the fbid as the graph path
    // as an alternative the request* static methods of the FBRequest class could
    // be used to fetch common requests, such as /me and /me/friends
    NSString *messageString=[NSString stringWithFormat:@"Check out my new video on Viblio ! \n https://staging.viblio.com/"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[messageString] forKeys:@[@"message"]];
    
    FBRequest *request=[[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"me/feed" parameters:dict HTTPMethod:@"POST"];
    
    // add the request to the connection object, if more than one request is added
    // the connection object will compose the requests as a batch request; whether or
    // not the request is a batch or a singleton, the handler behavior is the same,
    // allowing the application to be dynamic in regards to whether a single or multiple
    // requests are occuring
    [newConnection addRequest:request completionHandler:handler];
    
    // if there's an outstanding connection, just cancel
    [self.requestConnection cancel];
    
    // keep track of our connection, and start it
    self.requestConnection = newConnection;
    [newConnection start];
}

// FBSample logic
// Report any results.  Invoked once for each request we make.
- (void)requestCompleted:(FBRequestConnection *)connection
                 forFbID:fbID
                  result:(id)result
                   error:(NSError *)error
{
    NSLog(@"request completed");
    
    // not the completion we were looking for...
    if (self.requestConnection &&
        connection != self.requestConnection)
    {
        NSLog(@"    not the completion we are looking for");
        return;
    }
    
    // clean this up, for posterity
    self.requestConnection = nil;
    
    if (error)
    {
        NSLog(@"    error -- %@", error.userInfo);
        NSString *message;
        if( error.userInfo != nil )
        {
           message  = error.userInfo[@"com.facebook.sdk:ParsedJSONResponseKey"][@"body"][@"error"][@"message"];
        }
        else
            message = error.localizedDescription;
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        // error contains details about why the request failed
        [alert show];
    }
    else
    {
        NSLog(@"   ok");
        [ViblioHelper displayAlertWithTitle:@"Success" messageBody:@"Video has been successfully shared!" viewController:self cancelBtnTitle:@"OK"];
    };
}


-(void)fbSessionEsteblish:(NSArray*)permissions :(UIView*)view :(void(^)(NSError*, NSString*))success
{
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      switch (status) {
                                          case FBSessionStateOpen:
                                              [self postSharingVideoToFBTimeline];
                                              break;
                                          case FBSessionStateCreatedOpening:
                                              [[FBSession activeSession] handleDidBecomeActive];
                                              break;
                                          case FBSessionStateClosed:
                                              if (success)
                                                  success(error, nil);
                                              break;
                                          case FBSessionStateClosedLoginFailed:
                                          {
                                              [ViblioHelper displayAlertWithTitle:@"Login" messageBody:@"Facebook Login failed. Could not establish session" viewController:nil cancelBtnTitle:@"OK"];
                                              success(nil, nil);
                                          }
                                              break;
                                          default:
                                              break;
                                      }
                                  }];
}


- (IBAction)mailClicked:(id)sender {

    DLog(@" Log : Mail Clicked ");
    [self.btnMail setImage:[UIImage imageNamed:@"bttn_mail"] forState:UIControlStateNormal];
    DLog(@" Log : Mail Clicked - 1");
    [self MailSharingClicked:sender];
    
    //[ViblioHelper MailSharingClicked:self];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        
        if( textView == self.txtVwBody )
        {
            self.txtVwBody.tag = 0;
            
            CGRect txtVwFrame = self.vwBody.frame;
            txtVwFrame.size.height += 215;
            self.vwBody.frame = txtVwFrame;
            
            CGRect txtBodyframe = self.txtVwBody.frame;
            txtBodyframe.origin.y += 66;
            txtBodyframe.size.height -= 66;
            self.txtVwBody.frame = txtBodyframe;
            
            CGRect shareVwFrame = self.vsSharingOpitons.frame;
            shareVwFrame.origin.y += 215;
            self.vsSharingOpitons.frame = shareVwFrame;
        }
        
        [self.txtFiledTitle setHidden:NO];
        [self.thumbImgVw setHidden:NO];
        [textView resignFirstResponder];
    }
    
    return YES;
}

-(void)MailSharingClicked : (id)sender
{
    //DLog(@" Log : Mail Clicked - 2");
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            ABAddressBookRef addressBook = ABAddressBookCreate( );
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        // DLog(@" Log : Mail Clicked - 3");
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        if( APPMANAGER.contacts != nil )
        {
            [APPMANAGER.contacts removeAllObjects];
            APPMANAGER.contacts = nil;
        }
        
        //DLog(@" Log : Mail Clicked - 4 - count - %ld", numberOfPeople);
        APPMANAGER.contacts = [NSMutableArray new];
        
        for(int i = 0; i < numberOfPeople; i++) {
            
            //DLog(@"Log : In processing contact - %d", i);
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            
            ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSMutableArray *emailIds = [NSMutableArray new];
            
            //DLog(@" Log : Mail Clicked 6 - %@", email);
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(email); i++) {
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(email, i);
                //sDLog(@" Log : Mail Clicked 7 - %@", phoneNumber);
                [emailIds addObject:phoneNumber];
            }

            if( emailIds.count > 0 )
            {
                //DLog(@" Log : Mail Clicked 8 - %@ - %@ - %@", emailIds, firstName, lastName);
                
                if( [firstName isValid] && [lastName isValid] )
                    [APPMANAGER.contacts addObject:@{ @"fname" : firstName, @"lname" : lastName, @"email" : emailIds}];
                else
                    [APPMANAGER.contacts addObject:@{ @"email" : emailIds}];
                
            }
            
           // DLog(@" Log : Mail Clicked 9 - %@", APPMANAGER.contacts);
        }
        
        //DLog(@" Log : Mail Clicked - 5");
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"contacts")] animated:YES];
    }
    else {
        // Send an alert telling user to change privacy setting in settings app
        
        [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Viblio could not access your contacts. Please enable access in settings" viewController:nil cancelBtnTitle:@"OK"];
    }
}


#pragma table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if( APPMANAGER.selectedContacts != nil && APPMANAGER.selectedContacts.count > 0 )
        return APPMANAGER.selectedContacts.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ContactsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // cell.tag = 0;
    
    if( ![self isIndexSelected:@(indexPath.row)] )
    {
        cell.imageView.image = nil;
        cell.tag = 0;
    }
    else
    {
        cell.tag = 1;
        cell.imageView.image = [UIImage imageNamed:@"selected"];
    }
    
    if( [((NSDictionary*)APPMANAGER.selectedContacts[indexPath.row])[@"fname"] isValid] &&  ((NSDictionary*)APPMANAGER.selectedContacts[indexPath.row])[@"lname"] )
    {
        cell.textLabel.text = [[((NSDictionary*)APPMANAGER.selectedContacts[indexPath.row])[@"fname"] stringByAppendingString:@" "] stringByAppendingString:((NSDictionary*)APPMANAGER.selectedContacts[indexPath.row])[@"lname"]];
    }
    else
    {
        cell.textLabel.text =  [((NSArray*)((NSDictionary*)APPMANAGER.selectedContacts[indexPath.row])[@"email"]) firstObject];
    }
    
    cell.textLabel.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (IBAction)naviagteToContacts:(id)sender {
    
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"contacts")] animated:YES];
}

-(BOOL)isIndexSelected : (NSNumber*)currentIndex
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    DLog(@"Log : Selection detected..");

    [APPMANAGER.selectedContacts removeObjectAtIndex:indexPath.row];
    
    if( APPMANAGER.selectedContacts.count == 0 )
    {
        if( self.btnFB.tag == 0 )
            self.navigationItem.rightBarButtonItem = nil;
        
        [self.btnMail setImage:[UIImage imageNamed:@"bttn_mail_normal"] forState:UIControlStateNormal];
        self.btnMail.tag = 0;
    }

    [self.emailList reloadData];
}

@end
