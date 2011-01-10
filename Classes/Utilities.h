//
//  Utilities.h
//  PushMusic
//
//  Created by Aaron Sarazan on 1/8/11.
//  Copyright 2011 Spark Plug Games, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utilities : NSObject {
	
}

+(NSString *) md5:(NSString *)str;
+(NSData *) gzipData:(NSData *)data;
+(BOOL) isSimulator;
+(NSString *) deviceId;
+(NSString *) deviceName;

@end
