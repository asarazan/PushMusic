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

}

-(void)setupMediaCallbacks;
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void)pollingForSongCallback:(NSTimer*)timer;
-(void)getSongRequest;
-(void)playSongByID;

@end
