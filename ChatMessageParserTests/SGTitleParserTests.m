//
//  SGTitleParserTests.m
//  ChatMessageParser
//
//  Created by Seth on 4/23/14.
//  Copyright (c) 2014 Seth Gholson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SGTitleParser.h"

@interface SGTitleParserTests : XCTestCase

@end

@implementation SGTitleParserTests

- (void)testTitleParserTwitter
{
	SGTitleParser *parser = [[SGTitleParser alloc] initWithUrl:[NSURL URLWithString:@"https://twitter.com/jdorfman/status/430511497475670016"]];
	[parser parseSynchronously];
	XCTAssertEqualObjects(@"Twitter / jdorfman: nice @littlebigdetail from ...", parser.title, @"Wrong title parsed.");
}

- (void)testTitleParserBlog
{
	SGTitleParser *parser = [[SGTitleParser alloc] initWithUrl:[NSURL URLWithString:@"http://www.sethgholson.com"]];
	[parser parseSynchronously];
	XCTAssertEqualObjects(@"Seth Gholson", parser.title, @"Wrong title parsed.");
}


- (void)testTitleParserGoogle
{
	SGTitleParser *parser = [[SGTitleParser alloc] initWithUrl:[NSURL URLWithString:@"http://www.google.com"]];
	[parser parseSynchronously];
	XCTAssertEqualObjects(@"Google", parser.title, @"Wrong title parsed.");
}

@end
