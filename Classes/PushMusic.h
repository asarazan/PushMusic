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
	NSURLConnection * myConnection;
}

- (void) updateCollection;
- (NSArray *) getCollection;
- (void) sendLibrary;
- (void) createSerializedCollection;
- (NSString *) getFullPath;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

+ (NSURLRequest *)createPostRequest:(NSURL *)destination withPath:(NSString *)path;

@end
