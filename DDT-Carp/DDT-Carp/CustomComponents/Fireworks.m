//
//  Fireworks.m
//  DDT-LightReflection
//
//  Created by Z on 14-9-26.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "Fireworks.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"


@interface Fireworks ()
{
    BOOL _hasChild;
}
@end

@implementation Fireworks
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxScale = -1.f;
        self.minScale = -1.f;
        self.minLifeCycle = -1.f;
        self.maxLifeCycle = -1.f;
        self.distance = 300;
    }
    return self;
}
-(void)onEnter{
    [super onEnter];
    [self initSetting];
    [self createFireworks];
}

-(void)initSetting{
    _hasChild = NO;
    if (self.fireworkNumber == 0) {
        self.fireworkNumber = 10;
    }
    if (self.imageCount == 0) {
        self.imageCount = 1;
    }
    if (self.imageStingSuffix == nil) {
        self.imageStingSuffix = @"";
    }
    if (self.imageString == nil) {
        self.imageString = @"";
    }
}

-(void)createFireworks{
    for (int i = 0; i < self.fireworkNumber; i++) {
        CGFloat scale = arc4random()%((self.maxScale <= 0.f && self.minScale <= 0.f) ? 5 : (int)((self.maxScale - self.minScale)*10))*0.1 + (self.minScale > 0.f ? self.minScale : 0.6f);
        CGFloat angle = arc4random()%(360/self.fireworkNumber) + 360.0f/self.fireworkNumber * i;
        CGFloat lifecycle = arc4random()%((self.maxLifeCycle > 0.f && self.minLifeCycle > 0.f) ? (int)((self.maxLifeCycle - self.minLifeCycle)*10) : 30) * 0.1 + (self.minLifeCycle > 0.f ? self.minLifeCycle : 3.0f);
        int type = i%self.imageCount + 1;
        [self createAFireworkWithScale:scale andAngle:angle andLifeCycle:lifecycle andType:type];
    }
}

-(void)createAFireworkWithScale:(CGFloat)scale andAngle:(CGFloat)angle andLifeCycle:(CGFloat)lifeCycle andType:(int)type{
    CCSprite* spotSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@%d%@.png", self.imageString, type, self.imageStingSuffix]];
    spotSprite.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    spotSprite.scale = scale;
    spotSprite.rotation = angle;
    [self addChild:spotSprite];
    _hasChild = YES;
    float y = cosf(angle/180*M_PI) * self.distance;
    float x = sinf(angle/180*M_PI) * self.distance;
    CCActionMoveTo* moveAction = [CCActionMoveTo actionWithDuration:lifeCycle position:ccp(spotSprite.position.x + x, spotSprite.position.y + y)];
    CCActionScaleTo* scaleAction = [CCActionScaleTo actionWithDuration:lifeCycle scale:0];
    CCActionFadeTo* fadeAction = [CCActionFadeTo actionWithDuration:lifeCycle opacity:self.isFadeToZero ? 0 : spotSprite.opacity];
    
    [spotSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:moveAction, scaleAction, fadeAction, nil], [CCActionCallBlock actionWithBlock:^{
        [spotSprite removeFromParent];
    }], nil]];
}

-(void)update:(CCTime)delta{
    if (_hasChild) {
        if (self.children.count == 0) {
            [self removeFromParent];
        }
    }
}
@end
