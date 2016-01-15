//
//  ContactViewController.h
//  CareSentineliOS
//
//  Created by Andres Prada on 12/15/15.
//  Copyright © 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNSwitchChangedDelegate.h"
#import <AddressBookUI/AddressBookUI.h>

@interface SmsViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
- (IBAction)backAction:(id)sender;
- (IBAction)logoutAction:(id)sender;
- (Boolean) findContactExist:(NSArray*)contactList contact:(NSString*) newContactName;
@end
