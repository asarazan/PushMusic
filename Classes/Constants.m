//
//  Constants.m
//  PushMusic
//
//  Created by Aaron Sarazan on 1/8/11.
//  Copyright 2011 Spark Plug Games, LLC. All rights reserved.
//

#import "Constants.h"

#pragma mark -
#pragma mark PushMusic

NSString * const kDeviceID=			@"deviceId";
NSString * const kName=				@"name";
NSString * const kSongs=			@"songs";
NSString * const kArtist=			@"artist";
NSString * const kAlbum=			@"album";
NSString * const kTitle=			@"title";
NSString * const kTrackNumber=		@"trackNumber";
NSString * const kSongID=			@"id";

NSString * const kPostURLString=	@"device";
NSString * const kHashURLString=	@"hash";
NSString * const kPath=				@".jsonstorage";

//God-willing, we won't need to use this again.
NSString * const kTestJSON=			@"{\"deviceId\":\"d9db5c1b3386c6149ea468dd831423e8f182ef20\",\"name\":\"Robby's iPhone\","
									"\"songs\":[	{\"title\":\"A-Punk\",\"album\":\"Vampire Weekend\",\"trackNumber\":3,\"id\":15398368358004135853,\"artist\":\"Vampire Weekend\"},"
									"{\"title\":\"A.D.D\",\"album\":\"Steal This Album!\",\"trackNumber\":7,\"id\":14017898169059185142,\"artist\":\"System of a Down\"} ] }";

#pragma mark PushMusicPlayer
NSString * const kGetURLString =	@"check";
NSString * const kTestID =			@"14017898169059185142";

#pragma mark Universal
NSString * const kPrefServerIP=		@"pref_server_ip";
NSString * const kPrefServerPort=	@"pref_server_port";

@implementation Constants

@end
