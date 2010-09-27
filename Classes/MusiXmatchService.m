//
//  MusiXmatchService.m
//  MusiXmatch
//
//  Created by Roman Shterenzon on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MusiXmatchService.h"
#import "SZJsonParser.h"
#import "Track.h"
#import "NSString+Extensions.h"

static NSString *kUserAgent = nil;

@interface MusiXmatchService (Private)
- (NSString*)baseUrl:(NSString*)method;
- (NSDictionary*)performQuery:(NSString*)url;
- (NSArray*)trackSearch:(NSString *)url;
@end


@implementation MusiXmatchService

- (NSString*)baseUrl:(NSString*)method {
	return [NSString stringWithFormat:@"%@%@?apikey=%@&format=%@", APIBASE, method, APIKEY, APIFORMAT];
}


- (NSDictionary*)performQuery:(NSString*)urlStr {
	NSURL *url = [[NSURL alloc] initWithString:urlStr];
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[url release];
	if (!kUserAgent) {
#if TARGET_OS_IPHONE
		NSDictionary *infoPList = [[NSBundle mainBundle] infoDictionary];
		NSString *appName = [infoPList objectForKey:@"CFBundleDisplayName"];
		NSString *version = [infoPList objectForKey:@"CFBundleVersion"];
		kUserAgent = [[NSString alloc] initWithFormat:@"%@/%@ (%@; %@; %@ %@)", appName, version,
					 [UIDevice currentDevice].model,
					 [[[NSUserDefaults standardUserDefaults] objectForKey: @"AppleLanguages"] objectAtIndex:0],
					 [UIDevice currentDevice].systemName,
					 [UIDevice currentDevice].systemVersion]];
#else
		kUserAgent = USER_AGENT;
#endif
	}
	[request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[request release];
	if (error) {
		NSLog(@"Error fetching %@: %@", url, [error localizedDescription]);
		return nil;
	}
	SZJsonParser *parser = [[SZJsonParser alloc] initWithData:data];
	id dict = [parser parse];
	[parser release];
	if (![dict isKindOfClass:[NSDictionary class]]) {
		NSLog(@"Invalid response: %@", dict);
		return nil;
	}
	NSDictionary *body = [[dict objectForKey:@"message"] objectForKey:@"body"];
	return body;
}


- (NSArray*)trackSearch:(NSString *)url {
	NSDictionary *body = [self performQuery:url];
	[url release];
	NSArray *results = [body objectForKey:@"track_list"];
	if (!results) {
		return [NSArray array];
	}
	NSMutableArray *tracks = [NSMutableArray array];
	for (NSDictionary *dict in results) {
		Track *track = [[Track alloc] initWithDictionary:[dict objectForKey:@"track"]];
		[tracks addObject:track];
		[track release];
	}
	return tracks;
}


- (NSArray*)trackSearch:(NSString *)query numResults:(NSUInteger)numResults {
	NSString *url = [[NSString alloc] initWithFormat:@"%@&q=%@&page_size=%u&f_has_lyrics=1",
					 [self baseUrl:TRACK_SEARCH], [query URLEncoded], numResults];
	return [self trackSearch:url];
}


- (Track*)trackSearch:(NSString*)artist track:(NSString*)track {
	NSString *url = [[NSString alloc] initWithFormat:@"%@&q_artist=%@&q_track=%@&page_size=1&f_has_lyrics=1",
						[self baseUrl:TRACK_SEARCH], [artist URLEncoded], [track URLEncoded]];
	NSArray *tracks = [self trackSearch:url];
	if (!tracks || [tracks count] == 0) {
		return nil;
	}
	return [tracks objectAtIndex:0];
}


- (NSString*)getLyrics:(NSUInteger)lyricsId {
	NSString *url = [[NSString alloc] initWithFormat:@"%@&lyrics_id=%u",
						[self baseUrl:LYRICS_GET], lyricsId];
	NSDictionary *body = [self performQuery:url];
	[url release];
	if (!body) {
		return nil;
	}
	return [[[body objectForKey:@"lyrics_list"] objectForKey:@"lyrics"] objectForKey:@"lyrics_body"];
}


- (Track*)getTrack:(NSUInteger)trackId {
	NSString *url = [[NSString alloc] initWithFormat:@"%@&track_id=%u",
					 [self baseUrl:TRACK_GET], trackId];
	NSDictionary *body = [self performQuery:url];
	NSDictionary *dict = [[body objectForKey:@"track_list"] objectForKey:@"track"];
	Track *track = [[Track alloc] initWithDictionary:dict];
	return [track autorelease];
}


@end
