//
//  PushMusicPlayer.m
//  PushMusic
//
//  Created by Aaron Sarazan on 12/31/10.
//

#import "PushMusicPlayer.h"

static const NSString * kGetURLString=@"http://localhost/";

static const NSString * kTestID=@"14017898169059185142";

@implementation PushMusicPlayer

- (id)init {
    
    self = [super init];
    if (self) {
		ipodController=[MPMusicPlayerController iPodMusicPlayer];
		SEL pollingSelector = @selector(pollingForSongCallback:);
		pollTimer=[[NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:pollingSelector userInfo:nil repeats:YES] retain];
		[pollTimer fire];
	}
	
	return self;
}

- (void)playSongByID:(NSString*)stringId
{
	unsigned long long rawId=strtoull([stringId UTF8String], NULL, 0);
	NSNumber * number=[NSNumber numberWithUnsignedLongLong:rawId];	
	MPMediaPropertyPredicate * predicate= [MPMediaPropertyPredicate predicateWithValue:number forProperty:MPMediaItemPropertyPersistentID];
	MPMediaQuery * query=[[[MPMediaQuery alloc] initWithFilterPredicates:[NSSet setWithObject:predicate]] autorelease];
	
	[ipodController setQueueWithQuery:query];
	[ipodController play];	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"Response");
}

-(void)getSongRequest
{
	NSLog(@"Grabbing song request");

	//TODO -- get actual data from a server
	//NSURLRequest * request=[NSURLRequest requestWithURL:kGetURLString];
	//[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	
	//REMOVE this if-wrapper, as it's only to make sure it doesn't keep repeating the same song every poll with canned data
	if(ipodController.playbackState!=MPMusicPlaybackStatePlaying) { 
		[self playSongByID:kTestID];
	}
}

-(void)pollingForSongCallback:(NSTimer*)timer
{
	//TODO grab playback info
	NSLog(@"Polling for playback command");
	[self getSongRequest];
}

- (void)dealloc {
	[pollTimer release];
	[super dealloc];
}

@end
