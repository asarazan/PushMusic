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

//God-willing, we won't need to use this again.
static NSString * const kTestJSON=@"{\"deviceId\":\"d9db5c1b3386c6149ea468dd831423e8f182ef20\",\"name\":\"Robby's iPhone\","
										"\"songs\":[	{\"title\":\"A-Punk\",\"album\":\"Vampire Weekend\",\"trackNumber\":3,\"id\":15398368358004135853,\"artist\":\"Vampire Weekend\"},"
														"{\"title\":\"A.D.D\",\"album\":\"Steal This Album!\",\"trackNumber\":7,\"id\":14017898169059185142,\"artist\":\"System of a Down\"} ] }";

@implementation PushMusic

- (id)init {    
    self = [super init];
    if (self) {		
		[self sendLibrary];		
		player=[[PushMusicPlayer alloc] init];   
	}
    return self;
}

- (NSString *) getFullPath {
	NSString * tempDir = NSTemporaryDirectory();
	return [tempDir stringByAppendingFormat:@"/%@.txt",kPath];	
}

- (void) sendLibrary {
	[self createSerializedCollection];
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSString * serverIP = [defaults stringForKey:@"pref_server_ip"];
	NSString * serverPort = [defaults stringForKey:@"pref_server_port"];
	
	NSURL * postURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@",serverIP,serverPort,kPostURLString]];
	NSURLRequest * request=[[PushMusic createPostRequest:postURL withPath:[self getFullPath]] retain];
	myConnection=[[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];	
}

+ (NSURLRequest *)createPostRequest:(NSURL *)destination withPath:(NSString *)path {
	NSMutableURLRequest* post = [NSMutableURLRequest requestWithURL:destination];
	NSLog(@"Posting %@ to %@", path, destination);
	[post addValue: @"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
	[post setHTTPMethod: @"POST"];
	
	//TODO: get this thing to work with Streams instead of straight POST
//	[post setHTTPBodyStream:[NSInputStream inputStreamWithFileAtPath:path]];
	[post setHTTPBody:[NSData dataWithContentsOfFile:path]];
	
	return post;
}

- (void)createSerializedCollection {
	
	//If we're using canned data (say for Simulator testing) -- then we'll just read the planted file and write it back out.
#ifdef PUSHMUSIC_CANNED_DATA	
	NSString * json = [NSString stringWithContentsOfFile:[self getFullPath] encoding:NSUTF8StringEncoding error:NULL];
#else
	NSArray * collection=[self getCollection];
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
	NSString * json = [[[NSString alloc] initWithData:writer.buf encoding:NSUTF8StringEncoding] autorelease]; //May or may not be necessary. Won't take my chances.
#endif
	[json writeToFile:[self getFullPath] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Failed!");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Connection Complete");
}

//TODO probably don't need this singleton collection in memory, as we're storing it as a file now.
- (NSArray*)getCollection {
	if (nil==s_collection) {
		[self updateCollection];
	}
	return s_collection;
}

- (void)updateCollection {
	MPMediaQuery *everything = [[MPMediaQuery alloc] init];
	[everything setGroupingType: MPMediaGroupingArtist];
	s_collection = [everything items];
}

- (void)dealloc {
	[player release];
    [super dealloc];
}


@end
