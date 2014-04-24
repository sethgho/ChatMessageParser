//
//  SGChatMessageParser.h
//  ChatMessageParser
//
//  Created by Seth on 4/23/14.
//  Copyright (c) 2014 Seth Gholson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGChatMessageParser : NSObject

+(void)parseMessage:(NSString*)message withBlock:(void (^)(NSDictionary *result))block;
+(void)jsonStringForParsedMessage:(NSString*)message withBlock:(void (^)(NSString *json))block;
@end
