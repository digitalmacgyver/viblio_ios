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
    
    if( APPMANAGER.loadContacts == nil )
    {
        DLog(@"Log : Load contacts is nil ........");
        APPMANAGER.loadContacts = [APPMANAGER.contacts mutableCopy];
    }
    
    if( APPMANAGER.tempContacts == nil )
    {
        DLog(@"Log : self contacts is nil ........");
        APPMANAGER.tempContacts = [APPMANAGER.contacts mutableCopy];
    }
    
    if( APPMANAGER.selectedContacts == nil )
    {
        DLog(@"Log : self contacts is nil ........");
        APPMANAGER.selectedContacts = [NSMutableArray new];
    }

}

-(void)viewDidAppear:(BOOL)animated
{
    [self.contactsList reloadData];
    
//    self.selectedIndices = [NSMutableArray new];
//    
//    if( APPMANAGER.selectedContacts != nil && APPMANAGER.selectedContacts.count > 0 )
//    {
//        DLog(@"Log : Finding to restore selected indices...");
//        for( int i=0; i<APPMANAGER.selectedContacts.count; i++ )
//        {
//            id selectedContact = APPMANAGER.selectedContacts[i];
//            for( int j=0; j < APPMANAGER.contacts.count; j++ )
//            {
//                id contact = APPMANAGER.contacts[j];
//                if( [((NSDictionary*)contact)[@"fname"] isEqualToString:((NSDictionary*)selectedContact)[@"fname"]] &&
//                            [((NSDictionary*)contact)[@"lname"] isEqualToString:((NSDictionary*)selectedContact)[@"lname"]] )
//                    [self.selectedIndices addObject:@(j)];
//            }
//            [self.contactsList reloadData];
//        }
//    }
//    else if ( APPMANAGER.selectedContacts == nil )
//        APPMANAGER.selectedContacts = [NSMutableArray new];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [self.selectedIndices removeAllObjects];
//    self.selectedIndices = nil;
}

-(void)selectContactList
{
    DLog(@"Log : Select the contact list");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancelContactList
{
    DLog(@"Log : Cancel the contact list");
    
    [APPMANAGER.selectedContacts removeAllObjects];
    APPMANAGER.selectedContacts = nil;
    
    [APPMANAGER.tempContacts removeAllObjects];
    APPMANAGER.tempContacts = nil;
    
    [APPMANAGER.loadContacts removeAllObjects];
    APPMANAGER.loadContacts = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
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
    NSMutableDictionary *contact = APPMANAGER.loadContacts[indexPath.row];
    
    if( contact[@"isSelected"] != nil && ((NSNumber*)contact[@"isSelected"]).boolValue  )
        cell.imageView.image = [UIImage imageNamed:@"selected"];
    else
        cell.imageView.image = nil;
    
    if( [contact[@"fname"] isValid] && [contact[@"lname"] isValid] )
        cell.textLabel.text = [[contact[@"fname"] stringByAppendingString:@" "] stringByAppendingString:contact[@"lname"]];
    else
        cell.textLabel.text =  [contact[@"email"] firstObject];

    cell.textLabel.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"");
    NSMutableDictionary *contact =  [(NSMutableDictionary*)APPMANAGER.loadContacts[indexPath.row] mutableCopy];
    if( contact[@"isSelected"] != nil && ((NSNumber*)contact[@"isSelected"]).boolValue )
    {
        [contact setValue:@(NO) forKey:@"isSelected"];
        [APPMANAGER.selectedContacts removeObjectAtIndex:indexPath.row];
        [APPMANAGER.tempContacts addObject:contact];
        
        APPMANAGER.tempContacts = [self getSortedArrayFromArray:APPMANAGER.tempContacts] ;
    }
    else
    {
        [contact setValue:@(YES) forKey:@"isSelected"];
        [APPMANAGER.tempContacts removeObjectAtIndex:(indexPath.row-APPMANAGER.selectedContacts.count)];
        [APPMANAGER.selectedContacts addObject:contact];
    }
    
    [APPMANAGER.loadContacts removeAllObjects];
    APPMANAGER.loadContacts = nil;
    
    APPMANAGER.loadContacts = [(NSMutableArray*)[APPMANAGER.selectedContacts arrayByAddingObjectsFromArray:APPMANAGER.tempContacts] mutableCopy];
    [self.contactsList reloadData];
}


-(NSMutableArray*)getSortedArrayFromArray : (NSMutableArray*)contacts
{
    NSArray *sortedArray;
    sortedArray = [contacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *Obj1firstName = ((NSDictionary*)a)[@"fname"];
        NSString *Obj2firstName = ((NSDictionary*)b)[@"fname"];
        return [Obj1firstName compare:Obj2firstName];
    }];
    
    DLog(@"Log : Sote list is - %@", sortedArray);
    return [sortedArray mutableCopy];
}


@end
