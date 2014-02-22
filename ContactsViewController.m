//
//  ContactsViewController.m
//  Viblio_v2
//
//  Created by Vinay Raj on 18/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ContactsViewController.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController

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
    
    DLog(@"Log : View has been loaded");
    
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationTitleView]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                              [UIButton navigationItemWithTarget:self action:@selector(selectContactList) withImage:@"" withTitle:@"Done"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                             [UIButton navigationItemWithTarget:self action:@selector(cancelContactList) withImage:@"" withTitle:@"Cancel"]];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.selectedIndices = [NSMutableArray new];
}

-(void)viewWillDisappear:(BOOL)animated
{
    DLog(@"Log : Cancelling requests..");
    [self.selectedIndices removeAllObjects];
    self.selectedIndices = nil;
    
    if( self.op != nil )
    {
        [self.op cancel];
    }
//    [APPCLIENT.operationQueue cancelAllOperations];
//    NSString *emailList = [APPMANAGER.contacts componentsJoinedByString:@","]; //[[NSString alloc]init];
//    //emailList = [emailList str];
////    if( APPMANAGER.contacts != nil && APPMANAGER.contacts.count > 0 )
////    {
//        NSDictionary *queryParams = @{
//                                      @"mid" : APPMANAGER.video.uuid,
//                                      @"subject" : @"",
//                                      @"body" : @"",
//                                      @"list" : emailList
//                                      };
//        
//        NSString *path = [NSString stringWithFormat:@"/services/mediafile/add_share?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
//    [APPCLIENT cancelAllHTTPOperationsWithMethod:@"POST" path:path];
}

-(void)selectContactList
{
    DLog(@"Log : Select the contact list");
    
    self.op = [APPCLIENT sharingToUsersWithSubject:@"" body:@"" fileId:APPMANAGER.video.uuid success:^(BOOL sharingSuccess)
    {
        DLog(@"Log : Success callback...");
        [ViblioHelper displayAlertWithTitle:@"Success" messageBody:@"Video has been successfully shared!" viewController:self cancelBtnTitle:@"OK"];
    }failure:^(NSError *error)
    {
        DLog(@"Log : Error - %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Error while sharing the video. Do you want to try again ?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Try Again", nil];
        [alert show];
        alert = nil;
    }];
}

-(void)cancelContactList
{
    DLog(@"Log : Cancel the contact list");
    [self.navigationController popViewControllerAnimated:YES];
   // [[NSNotificationCenter defaultCenter] postNotificationName:removeContactsScreen object:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 )
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self selectContactList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return APPMANAGER.contacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(IS_IPHONE_5)
        return 50;
    else
        return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ContactsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if( ![self isIndexSelected:@(indexPath.row)] )
        cell.imageView.image = nil;
    else
        cell.imageView.image = [UIImage imageNamed:@"selected"];
    cell.textLabel.text = [[((NSDictionary*)APPMANAGER.contacts[indexPath.row])[@"fname"] stringByAppendingString:@" "] stringByAppendingString:((NSDictionary*)APPMANAGER.contacts[indexPath.row])[@"lname"]];
    cell.textLabel.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    cell.textLabel.textColor = [UIColor grayColor];
    return cell;
}

-(BOOL)isIndexSelected : (NSNumber*)currentIndex
{
    for( NSNumber *index in self.selectedIndices )
    {
        if( [index isEqual:currentIndex] )
            return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if( cell.tag )
    {
        cell.imageView.image = nil;
        cell.tag = 0;
        
        for( int i=0; i<self.selectedIndices.count; i++)
        {
            if( [self.selectedIndices[i] isEqual:@(indexPath.row)] )
            {
                [self.selectedIndices removeObjectAtIndex:i];
                break;
            }
        }
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"selected"];
        cell.tag = 1;
        [self.selectedIndices addObject:@(indexPath.row)];
    }
}

@end
