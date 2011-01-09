//
//  PushMusicPlayer.h
//  PushMusic
//
//  Created by Aaron Sarazan on 12/31/10.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PushMusicPlayer : NSObject {	
	NSTimer * pollTimer;
	MPMusicPlayerController * ipodController;
	NSURLConnection * myConnection;
	NSUserDefaults * defaults;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)pollingForSongCallback:(NSTimer *)timer;
- (void)getSongRequest;
- (void)playSongByID:(NSString *)stringId;

@end
