//
//  Track.m
//  MusiXmatch
//
//  Created by Roman Shterenzon on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Track.h"
#import "Artist.h"
#import "MusiXmatchService.h"

@interface Track ()
@property (nonatomic,retain) Artist *artist;
@property (nonatomic,retain) NSString *name;
@property (nonatomic) NSUInteger mxmId;
@property (nonatomic,retain) NSString *mbId;
@end


@implementation Track
@synthesize artist, name, mxmId, mbId, lyricsId;
@dynamic lyrics;

+ (id)trackWithId:(NSUInteger)trackId {
	MusiXmatchService *service = [MusiXmatchService sharedInstance];
	return [service getTrack:trackId];
}
	
- (id)initWithDictionary:(NSDictionary *)dict {
	Artist *theArtist = [[[Artist alloc] initWithDictionary:dict] autorelease];
	return [self initWithArtist:theArtist
						   name:[dict objectForKey:@"track_name"]
						  mxmId:[[dict objectForKey:@"track_id"] intValue]
						   mbId:[dict objectForKey:@"track_mbid"]
					   lyricsId:[[dict objectForKey:@"lyrics_id"] intValue]];
}

- (id)initWithArtist:(Artist*)theArtist name:(NSString*)theName mxmId:(NSUInteger)theMxmId mbId:(NSString*)theMbId lyricsId:(NSUInteger)theLyricsId {
	if ((self = [super init])) {
		self.artist = theArtist;
		self.name = theName;
		self.mxmId = theMxmId;
		self.mbId = theMbId;
		lyricsId = theLyricsId;
	}
	return self;
}

- (NSString*)lyrics {
	if (!lyrics) {
		MusiXmatchService *service = [MusiXmatchService sharedInstance];
		lyrics = [[service getLyrics:lyricsId] retain];
	}
	return lyrics;
}

- (void)dealloc {
	[lyrics release];
	[artist release];
	[name release];
	[mbId release];
	[super dealloc];
}
@end
