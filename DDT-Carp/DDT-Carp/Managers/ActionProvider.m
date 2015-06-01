//
//  ActionProvider.m
//  DDT-Carp
//
//  Created by Z on 14/12/17.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "ActionProvider.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"

@implementation ActionProvider
+(CCAction* )getPressBeginAction{
    return [CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.1f scale:1.15], [CCActionScaleTo actionWithDuration:0.1f scale:0.95], [CCActionScaleTo actionWithDuration:0.1f scale:1.1], nil];
}

+(CCAction* )getPressEndAction{
    return [CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.1f scale:0.95], [CCActionScaleTo actionWithDuration:0.1f scale:1.05], [CCActionScaleTo actionWithDuration:0.1f scale:1.f], nil];
}

+(CCAction* )getRepeatBlinkPrompt{
    return [CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionBlink actionWithDuration:0.8f blinks:3], nil]];
}

+(CCAction* )getRepeatScalePrompt{
    return [CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.2f scale:1.2f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.2f scale:0.9f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.1f scale:1.05f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.1f scale:1.f], [CCActionDelay actionWithDuration:0.8f], nil]];
}

+(CCAction* )getRepeatShakePrompt{
    return [CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRepeat actionWithAction:[CCActionSequence actions:[CCActionRotateTo actionWithDuration:0.1f angle:10], [CCActionDelay actionWithDuration:0.f], [CCActionRotateTo actionWithDuration:0.1f angle:-10], [CCActionDelay actionWithDuration:0.f], nil] times:3], [CCActionDelay actionWithDuration:2.f], nil]];
}

+(CCActionJumpTo* )getJumpInFromBottom:(CGPoint)endPosition andDuration:(double)duration{
    return [CCActionJumpTo actionWithDuration:duration position:endPosition height:endPosition.y + 20 jumps:1];
}

+(CCActionJumpTo* )getJumpInFromTop:(CGPoint)endPosition andDuration:(double)duration{
    return [CCActionJumpTo actionWithDuration:duration position:endPosition height:endPosition.y - 20 jumps:1];
}

+(CCActionJumpTo* )getJumpOutToBottomFrom:(CGPoint)currentPosition andEndPosition:(CGPoint)endPosition andDuration:(double)duration{
    return [CCActionJumpTo actionWithDuration:duration position:endPosition height:currentPosition.y + 20 jumps:1];
}

+(CCActionJumpTo* )getJumpOutToTopFrom:(CGPoint)currentPosition andEndPosition:(CGPoint)endPosition andDuration:(double)duration{
    return [CCActionJumpTo actionWithDuration:duration position:endPosition height:currentPosition.y - 20 jumps:1];
}

+(CCAction* )getRepeatSlowMove:(double)duration andDistance:(double)distance{
    return [CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:duration position:ccp(distance, 0)], [CCActionDelay actionWithDuration:0.2f], [CCActionMoveBy actionWithDuration:duration position:ccp(-distance, 0)], [CCActionDelay actionWithDuration:0.2f], nil]];
}
@end
