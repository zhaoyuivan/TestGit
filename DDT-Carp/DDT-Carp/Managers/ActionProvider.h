//
//  ActionProvider.h
//  DDT-Carp
//
//  Created by Z on 14/12/17.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CCAction;
@class CCActionJumpTo;

@interface ActionProvider : NSObject
+(CCAction* )getPressBeginAction;
+(CCAction* )getPressEndAction;
+(CCAction* )getRepeatBlinkPrompt;
+(CCAction* )getRepeatScalePrompt;
+(CCAction* )getRepeatShakePrompt;
+(CCActionJumpTo* )getJumpInFromBottom:(CGPoint)endPosition andDuration:(double)duration;
+(CCActionJumpTo* )getJumpInFromTop:(CGPoint)endPosition andDuration:(double)duration;
+(CCActionJumpTo* )getJumpOutToBottomFrom:(CGPoint)currentPosition andEndPosition:(CGPoint)endPosition andDuration:(double)duration;
+(CCActionJumpTo* )getJumpOutToTopFrom:(CGPoint)currentPosition andEndPosition:(CGPoint)endPosition andDuration:(double)duration;
+(CCAction* )getRepeatSlowMove:(double)duration andDistance:(double)distance;
@end
