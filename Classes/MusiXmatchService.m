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
static MusiXmatchService *sharedInstance = nil;

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
	NSHTTPURLResponse *response = nil;
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
	if ([response statusCode] != 200) {
		NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"Cannot fetch %@: %@", url, body);
		[body release];
		return nil;
	}
	SZJsonParser *parser = [[SZJsonParser alloc] initWithData:data];
	id dict = [parser parse];
	[parser release];
	if (![dict isKindOfClass:[NSDictionary class]]) {
		NSLog(@"Invalid response: %@", dict);
		return nil;
	}
	id body = [[dict objectForKey:@"message"] objectForKey:@"body"];
	if (![body isKindOfClass:[NSDictionary class]]) {
		NSLog(@"Invalid body, statusCode: %@", [[[dict objectForKey:@"message"] objectForKey:@"header"] objectForKey:@"status_code"]);
		return nil;
	}
	return body;
}


- (NSArray*)trackSearch:(NSString *)url {
	NSDictionary *body = [self performQuery:url];
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
	NSString *url = [NSString stringWithFormat:@"%@&q=%@&page_size=%u&f_has_lyrics=1",
					 [self baseUrl:TRACK_SEARCH], [query URLEncoded], numResults];
	return [self trackSearch:url];
}


- (Track*)trackSearch:(NSString*)artist track:(NSString*)track {
	NSString *url = [NSString stringWithFormat:@"%@&q_artist=%@&q_track=%@&page_size=1&f_has_lyrics=1",
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
	NSArray *lyricsList = [body objectForKey:@"lyrics_list"];
	if ([lyricsList count] == 0) {
		return nil;
	}
	return [[[lyricsList objectAtIndex:0] objectForKey:@"lyrics"] objectForKey:@"lyrics_body"];
}


- (Track*)getTrack:(NSUInteger)trackId {
	NSString *url = [[NSString alloc] initWithFormat:@"%@&track_id=%u",
					 [self baseUrl:TRACK_GET], trackId];
	NSDictionary *body = [self performQuery:url];
	NSDictionary *dict = [[body objectForKey:@"track_list"] objectForKey:@"track"];
	Track *track = [[Track alloc] initWithDictionary:dict];
	return [track autorelease];
}


#pragma mark -
#pragma mark Singleton methods

+ (MusiXmatchService*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[MusiXmatchService alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
