//
//  SparkNode.m
//  DDT-Carp
//
//  Created by Z on 14/11/2.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "SparkNode.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"

@interface SparkNode ()
{
    
}
@end

@implementation SparkNode
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageNamesArray = nil;
        self.direction = none;
        self.imageAngleOffset = 0.f;
        self.duration = 1.f;
        self.numberOfDirections = 4;
        self.distance = 100;
        self.isDestroySelf = YES;
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createSpark];
}

-(void)createSpark{
    CGFloat angle = 360.f/self.numberOfDirections;
    for (int i = 0; i < self.numberOfDirections; i++) {
        CCSprite* sprite = [CCSprite spriteWithImageNamed:self.imageNamesArray[i%self.imageNamesArray.count]];
        sprite.anchorPoint = ccp(0.5f, 0.f);
        sprite.position = [self convertToNodeSpace:self.position];
        sprite.rotation = i * angle;
        [self addChild:sprite z:1];
        [self runSparkActions:sprite];
    }
}

-(void)runSparkActions:(CCSprite* )sprite{
    CGFloat y = cos(sprite.rotation/180.f*M_PI) * self.distance;
    CGFloat x = sin(sprite.rotation/180.f*M_PI) * self.distance;
    sprite.rotation -= self.imageAngleOffset;
    [sprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:self.duration position:ccp(sprite.position.x + x, sprite.position.y + y)], [CCActionScaleTo actionWithDuration:self.duration scaleX:1 scaleY:0], nil], [CCActionCallBlock actionWithBlock:^{
        if(self.isDestroySelf){
            [sprite removeFromParent];
        }
        else{
            sprite.position = [self convertToNodeSpace:self.position];
            sprite.scale = 1;
            [self runSparkActions:sprite];
        }
    }], nil]];
}

-(void)update:(CCTime)delta{
    if (self.children.count == 0) {
        [self removeFromParent];
    }
}









@end
