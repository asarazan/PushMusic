//
//  PushMusicPlayer.m
//  PushMusic
//
//  Created by Aaron Sarazan on 12/31/10.
//

#import "PushMusicPlayer.h"

static const NSString * kGetURLString=@"http://10.0.1.14:8124/check";
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"Response");
	
	NSString * stringID = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	[self playSongByID:stringID];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Failed!");
}

-(void)getSongRequest
{
	NSLog(@"Grabbing song request");

	NSString * checkString = [NSString stringWithFormat:@"%@/%@",kGetURLString,[[UIDevice currentDevice] uniqueIdentifier]];
	NSURLRequest * request=[NSURLRequest requestWithURL:[NSURL URLWithString:checkString]];
	[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
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
