//
//  TypeViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "GenericSelectViewController.h"
#import "Type.h"

@interface TypeViewController : GenericSelectViewController {
    UIBarButtonItem *_editButton;
    UIBarButtonItem *_doneButton;
    UIBarButtonItem *_addButton;
    
    Type *_editedType;
}

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withMultiSelection:(BOOL)multiSelection withSelectedObjects:(NSArray *)selectedObjects target:(id)target action:(SEL)selector;
- (void)editType:(Type *)type;

@end
