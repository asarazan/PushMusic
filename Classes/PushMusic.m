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
static const NSString * kDeviceID=@"deviceId";
static const NSString * kName=@"name";
static const NSString * kSongs=@"songs";
static const NSString * kArtist=@"artist";
static const NSString * kAlbum=@"album";
static const NSString * kTitle=@"title";
static const NSString * kTrackNumber=@"trackNumber";
static const NSString * kSongID=@"id";

static const NSString * kPostURLString=@"http://localhost/"; //TODO get dynamic URLs
static const NSString * kGetURLString=@"http://localhost/";
static const NSString * kPath=@".jsonstorage";

@implementation PushMusic

- (id)init {
    
    self = [super init];
    if (self) {
		NSData * data=[self createSerializedCollection];
		NSString *tempDir = NSTemporaryDirectory();
		NSString * fullPath = [tempDir stringByAppendingFormat:@"/%@.txt",kPath];
		[data writeToFile:fullPath atomically:NO];
		
		NSURLRequest * request=[PushMusic createPostRequest:[NSURL URLWithString:kPostURLString] withPath:fullPath];
		[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
		
		player=[[PushMusicPlayer alloc] init];    }
    return self;
}

+ (NSURLRequest *)createPostRequest:(NSURL *)destination withPath:(NSString *)path {
	NSMutableURLRequest* post = [NSMutableURLRequest requestWithURL:destination];
	NSLog(@"Posting to %@", destination);
	[post addValue: @"application/octet-stream" forHTTPHeaderField:
	 @"Content-Type"];
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
