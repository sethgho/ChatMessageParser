//
//  SGTitleParser.h
//  ChatMessageParser
//
//  Created by Seth on 4/23/14.
//  Copyright (c) 2014 Seth Gholson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGTitleParser : NSObject <NSXMLParserDelegate>

@property(nonatomic, strong) NSString *title;
@property(nonatomic, copy) NSURL* url;
-(id)initWithUrl:(NSURL*)url;
-(void)parseSynchronously;

@end
