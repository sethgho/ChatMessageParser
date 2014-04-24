//
//  ChatMessageParserTests.m
//  ChatMessageParserTests
//
//  Created by Seth on 4/23/14.
//  Copyright (c) 2014 Seth Gholson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SGChatMessageParser.h"

@interface ChatMessageParserTests : XCTestCase

@end

@implementation ChatMessageParserTests

-(void)runAsync:(void (^)(BOOL *done))block
{
    __block BOOL done = NO;
    block(&done);
    while (!done) {
        [[NSRunLoop mainRunLoop] runUntilDate:
		 [NSDate dateWithTimeIntervalSinceNow:.1]];
    }
}

- (void)testLink
{
	NSString *message = @"This is my blog http://www.sethgholson.com";
	[self runAsync:^(BOOL *done) {
		[SGChatMessageParser parseMessage:message withBlock:^(NSDictionary *result) {
			XCTAssertNotNil([result objectForKey:@"links"], @"Nil links were returned.");
			XCTAssertTrue([[result objectForKey:@"links"] count] == 1, @"One link was not included.");
			NSDictionary *firstMatch = [[result objectForKey:@"links"] firstObject];
			NSString *url = [firstMatch objectForKey:@"url"];
			NSString *title = [firstMatch objectForKey:@"title"];
			XCTAssertEqualObjects(url, @"http://www.sethgholson.com", @"Wrong URL returned.");
			XCTAssertEqualObjects(title, @"Seth Gholson", @"Title is wrong.");
			XCTAssertTrue([[result allKeys] count] == 1, @"Only links should be returned.");
			*done = YES;
		}];
	}];
}

- (void)testEmoticon
{
	NSString *message = @"This is a fun exercise!  (yey)";
	[self runAsync:^(BOOL *done) {
		[SGChatMessageParser parseMessage:message withBlock:^(NSDictionary *result) {
			XCTAssertTrue([[result objectForKey:@"emoticons"] count] == 1, @"Wrong emoticons returned.");
			NSString *emoticon = [[result objectForKey:@"emoticons"] firstObject];
			XCTAssertEqualObjects(emoticon, @"yey", @"yey wasn't the first emoticon.");
			XCTAssertNil([result objectForKey:@"links"], @"No links should be returned.");
			*done = YES;
		}];
	}];
}

- (void)testMentions
{
	NSString *message = @"@Kevin wants me to work for Atlassian.";
	[self runAsync:^(BOOL *done) {
		[SGChatMessageParser parseMessage:message withBlock:^(NSDictionary *result) {
			XCTAssertTrue([[result objectForKey:@"mentions"] count] == 1, @"Wrong mentions returned.");
			NSString* mention = [[result objectForKey:@"mentions"] firstObject];
			XCTAssertEqualObjects(mention, @"Kevin", @"Wrong mention returned.");
			XCTAssertNil([result objectForKey:@"links"], @"No links should be returned.");
			*done = YES;
		}];
	}];
}

- (void)testExample1
{
	
	NSString *message = @"@chris you around?";
	[self runAsync:^(BOOL *done) {
		[SGChatMessageParser parseMessage:message withBlock:^(NSDictionary *result) {
			XCTAssertTrue([[result objectForKey:@"mentions"] count] == 1, @"Wrong mentions returned.");
			NSString* mention = [[result objectForKey:@"mentions"] firstObject];
			XCTAssertEqualObjects(mention, @"chris", @"Wrong mention returned.");
			XCTAssertNil([result objectForKey:@"links"], @"No links should be returned.");
			XCTAssertNil([result objectForKey:@"emoticons"], @"No emoticons should be returned.");
			*done = YES;
		}];
	}];

}

- (void)testExample2
{
	
	NSString *message = @"Good morning! (megusta) (coffee)";
	[self runAsync:^(BOOL *done) {
		[SGChatMessageParser parseMessage:message withBlock:^(NSDictionary *result) {
			XCTAssertTrue([[result objectForKey:@"emoticons"] count] == 2, @"Wrong mentions returned.");
			NSString* emoticon1 = [[result objectForKey:@"emoticons"] firstObject];
			NSString* emoticon2 = [[result objectForKey:@"emoticons"] objectAtIndex:1];
			XCTAssertEqualObjects(emoticon1, @"megusta", @"Wrong megusta returned.");
			XCTAssertEqualObjects(emoticon2, @"coffee", @"Wrong coffee returned.");
			XCTAssertNil([result objectForKey:@"links"], @"No links should be returned.");
			XCTAssertNil([result objectForKey:@"mentions"], @"No mentions should be returned.");
			*done = YES;
		}];
	}];
}

- (void)testExample3
{
	NSString *message = @"@bob @john (success) such a cool feature; https://twitter.com/jdorfman/status/430511497475670016";
	[self runAsync:^(BOOL *done) {
		[SGChatMessageParser parseMessage:message withBlock:^(NSDictionary *result) {
			NSString* mention1 = [[result objectForKey:@"mentions"] firstObject];
			NSString* mention2 = [[result objectForKey:@"mentions"] objectAtIndex:1];
			XCTAssertEqualObjects(mention1, @"bob", @"Wrong bob returned.");
			XCTAssertEqualObjects(mention2, @"john", @"Wrong john returned.");
			
			NSString *emoticon = [[result objectForKey:@"emoticons"] firstObject];
			XCTAssertEqualObjects(@"success", emoticon, @"Wrong emoticon returned.");
			
			NSDictionary *link1 = [[result objectForKey:@"links"] firstObject];
			NSString *url1 = [link1 objectForKey:@"url"];
			XCTAssertEqualObjects(url1, @"https://twitter.com/jdorfman/status/430511497475670016", @"Wrong URL returned.");

			NSString *title1 = [link1 objectForKey:@"title"];
			XCTAssertEqualObjects(@"Twitter / jdorfman: nice @littlebigdetail from ...", title1, @"Wrong title returned.");
			
			*done = YES;
		}];
		
	}];
}

- (void)testJsonRepresentation
{
	NSString *message = @"Good morning! (megusta) (coffee)";
	[self runAsync:^(BOOL *done) {
		[SGChatMessageParser jsonStringForParsedMessage:message withBlock:^(NSString *json) {
			XCTAssertEqualObjects(@"{\"emoticons\":[\"megusta\",\"coffee\"]}", json, @"Wrong JSON returned.");
			*done = YES;
		}];
	}];
}

- (void)testJsonRepresentationPlain
{
	NSString *message = @"Good morning!";
	[self runAsync:^(BOOL *done) {
		[SGChatMessageParser jsonStringForParsedMessage:message withBlock:^(NSString *json) {
			XCTAssertEqualObjects(@"{}", json, @"Wrong JSON returned.");
			*done = YES;
		}];
	}];
}

- (void)testJsonRepresentationEmpty
{
	NSString *message = @"";
	[self runAsync:^(BOOL *done) {
		[SGChatMessageParser jsonStringForParsedMessage:message withBlock:^(NSString *json) {
			XCTAssertEqualObjects(@"{}", json, @"Wrong JSON returned.");
			*done = YES;
		}];
	}];
}

- (void)testJsonRepresentationNil
{
	[self runAsync:^(BOOL *done) {
		[SGChatMessageParser jsonStringForParsedMessage:nil withBlock:^(NSString *json) {
			XCTAssertEqualObjects(@"{}", json, @"Wrong JSON returned.");
			*done = YES;
		}];
	}];
}


@end
