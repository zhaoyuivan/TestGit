//
//  BubbleBlowNode.m
//  DDT-Carp
//
//  Created by Z on 14/12/10.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "BubbleBlowNode.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"

#define INTERVAL 0.3f

@interface BubbleBlowNode ()
{
    CGFloat _interval;
}
@end

@implementation BubbleBlowNode
- (instancetype)init
{
    self = [super init];
    if (self) {
        _interval = 0.f;
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
}

-(void)update:(CCTime)delta{
    _interval += delta;
    if (self.isRepeat) {
        if (_interval >= INTERVAL) {
            _interval = 0.f;
            [self createBubbles];
        }
    }
}

-(void)createBubbles{
    for (int i = 0; i < self.bubbleNum; i++) {
        NSString* imageName = self.imagesArray[arc4random()%self.imagesArray.count];
        CGPoint startPos = ccp(self.startX, self.startYRange.location + arc4random()%self.startYRange.length);
        CGFloat startScale = (self.startScaleRange.location + arc4random()%self.startScaleRange.length) * 0.1f;
        [self createABubbleWithImage:imageName andStartPos:startPos andStartScale:startScale];
    }
}

-(void)createABubbleWithImage:(NSString* )imageName andStartPos:(CGPoint)startPos andStartScale:(CGFloat)startScale{
    CCSprite* bubble = [CCSprite spriteWithImageNamed:imageName];
    bubble.position = startPos;
    bubble.scale = startScale;
    [self addChild:bubble];
    __block CCSprite* bubbleTemp = bubble;
    [bubble runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:(arc4random()%3) * 0.1f], [CCActionSpawn actions:[CCActionMoveBy actionWithDuration:self.duration position:ccp(self.distance, 0)], [CCActionScaleTo actionWithDuration:self.duration scale:0], [CCActionFadeTo actionWithDuration:self.duration opacity:0], nil], [CCActionCallBlock actionWithBlock:^{
        [bubbleTemp removeFromParent];
    }], nil]];
}

-(void)dealloc{
    
}

@end
