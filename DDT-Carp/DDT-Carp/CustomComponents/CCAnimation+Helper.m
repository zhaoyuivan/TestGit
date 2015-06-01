//
//  CCAnimation+Helper.m
//  SS
//
//  Created by Quankai on 13-8-22.
//  Copyright (c) 2013年 Quankai. All rights reserved.
//

#import "CCAnimation+Helper.h"
#import "cocos2d.h"

@implementation CCAnimation (Helper)

+(CCAnimation*) animationWithFile:(NSString*)name withSuffix:(NSString* )suffixString frameCount:(int)frameCount delay:(float)delay
{
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameCount];
    for (int i = 1; i <= frameCount; i++) {
        NSString* file = [NSString stringWithFormat:@"%@%d%@.png", name, i, suffixString];
        CCSpriteFrame* frame = [CCSpriteFrame frameWithImageNamed:file];
        [frames addObject:frame];
    }
    return [CCAnimation animationWithSpriteFrames:frames delay:delay];
}

+(CCAnimation*) animationWithFile:(NSString*)name frameCount:(int)frameCount delay:(float)delay
{
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameCount];
    for (int i = 1; i <= frameCount; i++) {
        NSString* file = [NSString stringWithFormat:@"%@%d.png", name, i];
        CCSpriteFrame* frame = [CCSpriteFrame frameWithImageNamed:file];
        [frames addObject:frame];
        }
    return [CCAnimation animationWithSpriteFrames:frames delay:delay];
}


+(CCAnimation*) animationWithFile:(NSString*)name frames:(NSArray *)frameList delay:(float)delay
{
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:[frameList count]];
    for (int i = 0; i < [frameList count]; i++) {
        NSString* file = [NSString stringWithFormat:@"%@%@.png", name, [frameList objectAtIndex:i]];
        CCSpriteFrame* frame = [CCSpriteFrame frameWithImageNamed:file];
        [frames addObject:frame];
    }
    return [CCAnimation animationWithSpriteFrames:frames delay:delay];
}

+(CCAnimation*) animationWithFile:(NSString*)name delay:(float)delay
{
    NSMutableArray* frames = [NSMutableArray array];
    
    NSString* file = [NSString stringWithFormat:@"%@.png", name];
    CCSpriteFrame* frame = [CCSpriteFrame frameWithImageNamed:file];
    [frames addObject:frame];
    
    return [CCAnimation animationWithSpriteFrames:frames delay:delay];
}

@end
