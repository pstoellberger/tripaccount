//
//  ParticipantSortViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParticipantViewController.h"
#import "Travel.h"
#import "UIFactory.h"

@interface ParticipantSortViewController : UIViewController <ParticipantViewControllerDelegate>

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) ParticipantViewController *detailViewController;

- (id)initWithTravel:(Travel *) travel;

- (void)didItemCountChange:(NSUInteger)itemCount;

@end
