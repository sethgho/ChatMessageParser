//
//  SGChatMessageParser.m
//  ChatMessageParser
//
//  Created by Seth on 4/23/14.
//  Copyright (c) 2014 Seth Gholson. All rights reserved.
//

#import "SGChatMessageParser.h"
#import "SGTitleParser.h"

@implementation SGChatMessageParser

+(void)jsonStringForParsedMessage:(NSString*)message withBlock:(void (^)(NSString *json))block
{
	[self parseMessage:message withBlock:^(NSDictionary *result) {
		NSError *error;
		NSData *data = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
		if(error){
			NSLog(@"%@",error);
		}
		NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		block(json);
	}];
}

+(void)parseMessage:(NSString*)message withBlock:(void (^)(NSDictionary *result))block
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	if(!message || message.length == 0)
	{
		block(result);
		return;
	}
	
	NSArray *urls = [self urlsForMessage:message];
	if(urls && urls.count > 0)
	{
		NSArray *links = [self titlesWithUrls:urls];
		[result setObject:links forKey:@"links"];
	}
	
	NSArray* emoticons = [self emoticonsForMessage:message];
	if(emoticons && emoticons.count > 0)
	{
		[result setObject:emoticons forKey:@"emoticons"];
	}
	
	NSArray* mentions = [self mentionsForMessage:message];
	if(mentions && mentions.count > 0)
	{
		[result setObject:mentions forKey:@"mentions"];
	}
	
	block(result);
}

+(NSArray*)urlsForMessage:(NSString*)message
{
	NSMutableArray *links = [NSMutableArray array];
	NSError *error;
	NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
	if(error)
	{
		NSLog(@"Problem initializing data detector: %@", error);
		return links;
	}
	
	NSMutableArray *urls = [NSMutableArray array];
	[detector enumerateMatchesInString:message options:NSMatchingWithTransparentBounds range:NSMakeRange(0, message.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[urls addObject:result.URL];
	}];
	
	[urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[links addObject:obj];
	}];
	
	return links;
}

+(NSArray*)titlesWithUrls:(NSArray*)urls
{
	__block NSMutableArray *results = [NSMutableArray array];
	
	dispatch_group_t group = dispatch_group_create();
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	for (NSURL *url in urls) {
		dispatch_group_async(group, queue, ^{
			SGTitleParser *parser = [[SGTitleParser alloc] initWithUrl:url];
			[parser parseSynchronously];
			if(parser.title){
				[results addObject:@{@"url": [url absoluteString], @"title" : parser.title}];
			}else {
				[results addObject:@{@"url": [url absoluteString]}];
			}
		});
	}
	
	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
		
	return results;
}

+(NSArray*)emoticonsForMessage:(NSString*)message
{
	NSMutableArray *emoticons = [NSMutableArray array];
	NSError *error;
	NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\([^()]*\\)" options:0 error:&error];
	[regex enumerateMatchesInString:message options:NSMatchingWithTransparentBounds range:NSMakeRange(0,message.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSString *emoticon = [message substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 2)];
		[emoticons addObject:emoticon];
	}];
	return emoticons;
}

+(NSArray*)mentionsForMessage:(NSString*)message
{
	NSMutableArray *mentions = [NSMutableArray array];
	
	NSError *error;
	NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"@(\\w+)" options:0 error:&error];
	[regex enumerateMatchesInString:message options:NSMatchingWithTransparentBounds range:NSMakeRange(0,message.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSString *mention = [message substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 1)];
		[mentions addObject:mention];
	}];
	return mentions;
}

@end
