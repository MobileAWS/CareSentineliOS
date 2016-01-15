//
//  ContactViewController.m
//  CareSentineliOS
//
//  Created by Andres Prada on 12/15/15.
//  Copyright © 2015 MobileAWS. All rights reserved.
//

#import "SmsViewController.h"
#import <AddressBook/AddressBook.h>
#import "UIResources.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "ContactDao.h"
#import "DatabaseManager.h"
#import "LNNetworkManager.h"

@interface SmsViewController ()

@end

@implementation SmsViewController {
    NSArray *tableData;
    UITextField *newName;
    UITextField *newNumber;
     __weak AppDelegate *application;
    UIBarButtonItem *leftButton;
    UIBarButtonItem *backButton;
    IBOutlet NSLayoutConstraint *loginButtonWidthContraint;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [AppDelegate checkLogoutWithButton:_logoutButton withConstraint:loginButtonWidthContraint];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    tableData = [ContactDao getAllContactData];
    self.navigationController.navigationBar.barTintColor = baseBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:1 green:1 blue: 1 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self->application = (AppDelegate *)[UIApplication sharedApplication].delegate;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


- (IBAction)showAdressBook:(id)sender {
}

- (IBAction)showDialogBoxOptions:(id)sender
{
    
    if (![LNNetworkManager sessionValid]) {
        [application showLogin:self];
        return;
    }else{
    UIAlertController *addContactDialogBox = [UIAlertController alertControllerWithTitle:@"Add Contact" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [addContactDialogBox addAction:[UIAlertAction
                      actionWithTitle:@"Select Existing Contact"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action)
                      {
                          [self showPicker];
                      }]];
    
    [addContactDialogBox addAction:[UIAlertAction
                      actionWithTitle:@"Add New Contact"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action)
                      {
                          [self showAddContact];
                      }]];
    
    [addContactDialogBox addAction:[UIAlertAction
                      actionWithTitle:@"Cancel"
                      style:UIAlertActionStyleDefault
                      handler:nil]];

    [self presentViewController:addContactDialogBox animated:YES completion:nil];
    }

}
-(void) showAddContact
{
     UIAlertController *addContact = [UIAlertController alertControllerWithTitle:@"Add Contact" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [addContact addAction:[UIAlertAction
                           actionWithTitle:@"Add Contact"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               Contact* newContact = [Contact new];
                               newContact.name = newName.text;
                               newContact.number = newNumber.text;
                               DatabaseManager *manager = [DatabaseManager getSharedIntance];
                               Contact *contact = (Contact*)[manager save:newContact];
                               tableData = [ContactDao getAllContactData];
                               [self.tableView reloadData];
                           }]];
    [addContact addAction:[UIAlertAction
                           actionWithTitle:@"Cancel"
                           style:UIAlertActionStyleDefault
                           handler:nil]];
    
    [addContact addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name";
        newName = textField;
    }];
    [addContact addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Number";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        newNumber = textField;
    }];
    [self presentViewController:addContact animated:YES completion:nil];
}
- (void)showPicker
{
    if([tableData count] < 5){
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentModalViewController:picker animated:YES];
    }else {
        [AppDelegate showAlert:@"Only 5 contact are possible to add." withTitle:@"Alert"];
    }
}
- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    NSLog(@"click Cancel");
    [self dismissModalViewControllerAnimated:YES];
}
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person;
{
     NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
     NSString* lastname =  (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
     NSString* completeName =   [NSString stringWithFormat:@"%@ %@", name, lastname];
    if(![self findContactExist:completeName]){
        NSString* phone = nil;
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumbers) > 0) {
            phone = (__bridge_transfer NSString*)
            ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        } else {
            phone = @"[None]";
        }
        Contact *contactNew;
        contactNew =[Contact new];
        contactNew.name = completeName;
        contactNew.number = phone;
        DatabaseManager *manager = [DatabaseManager getSharedIntance];
        Contact *contacto = (Contact*)[manager save:contactNew];
        tableData = [ContactDao getAllContactData];
        [self.tableView reloadData];
        NSLog(@"get person");
    } else {
        [AppDelegate showAlert:@"This user already exist." withTitle:@"Alert"];
    }
    
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{

    return NO;
}
- (void)displayPerson:(ABRecordRef)person
{
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
   }
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return tableData.count;
}

- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    UIImage *background = nil;
    
    if (rowIndex == 0) {
        background = [UIImage imageNamed:@"cell_top.png"];
    } else if (rowIndex == rowCount - 1) {
        background = [UIImage imageNamed:@"cell_bottom.png"];
    } else {
        background = [UIImage imageNamed:@"cell_middle.png"];
    }
    
    return background;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Display recipe in the table cell
    Contact *contact = [tableData objectAtIndex:indexPath.row];
    NSInteger *index = indexPath.row;
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = [UIImage imageNamed:@"contact"];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    nameLabel.text = contact.name;
    
    UILabel *numberLabel = (UILabel *)[cell viewWithTag:102];
    numberLabel.text = contact.number;
    UIButton *buttonDelete =(UIButton *)[cell viewWithTag:104];
    buttonDelete.layer.cornerRadius =8.0f;
    
    [buttonDelete addTarget:self
                     action:@selector(removeContact:)
       forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
- (NSArray *) removeObjectFromArray:(NSArray *) array withIndex:(NSInteger) index {
    NSMutableArray *modifyableArray = [[NSMutableArray alloc] initWithArray:array];
    [modifyableArray removeObjectAtIndex:index];
    return [[NSArray alloc] initWithArray:modifyableArray];
}

- (void) removeContact:(id)sender
{
    CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    Contact *contactToDelete = [tableData objectAtIndex:indexPath.row];
    [ContactDao deleteContactData:contactToDelete];
    tableData = [ContactDao getAllContactData];
    [self.tableView reloadData];
     NSLog(@"delete contact %d",indexPath.row);
    //[self removeObjectFromArray:tableData :indexContact];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}
- (Boolean) findContactExist:(NSString*) newContactName
{
    for (int i=0; i < [tableData count]; i++) {
       Contact *currentContact = [tableData objectAtIndex:i];
        if([newContactName isEqualToString:currentContact.name]){
            return YES;
        }
    }
    return NO;
}
-(void)loginSucessfull{
    [self showDialogBoxOptions:0];
}


- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutAction:(id)sender {
    AppDelegate *delegeate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegeate logout:_logoutButton withConstraint:self->loginButtonWidthContraint];

}
@end
