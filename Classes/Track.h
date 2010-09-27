//
//  Track.h
//  MusiXmatch
//
//  Created by Roman Shterenzon on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Artist;

@interface Track : NSObject {
	Artist *artist;
	NSString *name;
	NSUInteger mxmId;
	NSString *mbId;
	NSUInteger lyricsId;
	NSString *lyrics;
}

@property (nonatomic,retain,readonly) Artist *artist;
@property (nonatomic,retain,readonly) NSString *name;
@property (nonatomic,readonly) NSUInteger mxmId;
@property (nonatomic,retain,readonly) NSString *mbId;
@property (readonly) NSUInteger lyricsId;
@property (nonatomic,retain,readonly) NSString *lyrics;

// Get the track with the provided MusiXmatch id
+ (id)trackWithId:(NSUInteger)trackId;

/* Create a track from a dictionary. The dictionary should have the following keys:
 @"track_id"
 @"track_mbid"
 @"lyrics_id"
 @"track_name"
 @"artist_id"
 @"artist_mbid"
 @"artist_name"
*/
- (id)initWithDictionary:(NSDictionary*)dict;

- (id)initWithArtist:(Artist*)theArtist name:(NSString*)theName mxmId:(NSUInteger)theMxmId mbId:(NSString*)theMbId lyricsId:(NSUInteger)theLyricsId;

@end
