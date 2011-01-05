//
//  PushMusicViewController.h
//  PushMusic
//
//  Created by Aaron Sarazan on 1/4/11.
//  Copyright 2011 Spark Plug Games, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PushMusic;

@interface PushMusicViewController : UIViewController {
	PushMusic * pushMusic;
}

- (IBAction)updateServer;

@property (nonatomic, retain) PushMusic * pushMusic;

@end
