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
	NSURLConnection * connection;
}

- (NSString *)createSerializedCollection;
+ (void) updateCollection;
+ (NSArray *) getCollection;
+ (NSURLRequest *)createPostRequest:(NSURL *)destination withPath:(NSString *)path;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
