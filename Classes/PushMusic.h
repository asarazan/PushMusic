//
//  PushMusic.h
//  PushMusic
//
//  Created by Aaron Sarazan on 12/31/10.
//

#import <Foundation/Foundation.h>

@class PushMusicPlayer;

@interface PushMusic : NSObject {
	PushMusicPlayer * player;
}
-(NSString *)createSerializedCollection;
+(void) updateCollection;
+(NSArray *) getCollection;
+(NSURLRequest *)createPostRequest:(NSURL *)destination withPath:(NSString *)path;

@end
