//
//  PushMusic.m
//  PushMusic
//
//  Created by Aaron Sarazan on 12/31/10.
//

#import "PushMusic.h"
#import "PushMusicPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <JSON/SBJsonStreamWriter.h>
#import "Utilities.h"
#import "Constants.h"

@implementation PushMusic

- (id)init {    
    self = [super init];
    if (self) {			
		defaults = [NSUserDefaults standardUserDefaults];
		player=[[PushMusicPlayer alloc] init];   
	}
    return self;
}

- (NSString *) getFullPath {
	NSString * tempDir = NSHomeDirectory();
	return [tempDir stringByAppendingFormat:@"/tmp/%@.txt",kPath];	
}

- (void) checkShouldSendLibrary {
	[self createSerializedCollection];
	NSURL * postURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@/%@",
										  [defaults stringForKey:kPrefServerIP],
										  [defaults stringForKey:kPrefServerPort],
										  kHashURLString,
										  [[UIDevice currentDevice] uniqueIdentifier]]];
	NSURLRequest * request = [NSURLRequest requestWithURL:postURL];
	myConnectionAsync = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
}

- (void) sendLibrary {	
	NSString * fullPath = [self getFullPath];
	NSString * checkString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:NULL];
	NSURL * postURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@/%@",
										  [defaults stringForKey:kPrefServerIP],
										  [defaults stringForKey:kPrefServerPort],
										  kPostURLString,
										  [Utilities md5:checkString]]];
	
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
	MPMediaQuery *everything = [[MPMediaQuery alloc] init];
	[everything setGroupingType: MPMediaGroupingArtist];
	NSArray * collection=[everything items];
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

- (BOOL)collectionExists {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self getFullPath]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if(connection==myConnectionAsync) {
		NSString * responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		NSString * jsonString = [NSString stringWithContentsOfFile:[self getFullPath] encoding:NSUTF8StringEncoding error:NULL];
		NSString * newSum = [Utilities md5:jsonString];
		NSLog(@"Got response %@ -- checking against %@\n",responseString,newSum);
		if(![responseString isEqualToString:newSum]) {
			[self sendLibrary];
		} else {
			//TODO notify already exists
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Failed!");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Connection Complete");
}

- (void)dealloc {
	[player release];
    [super dealloc];
}


@end
