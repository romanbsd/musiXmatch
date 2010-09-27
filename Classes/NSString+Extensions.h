//
//  NSString+Extensions.h
//  XtreaMusic
//
//  Created by Roman Shterenzon on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* cachesDirectory(void);

@interface NSString(Extensions)
- (NSString *)URLEncoded;
@end
