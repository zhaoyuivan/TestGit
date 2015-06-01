//
//  ObserveBaseScene.m
//  DDT-Carp
//
//  Created by Z on 15/2/3.
//  Copyright (c) 2015年 ZY. All rights reserved.
//

#import "ObserveBaseScene.h"
#import "BubbleRise.h"

#define FISHORDER 100

@interface ObserveBaseScene ()
{
//    bubble
    BOOL _bubbleStart;
    CGFloat _createBubbleTime;
}
@end

@implementation ObserveBaseScene
- (instancetype)init
{
    self = [super init];
    if (self) {
        _backgroundNode = [CCNode node];
        _backgroundNode.contentSize = [[CCDirector sharedDirector] viewSize];
        _backgroundNode.anchorPoint = ccp(0, 0);
        _backgroundNode.position = ccp(0, 0);
        [self addChild:_backgroundNode z:1];
        
        _observedSpriteArray = [[NSMutableArray alloc] init];
        _bubbleStart = YES;
        _createBubbleTime = 10.f;
    }
    return self;
}

-(void)update:(CCTime)delta{
    if (_bubbleStart) {
        _createBubbleTime += delta;
        if (_createBubbleTime >= 10.f) {
            _createBubbleTime = 0.f;
            BubbleRise* bubbleRise = [BubbleRise node];
            CGFloat x = 100.0 + arc4random()%650;
            CGFloat y = 50.0 + arc4random()%50;
            bubbleRise.position = ccp(x, y);
            bubbleRise.numberOfBubbles = 4;
            bubbleRise.riseTime = (768 + bubbleRise.contentSize.height)/70.f;
            bubbleRise.randomNumberOfBubbles = YES;
            bubbleRise.imageName = @"bubble";
            bubbleRise.imageSuffixName = @"_puzzle";
            bubbleRise.numberOfImages = 4;
            bubbleRise.isDestroySelf = YES;
            [_backgroundNode addChild:bubbleRise z:1];
        }
    }
}

-(void)createObservedSprite{
//    observer
    CCSprite* handleSprite = [CCSprite spriteWithImageNamed:@"handle_observe.png"];
    handleSprite.position = ccp(598/2.f, 768 - 246.5/2.f);
    [_backgroundNode addChild:handleSprite z:1000];
    
    CCSprite* leftHook = [CCSprite spriteWithImageNamed:@"hook_left_observe.png"];
    leftHook.anchorPoint = ccp(1.f, 1.f);
    leftHook.position = [handleSprite convertToNodeSpace:ccp(524.5/2.f + leftHook.contentSize.width/2.f, 768 - 545/2.f + leftHook.contentSize.height/2.f)];
    [handleSprite addChild:leftHook z:-1];
    
    CCSprite* rightHook = [CCSprite spriteWithImageNamed:@"hook_right_observe.png"];
    rightHook.anchorPoint = ccp(0.f, 1.f);
    rightHook.position = [handleSprite convertToNodeSpace:ccp(686.5/2.f - rightHook.contentSize.width/2.f, 768 - 541.5/2.f + rightHook.contentSize.height/2.f)];
    [handleSprite addChild:rightHook z:-1];
    
    _observerSprite = [TouchSprite spriteWithImageNamed:@"magnifier_skew_observe.png"];
    _observerSprite.position = [handleSprite convertToNodeSpace: ccp(632.5/2.f, 768 - 670.5/2.f)];
    _observerSprite.userInteractionEnabled = NO;
    [handleSprite addChild:_observerSprite z:1];
    
    __unsafe_unretained ObserveBaseScene* weakSelf = self;
    _observerSprite.touchBegan = ^(UITouch* touch){
        [weakSelf observerTouchBegan:touch];
    };
    
    _observerSprite.touchMoved = ^(UITouch* touch){
        [weakSelf observerTouchMoved:touch];
    };
    
    _observerSprite.touchEnded = ^(UITouch* touch){
        [weakSelf observerTouchEnded:touch];
    };
    
    _observerSprite.touchCanceled = ^(UITouch* touch){
        [weakSelf observerTouchCanceled:touch];
    };
    
    handleSprite.position = ccp(1300 , handleSprite.position.y);
    [handleSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.2f position:ccp(598/2.f, 768 - 246.5/2.f)], [CCActionCallBlock actionWithBlock:^{
        [leftHook runAction:[CCActionSequence actions:[CCActionRotateTo actionWithDuration:0.5f angle:7.f], [CCActionDelay actionWithDuration:1.f], [CCActionRotateTo actionWithDuration:0.5f angle:0.f], nil]];
        
        [rightHook runAction:[CCActionSequence actions:[CCActionRotateTo actionWithDuration:0.5f angle:-2.f], [CCActionDelay actionWithDuration:1.f], [CCActionRotateTo actionWithDuration:0.5f angle:0.f], nil]];
        
        [_observerSprite removeFromParent];
        _observerSprite.position = [handleSprite convertToWorldSpace:_observerSprite.position];
        [_backgroundNode addChild:_observerSprite z:1000];
        _observerSprite.userInteractionEnabled = YES;
        CGFloat distance = _observerSprite.position.y - 50;
        CCTime duration = distance/100.f;
        [_observerSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:duration position:ccp(640/2.f, 50)], [CCActionRotateTo actionWithDuration:duration angle:-85], nil], nil]];
        
        [handleSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionMoveTo actionWithDuration:1.f position:ccp(-300, handleSprite.position.y)], nil]];
    }], nil]];
    
