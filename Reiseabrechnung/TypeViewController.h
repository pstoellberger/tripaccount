//
//  TypeViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "GenericSelectViewController.h"

@interface TypeViewController : GenericSelectViewController {
    UIBarButtonItem *_editButton;
    UIBarButtonItem *_doneButton;
    UIBarButtonItem *_addButton;
    
    Type *_editedType;
}

- (void)editType:(Type *)type;

@end
