//
//  PushMusicPlayer.m
//  PushMusic
//
//  Created by Aaron Sarazan on 12/31/10.
//

#import "PushMusicPlayer.h"
#import "Constants.h"
#import "Utilities.h"

@implementation PushMusicPlayer

- (id)init {    
    self = [super init];
    if (self) { 
		defaults = [NSUserDefaults standardUserDefaults];
		ipodController = [MPMusicPlayerController iPodMusicPlayer];
		SEL pollingSelector = @selector(pollingForSongCallback:);
		
		float interval = atof([[[NSUserDefaults standardUserDefaults] stringForKey:@"pref_poll_rate"] UTF8String]);
		pollTimer = [[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:pollingSelector userInfo:nil repeats:YES] retain];
		[pollTimer fire];
	}
	
	return self;
}

- (void)playSongByID:(NSString*)stringId {
	unsigned long long rawId=strtoull([stringId UTF8String], NULL, 0);
	NSNumber * number=[NSNumber numberWithUnsignedLongLong:rawId];	
	MPMediaPropertyPredicate * predicate= [MPMediaPropertyPredicate predicateWithValue:number forProperty:MPMediaItemPropertyPersistentID];
	MPMediaQuery * query=[[[MPMediaQuery alloc] initWithFilterPredicates:[NSSet setWithObject:predicate]] autorelease];
	
	[ipodController setQueueWithQuery:query];
	[ipodController play];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"Response");
	
	NSString * stringID = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	[self playSongByID:stringID];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Failed!");
}

-(void)getSongRequest {
	NSLog(@"Grabbing song request");
	
#ifndef PUSHMUSIC_DUMMY_SERVER
	NSString * deviceID = [Utilities deviceId];
	NSURL * checkURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@/%@",
											 [defaults stringForKey:kPrefServerIP],
											 [defaults stringForKey:kPrefServerPort],
											 kGetURLString,
											 deviceID]];
	NSURLRequest * request = [NSURLRequest requestWithURL:checkURL];
	myConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
#else
	[self playSongByID:kTestID];
#endif
}

-(void)pollingForSongCallback:(NSTimer*)timer {
	NSLog(@"Polling for playback command");
	[self getSongRequest];
}

- (void)dealloc {
	[pollTimer release];
	[super dealloc];
}

@end
