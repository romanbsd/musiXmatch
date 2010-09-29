//
//  main.m
//  MusiXmatch
//
//  Created by Roman Shterenzon on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include "MusiXmatchService.h"
#include "Artist.h"
#include "Track.h"

int main(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	MusiXmatchService *service = [MusiXmatchService sharedInstance];
	Track *track = [service trackSearch:@"Iron Maiden" track:@"the trooper"];
	NSLog(@"track_id: %u, lyrics: %@", track.mxmId, [track lyrics]);

	NSArray *tracks = [service trackSearch:@"dreamer" numResults:10];
	for (track in tracks) {
		NSLog(@"TrackID: %u, Artist: %@, Title: %@", track.mxmId, track.artist.name, track.name);
	}
	track = [service trackSearch:@"dummyartist" track:@"dummytrack"];
	NSLog(@"track: %@", track);
	
	[pool release];
	return 0;
}