//
//  DropBoxShare.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>
#import "Travel.h"

@interface DropBoxShare : NSObject <DBSessionDelegate, DBRestClientDelegate, UIAlertViewDelegate> {
    NSString *_relinkUserId;
    DBRestClient *_restClient;
    Travel *_travelToShare;
    NSString *_tempFile;
}

+ (DropBoxShare *)sharedInstance;
- (void)share:(Travel *)travel;
- (void)continueAction;

@end
