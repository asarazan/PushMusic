//
//  Utilities.m
//  PushMusic
//
//  Created by Aaron Sarazan on 1/8/11.
//  Copyright 2011 Spark Plug Games, LLC. All rights reserved.
//

#import "Utilities.h"

#import <CommonCrypto/CommonDigest.h>
#import <zlib.h>
#import "NSData+CocoaDevUsersAdditions.h"
#import "TargetConditionals.h"

@implementation Utilities

//adapted from http://discussions.apple.com/thread.jspa?threadID=1509152
+ (NSString *) md5:(NSString *)str {	
	const char *cStr = [str UTF8String];	
	CC_LONG len=strlen(cStr);
	unsigned char *result = malloc(len);
	CC_MD5(cStr, len, result);
	return [NSString 			
			stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",			
			result[0], result[1],			
			result[2], result[3],			
			result[4], result[5],			
			result[6], result[7],			
			result[8], result[9],			
			result[10], result[11],			
			result[12], result[13],			
			result[14], result[15]];	
}

+ (NSData *) gzipData:(NSData *)data {
	return [[data zlibDeflate] autorelease];
}

+ (BOOL) isSimulator {
#ifdef TARGET_IPHONE_SIMULATOR
	return YES;
#else
	return NO;
#endif
}

+ (NSString *) deviceId {
	return [Utilities isSimulator] ? @"0" : [[UIDevice currentDevice] uniqueIdentifier];
}

+ (NSString *) deviceName {
	return [Utilities isSimulator] ? @"Simulator" : [[UIDevice currentDevice] name];
}
@end
