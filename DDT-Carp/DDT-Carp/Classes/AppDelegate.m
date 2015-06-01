//
//  AppDelegate.m
//  DDT-Carp
//
//  Created by Z on 15/1/30.
//  Copyright ZY 2015年. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "IntroScene.h"
#import "HelloWorldScene.h"
#import "ContentScene.h"

@implementation AppDelegate

// 
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
	// This method is a good place to add one time setup code that only runs when your app is first launched.
	
	// Setup Cocos2D with reasonable defaults for everything.
	// There are a number of simple options you can change.
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.
	[self setupCocos2dWithOptions:@{
		// Show the FPS and draw call label.
		CCSetupShowDebugStats: @(YES),
		
		// More examples of options you might want to fiddle with:
		// (See CCAppDelegate.h for more information)
		
		// Use a 16 bit color buffer: 
//		CCSetupPixelFormat: kEAGLColorFormatRGB565,
		// Use a simplified coordinate system that is shared across devices.
//		CCSetupScreenMode: CCScreenModeFixed,
//        clippingNode 遮挡需要
        CCSetupDepthFormat: @GL_DEPTH24_STENCIL8_OES,
		// Run in portrait mode.
//		CCSetupScreenOrientation: CCScreenOrientationPortrait,
		// Run at a reduced framerate.
//		CCSetupAnimationInterval: @(1.0/30.0),
		// Run the fixed timestep extra fast.
//		CCSetupFixedUpdateInterval: @(1.0/180.0),
		// Make iPad's act like they run at a 2x content scale. (iPad retina 4x)
//		CCSetupTabletScale2X: @(YES),
	}];
	
	return YES;
}

-(CCScene *)startScene
{
	// This method should return the very first scene to be run when your app starts.
	return [ContentScene scene];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
    if( [navController_ visibleViewController] == [CCDirector sharedDirector] )
        [[CCDirector sharedDirector] stopAnimation];
//    submarine tip
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"submarine"];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    if( [navController_ visibleViewController] == [CCDirector sharedDirector] )
        [[CCDirector sharedDirector] startAnimation];
//    submarine tip
    [[NSUserDefaults standardUserDefaults] setObject:@"tip" forKey:@"submarine"];
}



@end
