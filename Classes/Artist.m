//
//  Artist.m
//  MusiXmatch
//
//  Created by Roman Shterenzon on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Artist.h"

@interface Artist ()
@property (nonatomic,retain) NSString *name;
@property (nonatomic) NSUInteger mxmId;
@property (nonatomic,retain) NSString *mbId;
@end


@implementation Artist
@synthesize name, mxmId, mbId;

- (id)initWithDictionary:(NSDictionary *)dict {
	return [self initWithName:[dict objectForKey:@"artist_name"]
						mxmId:[[dict objectForKey:@"artist_id"] intValue]
						 mbId:[dict objectForKey:@"artist_mbid"]];
}

- (id)initWithName:(NSString*)theName mxmId:(NSUInteger)theMxmId mbId:(NSString*)theMbId {
	if ((self = [super init])) {
		self.name = theName;
		self.mxmId = theMxmId;
		self.mbId = theMbId;
	}
	return self;
}

- (void)dealloc {
	[name release];
	[mbId release];
	[super dealloc];
}
@end
