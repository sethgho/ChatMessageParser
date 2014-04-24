//
//  SGTitleParser.m
//  ChatMessageParser
//
//  Created by Seth on 4/23/14.
//  Copyright (c) 2014 Seth Gholson. All rights reserved.
//

#import "SGTitleParser.h"

@implementation SGTitleParser

BOOL _isTitle;

-(id)initWithUrl:(NSURL*)url
{
	self = [super init];
    if (self) {
		self.url = url;
    }
    return self;
}

-(void)parseSynchronously {
	NSError *error;
	NSString *content = [NSString stringWithContentsOfURL:self.url encoding:NSUTF8StringEncoding error:&error];
	if(error)
	{
		NSLog(@"%@", error);
		return;
	}
	NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"<title[^>]*>(.*?)</title>" options:0 error:&error];
	if(error)
	{
		NSLog(@"%@", error);
		return;
	}
	NSArray *matches = [regex matchesInString:content options:NSMatchingWithTransparentBounds range:NSMakeRange(0, content.length)];
	NSTextCheckingResult *match = [matches firstObject];
	self.title = [content substringWithRange:NSMakeRange(match.range.location + 7, match.range.length - 15)];
}

@end
