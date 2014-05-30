//
//  ContactsViewController.m
//  Viblio_v2
//
//  Created by Vinay Raj on 18/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ContactsViewController.h"
#import "contactsCell.h"

@interface ContactsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIView *vwNewEmail;
@property (weak, nonatomic) IBOutlet UIView *detailsSelection;
@property (nonatomic, assign) int selectedIndex;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
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

    [self.detailsSelection.layer setCornerRadius:5];
    self.detailsSelection.clipsToBounds = YES;
   // self.detailsSelection.layer.borderColor = [[UIColor lightGrayColor] CGColor];
   // self.detailsSelection.layer.borderWidth = 1;
    
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationShareTitleView:@"Contacts"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                              [UIButton navigationRightItemWithTarget:self action:@selector(selectContactList) withImage:@"" withTitle:@"Done"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                             [UIButton navigationLeftItemWithTarget:self action:@selector(cancelContactList) withImage:@"" withTitle:@"Cancel" ]];
    
    self.selectedIndex = -1;
    
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


- (IBAction)addContactEmail:(id)sender {
    
    // Check whether the email address entered is valid
    
    if ([ViblioHelper vbl_isValidEmail:self.txtEmail.text])
    {
        DLog(@"Log : Valid email address....");
        
        NSMutableDictionary *contact = [@{ @"email" : @[self.txtEmail.text],
                                   @"isSelected" : @(YES),
                                           @"selectedEmailIndexes" : @[@(0)]
                                 } mutableCopy];
        
//        NSMutableArray *selectedIndexes = contact[@"selectedEmailIndexes"];
//        [selectedIndexes addObject:@(0)];
//        [contact setValue:selectedIndexes forKey:@"selectedEmailIndexes"];
        
        [APPMANAGER.selectedContacts addObject:contact];
        [self.txtEmail resignFirstResponder];
        [self.contactsList reloadData];
        
        [APPMANAGER.loadContacts removeAllObjects];
        APPMANAGER.loadContacts = nil;
        
        APPMANAGER.loadContacts = [(NSMutableArray*)[APPMANAGER.selectedContacts arrayByAddingObjectsFromArray:APPMANAGER.tempContacts] mutableCopy];
        self.txtEmail.text = nil;
        [self.contactsList reloadData];
    }
    else
        [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"I don't recognize that email format. Wanna try agian ?" viewController:nil cancelBtnTitle:@"Ok"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


-(void)viewDidAppear:(BOOL)animated
{
    DLog(@"Log : Going into this - 1");
    if( APPMANAGER.contacts != nil && APPMANAGER.contacts.count > 0 )
    {
        DLog(@"Log : Going into this");
        [self.contactsList reloadData];
        [self.detailsSelection setHidden:YES];
    }
    
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
    if( tableView == self.contactsList )
    {
        return APPMANAGER.loadContacts.count;
    }
    else
    {
        DLog(@"Log : Coming in not contact list");
        if( (APPMANAGER.loadContacts != nil && APPMANAGER.loadContacts.count > 0) && self.selectedIndex != -1 )
        {
            NSMutableDictionary *contact = APPMANAGER.loadContacts[self.selectedIndex];
            return ((NSArray*)contact[@"email"]).count;
        }
        else
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.contactsList )
    {
        return 64;
    }
    else
    {
        return 44;
    }
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if( tableView == self.contactsList )
    {
        return self.vwNewEmail.frame.size.height;
    }
    else
    {
        return 0;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if( tableView == self.contactsList )
    {
         return self.vwNewEmail;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Log : Cell creation");
    NSString *cellIdentifier = @"ContactsCell";
    
    contactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if( APPMANAGER.loadContacts != nil && APPMANAGER.loadContacts.count > 0 )
    {
        DLog(@"Log : Loadi Contacts is not nil");
        if( tableView == self.contactsList )
        {
            DLog(@"Log : in contacts list........");
            NSMutableDictionary *contact = APPMANAGER.loadContacts[indexPath.row];
            
            if( contact[@"isSelected"] != nil && ((NSNumber*)contact[@"isSelected"]).boolValue  )
                cell.selectedImage.image = [UIImage imageNamed:@"selected"];
            else
                cell.selectedImage.image = nil;
            
            
            if( [contact[@"fname"] isValid] || [contact[@"lname"] isValid] )
            {
                cell.lblName.text = [contact[@"fname"] stringByAppendingString:@" "];
                cell.lblName.text = [cell.lblName.text stringByAppendingString:contact[@"lname"]];
                
                CGRect lblNameframe = cell.lblName.frame;
                lblNameframe.size.height = 26;
                cell.lblName.frame = lblNameframe;
                
                if( ((NSArray*)contact[@"email"]).count > 1 )
                {
                    cell.lblEmail.text = [NSString stringWithFormat:@"( %@ and %d more )",[contact[@"email"] firstObject], ((NSArray*)contact[@"email"]).count -1 ];
                }
                else
                    cell.lblEmail.text = [NSString stringWithFormat:@"( %@ )", [contact[@"email"] firstObject]];
                
            }
            else
            {
                CGRect lblNameframe = cell.lblName.frame;
                lblNameframe.size.height = 50;
                cell.lblName.frame = lblNameframe;
                
                cell.lblName.text =  [contact[@"email"] firstObject];
                cell.lblEmail.text = nil;
            }
        }
        else
        {
            NSMutableDictionary *contact = APPMANAGER.loadContacts[self.selectedIndex];
            
            DLog(@"Log : The contact is - %@", contact);
            DLog(@"Log : The selected index is - %d", self.selectedIndex);
            
            if( contact[@"isSelected"] != nil && ((NSNumber*)contact[@"isSelected"]).boolValue  )
                cell.selectedImage.image = [UIImage imageNamed:@"selected"];
            else
                cell.selectedImage.image = nil;
            
            if( [self isIndexSelected:indexPath.row forContact:contact] )
            {
                cell.selectedImage.image = [UIImage imageNamed:@"selected"];
            }
            else
            {
                cell.selectedImage.image = nil;
            }
            
            cell.lblName.text =  [contact[@"email"] objectAtIndex:indexPath.row];
        }
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(BOOL)isIndexSelected : (int)index forContact : (NSMutableDictionary*)contact
{
    NSMutableArray *selectedIndices = contact[@"selectedEmailIndexes"];
    for( int i=0 ; i < selectedIndices.count; i++ )
    {
        if( ((NSNumber*)selectedIndices[i]).intValue == index )
        {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.contactsList )
    {
        NSMutableDictionary *contact =  [(NSMutableDictionary*)APPMANAGER.loadContacts[indexPath.row] mutableCopy];
        if( contact[@"isSelected"] != nil && ((NSNumber*)contact[@"isSelected"]).boolValue )
        {
            DLog(@"LOg : ------------------*******************************");
            [contact setValue:@(NO) forKey:@"isSelected"];
            [contact setValue:nil forKey:@"selectedEmailIndexes"];
            [self.btnDone setHidden:YES];
            
            [APPMANAGER.selectedContacts removeObjectAtIndex:indexPath.row];
            [APPMANAGER.tempContacts addObject:contact];
            
            APPMANAGER.tempContacts = [[ViblioHelper getSortedArrayFromArray:APPMANAGER.tempContacts] mutableCopy];
            [self.contactsList reloadData];
        }
        else
        {
            if( ((NSArray*)contact[@"email"]).count > 1 )
            {
                [self.detailsSelection setHidden:NO];
                [self.vwOverLay setHidden:NO];
                self.selectedIndex = indexPath.row;
                [self.detailsList reloadData];
            }
            else
            {
                DLog(@"Log : ___________________________________________________");
                [contact setValue:@(YES) forKey:@"isSelected"];
                
                NSMutableArray *selectedIndexes;
                if( contact[@"selectedEmailIndexes"] != nil )
                {
                   selectedIndexes = contact[@"selectedEmailIndexes"];
                }
                else
                {
                    selectedIndexes = [[NSMutableArray alloc]init];
                }
                
                [selectedIndexes addObject:@(0)];
                [contact setValue:selectedIndexes forKey:@"selectedEmailIndexes"];
                
                [APPMANAGER.tempContacts removeObjectAtIndex:(indexPath.row-APPMANAGER.selectedContacts.count)];
                [APPMANAGER.selectedContacts addObject:contact];
                [self.contactsList reloadData];
            }
        }
        
        [APPMANAGER.loadContacts removeAllObjects];
        APPMANAGER.loadContacts = nil;
        
        APPMANAGER.loadContacts = [(NSMutableArray*)[APPMANAGER.selectedContacts arrayByAddingObjectsFromArray:APPMANAGER.tempContacts] mutableCopy];
    }
    else
    {
        NSMutableDictionary * contact = [(NSMutableDictionary*)APPMANAGER.loadContacts[self.selectedIndex] mutableCopy];
        
        if( contact[@"selectedEmailIndexes"] == nil )
        {
            DLog(@"Log : adding for the first time ---");
            NSMutableArray *selectedIndexes = [[NSMutableArray alloc]init];
            [selectedIndexes addObject:@(indexPath.row)];
            [contact setValue:selectedIndexes forKey:@"selectedEmailIndexes"];
            [self.btnDone setHidden:NO];
        }
        else
        {
            DLog(@"Log : Already the index exists ---");
            if( ![self isIndexSelected:indexPath.row forContact:contact] )
            {
                NSMutableArray *selectedIndexes = contact[@"selectedEmailIndexes"];
                [selectedIndexes addObject:@(indexPath.row)];
                [contact setValue:selectedIndexes forKey:@"selectedEmailIndexes"];
                [self.btnDone setHidden:NO];
            }
            else
            {
                NSMutableArray *selectedIndexes = contact[@"selectedEmailIndexes"];
                for(int i=0; i<selectedIndexes.count; i++)
                {
                    if( ((NSNumber*)selectedIndexes[i]).intValue == indexPath.row )
                    {
                        [selectedIndexes removeObjectAtIndex:i];
                    }
                }
                
                [contact setValue:selectedIndexes forKey:@"selectedEmailIndexes"];
                
                if( selectedIndexes.count == 0 )
                {
                    [self.btnDone setHidden:YES];
                }
            }
        }
        
        [APPMANAGER.loadContacts removeObjectAtIndex:self.selectedIndex];
        [APPMANAGER.loadContacts insertObject:contact atIndex:self.selectedIndex];
        [self.detailsList reloadData];
    }
}


- (IBAction)ClickOfDone:(id)sender {
    
    [self.detailsSelection setHidden:YES];
    [self.vwOverLay setHidden:YES];
    
    NSMutableDictionary * contact = [(NSMutableDictionary*)APPMANAGER.loadContacts[self.selectedIndex] mutableCopy];
    [contact setValue:@(YES) forKey:@"isSelected"];
    [APPMANAGER.tempContacts removeObjectAtIndex:(self.selectedIndex-APPMANAGER.selectedContacts.count)];
    [APPMANAGER.selectedContacts addObject:contact];
    
    [APPMANAGER.loadContacts removeAllObjects];
    APPMANAGER.loadContacts = nil;
    
    APPMANAGER.loadContacts = [(NSMutableArray*)[APPMANAGER.selectedContacts arrayByAddingObjectsFromArray:APPMANAGER.tempContacts] mutableCopy];
    
    [self.contactsList reloadData];
}

- (IBAction)ClickOfCancel:(id)sender {
    
    [self.detailsSelection setHidden:YES];
    [self.vwOverLay setHidden:YES];
    
    NSMutableDictionary * contact = [(NSMutableDictionary*)APPMANAGER.loadContacts[self.selectedIndex] mutableCopy];
    [contact setValue:nil forKey:@"selectedEmailIndexes"];
    [APPMANAGER.loadContacts removeObjectAtIndex:self.selectedIndex];
    [APPMANAGER.loadContacts insertObject:contact atIndex:self.selectedIndex];
    [self.contactsList reloadData];
}




@end
