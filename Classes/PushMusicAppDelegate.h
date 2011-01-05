//
//  PushMusicAppDelegate.h
//  PushMusic
//
//  Created by Aaron Sarazan on 12/31/10.
//

#import <UIKit/UIKit.h>

@class PushMusic;

@interface PushMusicAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow * window;
	UIViewController * viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet UIViewController * viewController;

@end

