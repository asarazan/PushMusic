//
//  PushMusic.m
//  PushMusic
//
//  Created by Aaron Sarazan on 12/31/10.
//

#import "PushMusic.h"
#import "PushMusicPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SBJsonStreamWriter.h"

static NSArray * s_collection;
static NSString * const kDeviceID=@"deviceId";
static NSString * const kName=@"name";
static NSString * const kSongs=@"songs";
static NSString * const kArtist=@"artist";
static NSString * const kAlbum=@"album";
static NSString * const kTitle=@"title";
static NSString * const kTrackNumber=@"trackNumber";
static NSString * const kSongID=@"id";

static NSString * const kPostURLString=@"device";
static NSString * const kPath=@".jsonstorage";

@implementation PushMusic

- (id)init {    
    self = [super init];
    if (self) {
		NSString * data = [self createSerializedCollection];
		NSString * tempDir = NSTemporaryDirectory();
		NSString * fullPath = [tempDir stringByAppendingFormat:@"/%@.txt",kPath];
		[data writeToFile:fullPath atomically:NO encoding:NSUTF8StringEncoding error:NULL];
		
		NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		NSString * serverIP = [defaults stringForKey:@"pref_server_ip"];
		NSString * serverPort = [defaults stringForKey:@"pref_server_port"];
		
		NSURL * postURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@",serverIP,serverPort,kPostURLString]];
		NSURLRequest * request=[PushMusic createPostRequest:postURL withPath:fullPath];
		connection=[[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
		
		player=[[PushMusicPlayer alloc] init];   
	}
    return self;
}

+ (NSURLRequest *)createPostRequest:(NSURL *)destination withPath:(NSString *)path {
	NSMutableURLRequest* post = [NSMutableURLRequest requestWithURL:destination];
	NSLog(@"Posting to %@", destination);
	//[post addValue: @"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
	[post setHTTPMethod: @"POST"];
	[post setHTTPBodyStream:[NSInputStream inputStreamWithFileAtPath:path]];
	
	return post;
}

- (NSString *)createSerializedCollection {
	NSArray * collection=[PushMusic getCollection];
	SBJsonStreamWriter * writer = [[SBJsonStreamWriter alloc] init];
	[writer writeObjectOpen];
	
	[writer writeString:kDeviceID];
	[writer writeString:[[UIDevice currentDevice] uniqueIdentifier]];
	
	[writer writeString:kName];
	[writer writeString:[[UIDevice currentDevice] name]];
	
	[writer writeString:kSongs];	
	[writer writeArrayOpen];
	for (MPMediaItem * song in collection) {
		NSDictionary * dictionary=[NSDictionary dictionaryWithObjectsAndKeys:
								   [song valueForProperty:MPMediaItemPropertyArtist],kArtist,
								   [song valueForProperty:MPMediaItemPropertyAlbumTitle],kAlbum,
								   [song valueForProperty:MPMediaItemPropertyTitle],kTitle,
								   [song valueForProperty:MPMediaItemPropertyAlbumTrackNumber],kTrackNumber,
								   [song valueForProperty:MPMediaItemPropertyPersistentID],kSongID,
								   nil,nil];
		[writer writeValue:dictionary];
	}	
	
	[writer writeArrayClose];
	[writer writeObjectClose];
	NSString * buf = [[[NSString alloc] initWithData:[writer buf] encoding:NSUTF8StringEncoding] autorelease];
	return buf;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Failed!");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Connection Complete");
}

+ (NSArray*)getCollection {
	if (nil==s_collection) {
		[self updateCollection];
	}
	return s_collection;
}

+ (void)updateCollection {
	MPMediaQuery *everything = [[MPMediaQuery alloc] init];
	[everything setGroupingType: MPMediaGroupingArtist];
	s_collection = [everything items];
}

- (void)dealloc {
	[player release];
    [super dealloc];
}


@end
