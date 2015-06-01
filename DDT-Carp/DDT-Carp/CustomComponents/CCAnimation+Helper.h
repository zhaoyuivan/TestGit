//
//  CCAnimation+Helper.h
//  SS
//
//  Created by Quankai on 13-8-22.
//  Copyright (c) 2013年 Quankai. All rights reserved.
//

#import "CCAnimation.h"

@interface CCAnimation (Helper)
+(CCAnimation*) animationWithFile:(NSString*)name withSuffix:(NSString* )suffixString frameCount:(int)frameCount delay:(float)delay;
+(CCAnimation*) animationWithFile:(NSString*)name frameCount:(int)frameCount delay:(float)delay;
+(CCAnimation*) animationWithFile:(NSString*)name frames:(NSArray *)frameList delay:(float)delay;
+(CCAnimation*) animationWithFile:(NSString*)name delay:(float)delay;
@end
