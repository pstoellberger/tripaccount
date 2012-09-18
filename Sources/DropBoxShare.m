//
//  DropBoxShare.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DropBoxShare.h"
#import "Travel.h"
#import "Currency.h"
#import "ExchangeRate.h"
#import "Participant.h"
#import "Serialiser.h"

static DropBoxShare *gInstance = NULL;

@implementation DropBoxShare

+ (DropBoxShare *)sharedInstance {
    
    @synchronized(self) {
        if (gInstance == NULL) {
            gInstance = [[DropBoxShare alloc] init];
            
            NSString* appKey = @"fu0thva4eyj9pxh";
            NSString* appSecret = @"71si0t2ien79llv";
            NSString *root = kDBRootAppFolder; 
            
            DBSession* session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
            session.delegate = gInstance; // DBSessionDelegate methods allow you to handle re-authenticating
            [DBSession setSharedSession:session];

        }
    }
    
    return(gInstance);
}

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient = [[[DBRestClient alloc] initWithSession:[DBSession sharedSession]] retain];
        _restClient.delegate = self;
    }
    return _restClient;
}

- (NSArray *)createInitialOperations:(Travel *)travel {
    
    NSMutableArray *operations = [NSMutableArray array];
    
    NSMutableDictionary *operation = [NSMutableDictionary dictionaryWithCapacity:10];
    [operation setObject:@"create" forKey:@"operation"];
    [operation setObject:@"trip" forKey:@"type"];
    [operation setObject:[travel serialise] forKey:@"object"];
    [operations addObject:operation];
    
    for (Participant *participant in travel.participants) {
        operation = [NSMutableDictionary dictionaryWithCapacity:10];
        [operation setObject:@"create" forKey:@"operation"];
        [operation setObject:@"person" forKey:@"type"];
        [operation setObject:[participant serialise] forKey:@"object"];
        [operations addObject:operation];
    }
    
    for (Entry *entry in travel.entries) {
        operation = [NSMutableDictionary dictionaryWithCapacity:10];
        [operation setObject:@"create" forKey:@"operation"];
        [operation setObject:@"entry" forKey:@"type"];
        [operation setObject:[entry serialise] forKey:@"object"];
        [operations addObject:operation];
    }
    
    return operations;
}

- (void)continueAction {

    NSString *uploadFileName = @"dropboxInitialShare.plist";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:uploadFileName];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[self createInitialOperations:_travelToShare] forKey:@"operations"];
    NSString *errorStr = nil;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorStr]; 
    
    if (errorStr) {
        NSLog(@"Error: %@", errorStr);
    }
    
    NSError *error = nil;
    BOOL returnValue = [data writeToFile:appFile options:NSDataWritingAtomic error:&error];
    if (error || !returnValue) {
        NSLog(@"Error: %@", [error description]);
    }
    
    _tempFile = appFile;
    [[self restClient] uploadFile:@"MyTrip.plist" toPath:@"/" withParentRev:nil fromPath:appFile];
    
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    
    [[NSFileManager defaultManager] removeItemAtPath:_tempFile error:nil];

}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
    [[NSFileManager defaultManager] removeItemAtPath:_tempFile error:nil];
}

- (void)addToDictionary:(NSMutableDictionary *)dict object:(id)object key:(NSString *)key {
    if (object) {
        [dict setObject:object forKey:key];
    }
}

- (void)share:(Travel *)travel {
    
    [_travelToShare release];
    _travelToShare = travel;

    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] link];
    } else {
        [self continueAction];
    }

}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
	_relinkUserId = [userId retain];
	[[[[UIAlertView alloc] 
	   initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self 
	   cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil]
	  autorelease]
	 show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
	if (index != alertView.cancelButtonIndex) {
		[[DBSession sharedSession] linkUserId:_relinkUserId];
	}
	_relinkUserId = nil;
}

- (void)dealloc {
    [_restClient release];
}

@end
