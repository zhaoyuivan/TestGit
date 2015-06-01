//
//  BubbleRise.m
//  DDT-Carp
//
//  Created by Z on 14/10/27.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "BubbleRise.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"

@interface BubbleRise ()
{
    NSInteger _dispearCount;
    NSInteger _count;
}
@end

@implementation BubbleRise
-(void)onEnter{
    [super onEnter];
    [self createBubbles];
}

-(void)createBubbles{
    _dispearCount = 0;
    _count = self.randomNumberOfBubbles ? self.numberOfBubbles + arc4random()%3 : self.numberOfBubbles;
    for (int i = 0; i < _count; i++) {
        NSString* imageString = [NSString stringWithFormat:@"%@%ld%@.png", self.imageName, (long)(arc4random()%self.numberOfImages + 1), self.imageSuffixName];
        CCSprite* bubbleSprite = [CCSprite spriteWithImageNamed:imageString];
        CGPoint position = ccp(self.position.x + i%2 * (-1) * arc4random()%30 , self.position.y + i%2 * (-1) * arc4random()%30);
        bubbleSprite.position = [self convertToNodeSpace:position];
        bubbleSprite.scale = 0;
        bubbleSprite.opacity = arc4random()%4 * 0.1 + 0.f;
        [self addChild:bubbleSprite z:1];
        CGFloat delay = arc4random()%5 * 0.1 + i * 0.8f;
        [self runBubbleAction:bubbleSprite withDelay:delay];
    }
}

-(void)runBubbleAction:(CCSprite* )bubble withDelay:(NSTimeInterval )delay{
    CGFloat maxHeight = self.riseHeight ? self.riseHeight : 768 + bubble.contentSize.height;
    CGFloat riseTime = self.riseTime ? self.riseTime : (maxHeight - bubble.position.y)/50.0f;
    [bubble runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:delay], [CCActionSpawn actions:[CCActionScaleTo actionWithDuration:1.f scale:1], [CCActionMoveTo actionWithDuration:riseTime position:ccp(bubble.position.x, maxHeight)], nil], [CCActionCallBlock actionWithBlock:^{
        _dispearCount++;
        [bubble removeFromParent];
    }], nil]];
}

-(void)update:(CCTime)delta{
    if (_dispearCount == _count) {
        if (self.isDestroySelf) {
            [self removeFromParent];
        }
        else{
            _dispearCount = 0;
            [self performSelector:@selector(createBubbles) withObject:nil afterDelay:1.f];
        }
    }
}

@end
