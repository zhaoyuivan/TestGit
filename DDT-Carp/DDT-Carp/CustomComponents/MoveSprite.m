//
//  MoveSprite.m
//  DDT-Carp
//
//  Created by Z on 14/10/31.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "MoveSprite.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "CCTextureCache.h"

@interface MoveSprite ()
{
    CGFloat _initScale;
    BOOL _isFirstMove;
    BOOL _isMoving;
}
@end

@implementation MoveSprite
-(void)onEnter{
    [super onEnter];
}

-(id)initWithImageNamed:(NSString *)imageName{
    self = [super initWithImageNamed:imageName];
    if (self) {
        [self setting];
    }
    return self;
}

-(void)setIsMoveStart:(BOOL)isMoveStart{
    _isMoveStart = isMoveStart;
    [self preMove];
}

-(void)setting{
    _isFirstMove = YES;
    _isMoving = NO;
    _initScale = self.scale;
}

-(void)preMove{
    if (!self.isMoveStart) {
        self.paused = YES;
        _isMoving = NO;
        return;
    }
    else{
        self.paused = NO;
        if (_isMoving) {
            return;
        }
        else{
            if (!_isFirstMove) {
//                resume
            }
            else{
                [self move];
            }
        }
    }
}

-(void)move{
    _isFirstMove = NO;
    _isMoving = YES;
    if (self.randomStartPoint) {
        int y = (int)(self.startPointHigh.y - self.startPointLow.y);
        self.startPoint = ccp(self.startPointHigh.x, arc4random()%y + self.startPointLow.y);
    }
    self.position = self.startPoint;
    if (self.randomEndPoint) {
        int y = (int)(self.endPointHigh.y - self.endPointLow.y);
        self.endPoint = ccp(self.endPointHigh.x, arc4random()%y + self.endPointLow.y);
    }
    self.scale = _initScale;
    CGFloat duration = self.isRandomDuration ? self.duration + arc4random()%11 * 0.1f : self.duration;
    __unsafe_unretained MoveSprite* weakSelf = self;
    if(self.isBezierMove){
        ccBezierConfig bezierConfig;
        bezierConfig.controlPoint_1 = ccp(self.startPoint.x + (self.endPoint.x - self.startPoint.x)/2, self.endPoint.y + (self.isBezierMove ? -10 : 0));
        bezierConfig.controlPoint_2 = bezierConfig.controlPoint_1;
        bezierConfig.endPosition = self.endPoint;
        
        [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:self.delayCreationTime], [CCActionSpawn actions:[CCActionBezierTo actionWithDuration:duration bezier:bezierConfig], [CCActionScaleTo actionWithDuration:duration scale:self.endScale], nil],  [CCActionCallBlock actionWithBlock:^{
            weakSelf.delayCreationTime = 0.f;
            if (weakSelf.isDetroySelf) {
                [weakSelf removeFromParent];
            }
            else{
                if (weakSelf.cycleBlock) {
                    weakSelf.cycleBlock();
                }
                [weakSelf move];
            }
        }], nil]];
    }
    else{
        [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:self.delayCreationTime], [CCActionSpawn actions:[CCActionMoveTo actionWithDuration:duration position:self.endPoint], [CCActionScaleTo actionWithDuration:duration scale:self.endScale], nil],  [CCActionCallBlock actionWithBlock:^{
            weakSelf.delayCreationTime = 0.f;
            if (weakSelf.isDetroySelf) {
                [weakSelf removeFromParent];
            }
            else{
                if (weakSelf.cycleBlock) {
                    weakSelf.cycleBlock();
                }
                [weakSelf move];
            }
        }], nil]];
    }
}

-(void)onExit{

    [super onExit];
}

-(void)dealloc{
    self.cycleBlock = nil;
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

@end
