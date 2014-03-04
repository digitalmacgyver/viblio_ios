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

    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationShareTitleView:@"Contacts"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                              [UIButton navigationRightItemWithTarget:self action:@selector(selectContactList) withImage:@"" withTitle:@"Done"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                             [UIButton navigationLeftItemWithTarget:self action:@selector(cancelContactList) withImage:@"" withTitle:@"Cancel" ]];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.selectedIndices = [NSMutableArray new];
    
    if( APPMANAGER.selectedContacts != nil && APPMANAGER.selectedContacts.count > 0 )
    {
        DLog(@"Log : Finding to restore selected indices...");
        for( int i=0; i<APPMANAGER.selectedContacts.count; i++ )
        {
            id selectedContact = APPMANAGER.selectedContacts[i];
            for( int j=0; j < APPMANAGER.contacts.count; j++ )
            {
                id contact = APPMANAGER.contacts[j];
                if( [((NSDictionary*)contact)[@"fname"] isEqualToString:((NSDictionary*)selectedContact)[@"fname"]] &&
                            [((NSDictionary*)contact)[@"lname"] isEqualToString:((NSDictionary*)selectedContact)[@"lname"]] )
                    [self.selectedIndices addObject:@(j)];
            }
            [self.contactsList reloadData];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.selectedIndices removeAllObjects];
    self.selectedIndices = nil;
    
//    if( self.op != nil )
//        [self.op cancel];
}

-(void)selectContactList
{
    DLog(@"Log : Select the contact list");
    DLog(@"Log : Selected contact list is - %@", self.selectedIndices);
    
    if (APPMANAGER.selectedContacts != nil)
    {
        [APPMANAGER.selectedContacts removeAllObjects];
        APPMANAGER.selectedContacts = nil;
    }
    APPMANAGER.selectedContacts = [[NSMutableArray alloc]init];
    
    for( int i=0; i < self.selectedIndices.count; i++ )
    {
        DLog(@"Log : The object to be added is - %@", [APPMANAGER.contacts objectAtIndex:i]);
        [APPMANAGER.selectedContacts addObject:[APPMANAGER.contacts objectAtIndex:i]];
    }
    
    DLog(@"Log : The selected list is - %@", APPMANAGER.selectedContacts);
    
    [self.navigationController popViewControllerAnimated:YES];
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
    
    if( [((NSDictionary*)APPMANAGER.contacts[indexPath.row])[@"fname"] isValid] &&  ((NSDictionary*)APPMANAGER.contacts[indexPath.row])[@"lname"] )
    {
            cell.textLabel.text = [[((NSDictionary*)APPMANAGER.contacts[indexPath.row])[@"fname"] stringByAppendingString:@" "] stringByAppendingString:((NSDictionary*)APPMANAGER.contacts[indexPath.row])[@"lname"]];
    }
    else
    {
        cell.textLabel.text =  [((NSArray*)((NSDictionary*)APPMANAGER.contacts[indexPath.row])[@"email"]) firstObject];
    }

    cell.textLabel.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    DLog(@"Log : Selection detected..");
    
    if( cell.tag )
    {
        cell.imageView.image = nil;
        cell.tag = 0;
        
        for( int i=0; i<self.selectedIndices.count; i++)
        {
            if( [self.selectedIndices[i] isEqual:@(indexPath.row)] )
            {
                DLog(@"Log : Entering in removig the object - %@", self.selectedIndices);
                [self.selectedIndices removeObjectAtIndex:i];
                DLog(@"Log : Entering in removig the object after removal - %@", self.selectedIndices);
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
    
    [self.contactsList reloadData];
}

@end