//    observed sprites
    int count = _observedCount;
    for (int i = 0; i < count; i++) {
        CCSprite* observedSprite = [CCSprite spriteWithImageNamed:count == 1 ? [NSString stringWithFormat:@"%@_observe.png", _observedName] : [NSString stringWithFormat:@"%@%d_observe.png", _observedName, i + 1]];
        observedSprite.opacity = 0;
        observedSprite.name = count == 1 ? _observedName : [NSString stringWithFormat:@"%@%d", _observedName, i + 1];
        observedSprite.position = count == 1 ? [_observedPositions.firstObject CGPointValue] : [_observedPositions[i] CGPointValue];
        [_backgroundNode addChild:observedSprite z:FISHORDER + 2];
        [_observedSpriteArray addObject:observedSprite];
        [observedSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionDelay actionWithDuration:3.f], [CCActionCallBlock actionWithBlock:^{
            [observedSprite runAction:[ActionProvider getRepeatBlinkPrompt]];
        }], nil]];
    }
}

-(void)observerTouchBegan:(UITouch* )touch{
    [_observerSprite stopAllActions];
    _observerSprite.userInteractionEnabled = NO;
    _observerSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"magnifier_real_observe.png"];
    _observerSprite.rotation = 0.f;
    _observerSprite.position = [touch locationInNode:_backgroundNode];
    __unsafe_unretained ObserveBaseScene* weakSelf = self;
    _observerSprite.touchMoved = ^(UITouch* touch){
        [weakSelf observerTouchMoved:touch];
    };
}

-(void)observerTouchMoved:(UITouch* )touch{
    CGPoint center = CGPointZero;
    NSString* name = nil;
    if (_observedSpriteArray.count == 2) {
        center = ccpMidpoint([(CCSprite* )_observedSpriteArray.firstObject position], [(CCSprite* )_observedSpriteArray.lastObject position]);
        name = [[(CCSprite* )_observedSpriteArray.firstObject name] substringToIndex:[(CCSprite* )_observedSpriteArray.firstObject name].length - 1];
    }
    else{
        center = [(CCSprite* )_observedSpriteArray.firstObject position];
        name = [(CCSprite* )_observedSpriteArray.firstObject name];
    }
    CGRect rect = CGRectMake(center.x - 150, center.y - 150, 300, 300);
    if (CGRectContainsPoint(rect, _observerSprite.position)) {
//        watching
        for (CCSprite* observedSprite in _observedSpriteArray) {
            [observedSprite stopAllActions];
            observedSprite.visible = YES;
        }
        _observerSprite.userInteractionEnabled = NO;
        _observerSprite.zOrder = FISHORDER + 3;
        [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"observe%@",name.capitalizedString]) withObject:nil afterDelay:0.f];
        _observerSprite.touchMoved = nil;
    }
    else{
        _observerSprite.position = [touch locationInNode:_backgroundNode];
    }
    //    NSLog(@"%@", NSStringFromCGPoint(_observerSprite.position));
}

-(void)observerTouchEnded:(UITouch* )touch{
    _observerSprite.userInteractionEnabled = NO;
    _observerSprite.touchMoved = nil;
    CGPoint center = CGPointZero;
    NSString* name = nil;
    if (_observedSpriteArray.count == 2) {
        center = ccpMidpoint([(CCSprite* )_observedSpriteArray.firstObject position], [(CCSprite* )_observedSpriteArray.lastObject position]);
        //        NSLog(@"%@", NSStringFromCGPoint(center));
        name = [[(CCSprite* )_observedSpriteArray.firstObject name] substringToIndex:[(CCSprite* )_observedSpriteArray.firstObject name].length - 1];
    }
    else{
        center = [(CCSprite* )_observedSpriteArray.firstObject position];
        name = [(CCSprite* )_observedSpriteArray.firstObject name];
    }
    CGRect rect = CGRectMake(center.x - 150, center.y - 150, 300, 300);
    if (CGRectContainsPoint(rect, _observerSprite.position)) {
//        watching
        for (CCSprite* observedSprite in _observedSpriteArray) {
            [observedSprite stopAllActions];
            observedSprite.visible = YES;
        }
        _observerSprite.zOrder = FISHORDER + 3;
        [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"observe%@", name.capitalizedString]) withObject:nil afterDelay:0.f];
        [_observerSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.1f position:ccp(center.x + 150/4, center.y - 150/4)], nil]];
    }
    else{
        [self observerGoDown];
    }
}

-(void)observerTouchCanceled:(UITouch* )touch{
    _observerSprite.touchMoved = nil;
    [self observerGoDown];
}

-(void)observerGoDown{
    _observerSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"magnifier_small_observe.png"];
    _observerSprite.userInteractionEnabled = YES;
    
    CGFloat distance = _observerSprite.position.y - 40;
    CCTime duration = distance > 0 ? distance/100.f : 0.5f;
    [_observerSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:duration position:ccp(_observerSprite.position.x, 40)], [CCActionRotateTo actionWithDuration:duration angle:-45.f], nil], nil]];
}

-(void)onExit{
    self.observedPositions = nil;
    [self.observedSpriteArray removeAllObjects];
    [super onExit];
}

@end
