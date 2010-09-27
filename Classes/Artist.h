//
//  Artist.h
//  MusiXmatch
//
//  Created by Roman Shterenzon on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Artist : NSObject {
	NSString *name;
	NSUInteger mxmId;
	NSString *mbId;
}

@property (nonatomic,retain,readonly) NSString *name;
@property (nonatomic,readonly) NSUInteger mxmId;
@property (nonatomic,retain,readonly) NSString *mbId;

/* The dictionary should have the following keys:
 @"artist_name"
 @"artist_id"
 @"artist_mbid"
 */
- (id)initWithDictionary:(NSDictionary*)dict;

- (id)initWithName:(NSString*)theName mxmId:(NSUInteger)theMxmId mbId:(NSString*)theMbId;
@end
