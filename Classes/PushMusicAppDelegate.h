//
//  PushMusicAppDelegate.h
//  PushMusic
//
//  Created by Aaron Sarazan on 12/31/10.
//

#import <UIKit/UIKit.h>

@class PushMusic;

@interface PushMusicAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	PushMusic * pushMusic;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) PushMusic * pushMusic;

@end

