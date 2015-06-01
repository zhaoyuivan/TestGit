//
//  FishMoveSprite.m
//  DDT-Carp
//
//  Created by Z on 14/12/26.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "FishMoveSprite.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"

@interface FishMoveSprite ()
{
    
}
@end

@implementation FishMoveSprite
-(id)initWithImageNamed:(NSString *)imageName withScale:(CGFloat)scale andDelayTime:(CGFloat)delayTime{
    if (self = [super initWithImageNamed:imageName]) {
        self.scale = scale;
        self.delayTime = delayTime;
        self.opacity = 0.f;
        [self createARiverFish];
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
}

-(void)createARiverFish{
    CGPoint crucialPositions[] = {ccp(188, 800), ccp(118, 585), ccp(159, 358), ccp(388, 270)};
    CGPoint control_1_Positions[] = {ccp(208, 616), ccp(69, 518), ccp(233, 332)};
    CGPoint control_2_Positions[] = {ccp(158, 640), ccp(100, 378), ccp(305, 416)};
    CGFloat controlRotations_1[] = {5.f, -20.f, -65.f};
    CGFloat controlRotations_2[] = {35.f, -80.f, -45.f};
    CGFloat reverseControlRotations_1[] = {175.f, 155.f, 85.f};
    CGFloat reverseControlRotations_2[] = {180.f, 215.f, 95.f};
    CGFloat durations[] = {4.f + arc4random()%3, 4.f + + arc4random()%3, 4.f + + arc4random()%3};
    BOOL isReverse = arc4random()%2 ? NO : YES;
    self.position = isReverse ? crucialPositions[3] : crucialPositions[0];
    self.rotation = isReverse ? 135.f : 0.f;
    NSMutableArray* movesArray = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < 3; i++) {
        int offset = arc4random()%30;
        CGPoint offSetPoint = ccp(((arc4random()%2) ? -1 :1) * offset, 0);
        ccBezierConfig bezierMove;
        bezierMove.endPosition = ccpAdd(crucialPositions[i + 1], offSetPoint);
        bezierMove.controlPoint_1 = ccpAdd(control_1_Positions[i], offSetPoint);
        bezierMove.controlPoint_2 = ccpAdd(control_2_Positions[i], offSetPoint);
        CCActionSpawn* oneMove = [CCActionSpawn actions:[CCActionBezierTo actionWithDuration:durations[i] bezier:bezierMove], [CCActionSequence actions:[CCActionRotateTo actionWithDuration:durations[i]/2.f angle:controlRotations_1[i]], [CCActionRotateTo actionWithDuration:durations[i]/2.f angle:controlRotations_2[i]], nil], nil];
        [movesArray addObject:oneMove];
    }
    
//    reverse
    for (int i = 2 ; i >= 0; i--) {
        int offset = arc4random()%20;
        CGPoint offSetPoint = ccp(((arc4random()%2) ? -1 :1) * offset, 0);
        ccBezierConfig bezierMove;
        bezierMove.endPosition = ccpAdd(crucialPositions[i], offSetPoint);
        bezierMove.controlPoint_1 = ccpAdd(control_2_Positions[i], offSetPoint);
        bezierMove.controlPoint_2 = ccpAdd(control_1_Positions[i], offSetPoint);
        CCActionSpawn* oneMove = [CCActionSpawn actions:[CCActionBezierTo actionWithDuration:durations[i] bezier:bezierMove], [CCActionSequence actions:[CCActionRotateTo actionWithDuration:durations[i]/2.f angle:reverseControlRotations_1[i]], [CCActionRotateTo actionWithDuration:durations[i]/2.f angle:reverseControlRotations_2[i]], nil], nil];
        [movesArray addObject:oneMove];
    }
    
    CGFloat totalMoveTime = durations[0] + durations[1] + durations[2];
    CGFloat fadeOutDelayTime = arc4random()%(int)(totalMoveTime - 2 - 3);
    CGFloat fadeInDelayTime = 1 + arc4random()%(int)(totalMoveTime - 2 - 3 - 1 - fadeOutDelayTime);
    CGFloat restDelayTime = totalMoveTime - 3 - fadeOutDelayTime - fadeInDelayTime;
    _defaultOpacity = 0.3f + arc4random()%6 * 0.1f;
    
    CCActionSpawn* formalMove = [CCActionSpawn actions:
                                 [CCActionSequence actions:[CCActionDelay actionWithDuration:0.f], movesArray[0], movesArray[1], movesArray[2], nil],
                                 [CCActionSequence actions:[CCActionDelay actionWithDuration:0.f], [CCActionFadeTo actionWithDuration:0.f opacity:_defaultOpacity], [CCActionDelay actionWithDuration:fadeOutDelayTime], [CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionDelay actionWithDuration:fadeInDelayTime], [CCActionFadeTo actionWithDuration:1.f opacity:_defaultOpacity], [CCActionDelay actionWithDuration:restDelayTime], [CCActionFadeTo actionWithDuration:1.f opacity:0.f], nil],
                                 nil];
    CCActionSpawn* reverseMove = [CCActionSpawn actions:
                                  [CCActionSequence actions:[CCActionDelay actionWithDuration:0.f], movesArray[3], movesArray[4], movesArray[5], nil],
                                  [CCActionSequence actions:[CCActionDelay actionWithDuration:0.f], [CCActionFadeTo actionWithDuration:1.f opacity:_defaultOpacity], [CCActionDelay actionWithDuration:fadeOutDelayTime], [CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionDelay actionWithDuration:fadeInDelayTime], [CCActionFadeTo actionWithDuration:1.f opacity:_defaultOpacity], [CCActionDelay actionWithDuration:restDelayTime], [CCActionFadeTo actionWithDuration:0.f opacity:0.f], nil],
                                  nil];
    
    [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:self.delayTime], [CCActionCallBlock actionWithBlock:^{
        [self runAction:[CCActionRepeatForever actionWithAction:
                         [CCActionSequence actions:
                          isReverse ? reverseMove : formalMove,
                          [CCActionRotateBy actionWithDuration:0.f angle:180.f],
                          isReverse ? formalMove : reverseMove,
                          [CCActionRotateBy actionWithDuration:0.f angle:180.f],
                          nil]]];
    }], nil]];
    
    
}
@end
