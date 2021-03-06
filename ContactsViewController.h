//
//  ContactsViewController.h
//  Viblio_v2
//
//  Created by Vinay Raj on 18/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsViewController : UIViewController<UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain)NSMutableArray *selectedIndices;
@property (weak, nonatomic) IBOutlet UITableView *contactsList;
@property (weak, nonatomic) IBOutlet UITableView *detailsList;

@property (weak, nonatomic) IBOutlet UIView *vwOverLay;
@property (nonatomic, strong) NSMutableArray *contacts, *loadContacts;

@end
