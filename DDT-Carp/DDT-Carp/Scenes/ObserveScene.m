//
//  ObserveScene.m
//  DDT-Carp
//
//  Created by Z on 14/10/30.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "ObserveScene.h"
#import "CCTextureCache.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "TouchSprite.h"
#import "BubbleRise.h"
#import "CCAnimation+Helper.h"
#import "MoveSprite.h"
#import "SparkNode.h"
#import "Fireworks.h"
#import "FishSprite.h"

#import "LiveEnvironmentScene.h"
#import "ContentScene.h"
#import "SubmarineScene.h"

#define FISHORDER 100
#define O2NUMBER 4
#define CO2NUMBER 8

@interface ObserveScene ()<CCPhysicsCollisionDelegate>
{
    CCNode* _backgroundNode;
    CCSprite* _fishSprite;
    TouchSprite* _observerSprite;
    CCSprite* _observedSprite;
    CCClippingNode* _observedClNode;
    TouchSprite* _goNextSprite;
    BOOL _isShowAnimation;
    NSMutableArray* _observedNames;
    NSMutableArray* _observedPositions;
    BOOL _isSceneOver;
    
//    bubble
    BOOL _bubbleStart;
    CGFloat _createBubbleTime;
    
//    bladder
    BOOL _physicsLauched;
    BOOL _isTouchBladder;
    CCSprite* _bladderSprite;
}
@end

@implementation ObserveScene
+(ObserveScene *)scene{
    return [[self alloc] init];
}

+(ObserveScene *)sceneForBladder{
    return [[self alloc] initForBladder:@"bladder"];
}

-(id)initForBladder:(NSString* )bladder{
    self = [super init];
    if (self) {
        _isSceneOver = NO;
        _physicsLauched = NO;
        _isTouchBladder = NO;
        _bubbleStart = YES;
        _createBubbleTime = 10.f;
        _isShowAnimation = NO;
        if (bladder == nil) {
            _observedNames = [NSMutableArray arrayWithObjects:@"gill", @"bladder", nil];
            _observedPositions = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(491.5/2, 768 - 989.5/2)], [NSValue valueWithCGPoint:ccp(962/2, 768 - 946/2)], nil];
        }
        else{
            _observedNames = [NSMutableArray arrayWithObjects:@"bladder", nil];
            _observedPositions = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(962/2, 768 - 946/2)], nil];
            self.step = 3;
        }
        //    _observedPositions = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(491.5/2, 768 - 989.5/2)], [NSValue valueWithCGPoint:ccp(962/2, 768 - 946/2)], nil];
        
        _backgroundNode = [CCNode node];
        _backgroundNode.contentSize = [[CCDirector sharedDirector] viewSize];
        _backgroundNode.anchorPoint = ccp(0, 0);
        _backgroundNode.position = ccp(0, 0);
        [self addChild:_backgroundNode z:1];
        
//        home
//        TouchSprite* homeSprite = [TouchSprite spriteWithImageNamed:@"home.png"];
//        homeSprite.position = ccp(161/2, 768 - 142/2);
//        [_backgroundNode addChild:homeSprite z:1000];
//        homeSprite.userInteractionEnabled = YES;
//        __unsafe_unretained TouchSprite* homeSpriteTemp = homeSprite;
//        homeSprite.touchBegan = ^(UITouch* touch){
//            homeSpriteTemp.userInteractionEnabled = NO;
//            [homeSpriteTemp runAction:[ActionProvider getPressBeginAction]];
//            [[CCDirector sharedDirector] replaceScene:[ContentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
//        };

    }
    return self;
}

- (instancetype)init
{
    return [self initForBladder:nil];
}

-(void)onEnter{
    [super onEnter];
    [self createBackground];
}

-(void)prevPress:(CCButton *)button{
    if(self.step == 1){
        [[CCDirector sharedDirector] replaceScene:[LiveEnvironmentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    else if(self.step == 3){
        [[CCDirector sharedDirector] replaceScene:[ObserveScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    [self handleButtons:NO];
}

-(void)nextPress:(CCButton *)button{
    if (self.step == 1) {
        [[CCDirector sharedDirector] replaceScene:[ObserveScene sceneForBladder] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    else if(self.step == 2){
        [self prepareNextObserving];
    }
    else if(self.step == 3){
        [[CCDirector sharedDirector] replaceScene:[SubmarineScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    else{
        [self prepareNextObserving];
    }
    [self handleButtons:NO];
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
    if (_physicsLauched) {
        FishSprite* fishSprite = (FishSprite* )_bladderSprite.parent;
        CGPoint position = fishSprite.position;
        CGFloat lowY = _observedClNode.stencil.position.y - _observedClNode.stencil.contentSize.height/2;
        CCPhysicsNode* physicsNode = (CCPhysicsNode* )fishSprite.parent;
//        398 - -100 lowY - 120
        CGFloat lowGravity = 100;
        CGFloat gravityRatio = (-100 - lowGravity)/(398 - lowY);
        physicsNode.gravity = ccp(0, (position.y - lowY) * gravityRatio + lowGravity);
        if (_isTouchBladder) {
//            bladder
//            398 - 1/0.45 lowY - 0.7/0.45
            CGFloat lowScaleX = 0.7f/0.45f;
            CGFloat ratioX = (1/0.45f - lowScaleX)/(398.f - lowY);
            CGFloat lowScaleY = 0.2f;
            CGFloat ratioY = (1/0.45f - lowScaleY)/(398.f - lowY);
            _bladderSprite.scaleX = (position.y - lowY) * ratioX + lowScaleX;
            _bladderSprite.scaleY = (position.y - lowY) * ratioY + lowScaleY;
        }
    }
}

-(void)createBackground{
//    bg
    CCSprite* oldBgSprite = [CCSprite spriteWithImageNamed:@"water_left_puzzle.png"];
    oldBgSprite.anchorPoint = ccp(0, 0);
    oldBgSprite.position = ccp(0, 0);
    [_backgroundNode addChild:oldBgSprite z:1];
    
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_observe.png"];
    bgSprite.anchorPoint = ccp(0, 0);
    bgSprite.position = ccp(0, 0);
    bgSprite.opacity = 0;
    [_backgroundNode addChild:bgSprite z:1];
    
//    fish
    CCSprite* oldFishSprite = [CCSprite spriteWithImageNamed:@"carp_puzzle.png"];
    oldFishSprite.scale = 0.6;
    oldFishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [_backgroundNode addChild:oldFishSprite z:FISHORDER];

    _fishSprite = [CCSprite spriteWithImageNamed:@"carp_observe.png"];
    _fishSprite.opacity = 0;
    _fishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [_backgroundNode addChild:_fishSprite z:FISHORDER];
    
//    observer
//    CCSprite* boardSprite = [CCSprite spriteWithImageNamed:@"board_observe.png"];
//    boardSprite.position = ccp(1857/2, 768 - 1357.5/2);
//    boardSprite.name = @"observerBoard";
//    [_backgroundNode addChild:boardSprite z:1000];
//    
//    _observerSprite = [TouchSprite spriteWithImageNamed:@"magnifier_small_observe.png"];
//    _observerSprite.position = [boardSprite convertToNodeSpace:ccp(1798.5/2, 768 - 1354.5/2)];
//    _observerSprite.userInteractionEnabled = YES;
//    [boardSprite addChild:_observerSprite z:1];
//    
//    boardSprite.position = ccp(boardSprite.position.x + boardSprite.contentSize.width, boardSprite.position.y);
//    
//    __unsafe_unretained ObserveScene* weakSelf = self;
    
//    actions
    [oldFishSprite runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:2.f scale:1], [CCActionCallBlock actionWithBlock:^{
        [bgSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionCallBlock actionWithBlock:^{
            [oldBgSprite removeFromParent];
        }], nil]];
        [_fishSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionCallBlock actionWithBlock:^{
            [oldFishSprite removeFromParent];
        }], nil]];
//        [boardSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionMoveBy actionWithDuration:0.5f position:ccp(-boardSprite.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
//            [_observerSprite removeFromParent];
//            _observerSprite.position = ccp(1798.5/2, 768 - 1354.5/2);
//            [_backgroundNode addChild:_observerSprite z:1000];
//            _observerSprite.touchBegan = ^(UITouch* touch){
//                [weakSelf observerTouchBegan:touch];
//            };
//            
//            _observerSprite.touchMoved = ^(UITouch* touch){
//                [weakSelf observerTouchMoved:touch];
//            };
//            
//            _observerSprite.touchEnded = ^(UITouch* touch){
//                [weakSelf observerTouchEnded:touch];
//            };
//            
//            _observerSprite.touchCanceled = ^(UITouch* touch){
//                [weakSelf observerTouchCanceled:touch];
//            };
//            [self runObserverPrompt];
//        }], nil]];
        [self createObservedSprite];
    }], nil]];
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
    
    __unsafe_unretained ObserveScene* weakSelf = self;
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

    
    CCSprite* observedSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@_observe.png", _observedNames.firstObject]];
    observedSprite.opacity = 0;
    observedSprite.name = _observedNames.firstObject;
    [_observedNames removeObjectAtIndex:0];
    observedSprite.position = [_observedPositions.firstObject CGPointValue];
    [_observedPositions removeObjectAtIndex:0];
    [_backgroundNode addChild:observedSprite z:FISHORDER + 2];
    _observedSprite = observedSprite;
    
    [observedSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionDelay actionWithDuration:3.f], [CCActionCallBlock actionWithBlock:^{
        [observedSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionBlink actionWithDuration:1.5f blinks:3], [CCActionDelay actionWithDuration:1.f], nil]]];
    }], nil]];
}

-(void)runObserverPrompt{
    [_observerSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.2f], [CCActionCallBlock actionWithBlock:^{
        [_observerSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRepeat actionWithAction:[CCActionSequence actions:[CCActionRotateTo actionWithDuration:0.1f angle:10], [CCActionDelay actionWithDuration:0.f], [CCActionRotateTo actionWithDuration:0.1f angle:-10], [CCActionDelay actionWithDuration:0.f], nil] times:3], [CCActionDelay actionWithDuration:2.f], nil]]];
    }], nil]];
}

-(void)observerTouchBegan:(UITouch* )touch{
    [_observerSprite stopAllActions];
    _observerSprite.userInteractionEnabled = NO;
    _observerSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"magnifier_real_observe.png"];
    _observerSprite.rotation = 0.f;
    _observerSprite.position = [touch locationInNode:_backgroundNode];
    __unsafe_unretained ObserveScene* weakSelf = self;
    _observerSprite.touchMoved = ^(UITouch* touch){
        [weakSelf observerTouchMoved:touch];
    };
}

-(void)observerTouchMoved:(UITouch* )touch{
    CGRect rect = CGRectMake(_observedSprite.position.x - 150, _observedSprite.position.y - 150, 300, 300);
    if (CGRectContainsPoint(rect, _observerSprite.position)) {
//        watching
        [_observedSprite stopAllActions];
        _observedSprite.visible = YES;
        _observerSprite.userInteractionEnabled = NO;
        _observerSprite.zOrder = FISHORDER + 3;
        [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"observe%@", _observedSprite.name.capitalizedString]) withObject:nil afterDelay:0.f];
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
    CGRect rect = CGRectMake(_observedSprite.position.x - 150, _observedSprite.position.y - 150, 300, 300);
    if (CGRectContainsPoint(rect, _observerSprite.position)) {
//        watching
        [_observedSprite stopAllActions];
        _observedSprite.visible = YES;
        _observerSprite.zOrder = FISHORDER + 3;
        [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"observe%@", _observedSprite.name.capitalizedString]) withObject:nil afterDelay:0.f];
        [_observerSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.1f position:ccp(_observedSprite.position.x + _observedSprite.contentSize.width/4, _observedSprite.position.y - _observedSprite.contentSize.height/4)], nil]];
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

-(void)observerGoBack{
    _observerSprite.zOrder = 1000;
    [_observerSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.3f position:ccp(1798.5/2, 768 - 1354.5/2)], [CCActionCallBlock actionWithBlock:^{
        _observerSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"magnifier_small_observe.png"];
        _observerSprite.userInteractionEnabled = YES;
        [self runObserverPrompt];
        if (_isSceneOver) {
            [self goOver];
        }
    }], nil]];
}

#pragma mark - gill
-(void)observeGill{
    if (_isShowAnimation) {
        return;
    }
    _isShowAnimation = YES;
//    _observedSprite.zOrder = FISHORDER + 2;
//    gill bg
    [self handleButtons:NO];
    self.homeButton.enabled = NO;
    CCSprite* gillBgSprite = [CCSprite spriteWithImageNamed:@"gill_bg_observe.png"];
    gillBgSprite.name = @"gillBg";
    gillBgSprite.position = ccp(585/2, 768 - 970/2);
    [_backgroundNode addChild:gillBgSprite z:FISHORDER + 1];
    
//    circle
    CCSprite* circleSprite = [CCSprite spriteWithImageNamed:@"circle_observe.png"];
    circleSprite.position = ccp(1221/2, 768 - 519.5/2);
    circleSprite.name = @"gillCircle";
    circleSprite.opacity = 0;
    [_backgroundNode addChild:circleSprite z:FISHORDER + 4];
    
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_circle_observe.png"];
    fishSprite.position = [circleSprite convertToNodeSpace:ccp(1235/2 + 23, 768 - 514.5/2 + 11)];
    fishSprite.opacity = 0;
    [circleSprite addChild:fishSprite z:1];
    
    CCSprite* gillSprite = [CCSprite spriteWithImageNamed:@"gill_circle_observe.png"];
    gillSprite.position = [circleSprite convertToNodeSpace:ccp(1235/2, 768 - 514.5/2)];//ccp(1333/2 - 48, 768 - 491.5/2 - 10)];
    gillSprite.opacity = 0;
    [circleSprite addChild:gillSprite z:2];
    
    circleSprite.position = ccp(1221/2 - 100, 768 - 519.5/2 - 80);
    circleSprite.scale = 0.6;
    
    for (CCSprite* sprite in circleSprite.children) {
        [sprite runAction:[CCActionSpawn actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], nil]];
    }
    [circleSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionScaleTo actionWithDuration:1.f scale:1], [CCActionMoveTo actionWithDuration:1.f position:ccp(1221/2, 768 - 519.5/2)], nil], [CCActionDelay actionWithDuration:0.5f], [CCActionCallBlock actionWithBlock:^{
//        animation start
        [self gillAnimationStart:circleSprite];
    }], nil]];
}

-(void)gillAnimationStart:(CCSprite* )circleSprite{
    [circleSprite removeAllChildren];
    
//    clippingNode
    CCSprite* clipRect = [CCSprite spriteWithImageNamed:@"clip_observe.png"];
    clipRect.anchorPoint = ccp(0.5, 0.5);
    clipRect.position = ccp(1221/2, 768 - 519.5/2);
    CCClippingNode* clNode = [CCClippingNode clippingNodeWithStencil:clipRect];
    clNode.contentSize = self.contentSize;
    clNode.alphaThreshold = 0.f;
    [_backgroundNode addChild:clNode z:FISHORDER + 5];
    
//    fish
    CCSprite* fishHeadSprite = [CCSprite spriteWithImageNamed:@"carp_head_observe.png"];
    fishHeadSprite.position = ccp(1117.5/2 + 1, 768 - 481/2);
    [clNode addChild:fishHeadSprite z:11];
    
    CCSprite* fishBodySprite = [CCSprite spriteWithImageNamed:@"carp_body_observe.png"];
    fishBodySprite.position = ccp(1333/2, 768 - 491.5/2);
    [clNode addChild:fishBodySprite z:3];
    
//    gills
    CGPoint points[] = {ccp(1317/2, 768 - 517/2), ccp(1330/2 + 5, 768 - 510/2), ccp(1341/2, 768 - 506/2)};
    int zOrders[] = {9, 7, 5};
    NSArray* imagePrefix = @[@"gill_top", @"gill_mid", @"gill_bottom"];
    for (int i = 0; i < 3; i++) {
        CCSprite* gillSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@1_observe.png", imagePrefix[i]]];
        gillSprite.position = points[i];
        [clNode addChild:gillSprite z:zOrders[i]];
        CCAnimation* gillAnimation = [CCAnimation animationWithFile:imagePrefix[i] withSuffix:@"_observe" frameCount:4 delay:0.2];
        [gillSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:gillAnimation]]];
    }
    
//    pectoral_fin
    CCSprite* finSprite = [CCSprite spriteWithImageNamed:@"pectoral_fin_observe.png"];
    finSprite.anchorPoint = ccp(0, 1);
    finSprite.position = ccp(1411/2 - finSprite.contentSize.width/2, 768 - 781/2 + finSprite.contentSize.height/2);
    [clNode addChild:finSprite z:4];
    [finSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRotateTo actionWithDuration:0.5f angle:5], [CCActionRotateTo actionWithDuration:0.5f angle:-5], nil]]];
    
//    co2 o2 water
    CCSprite* waterSprite = [CCSprite spriteWithImageNamed:@"water1_observe.png"];
    waterSprite.position = ccp(928.5/2, 768 - 511.5/2);
    waterSprite.opacity = 0;
    [clNode addChild:waterSprite z:1];
    
    _observedClNode = clNode;
    
    CCAnimation* waterAnimation = [CCAnimation animationWithFile:@"water" withSuffix:@"_observe" frameCount:2 delay:0.2f];
    [waterSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:waterAnimation]]];
    [waterSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionCallBlock actionWithBlock:^{
//        o2
        for (int i = 0; i < O2NUMBER; i++) {
            MoveSprite* o2Sprite = [MoveSprite spriteWithImageNamed:i%2 ? @"o2_yellow_observe.png" : @"o2_purple_observe.png"];
            o2Sprite.randomStartPoint = YES;
            o2Sprite.startPointLow = ccp(665/2, 768 - 667/2 + 20);
            o2Sprite.startPointHigh = ccp(665/2, 768 - 268/2 + 50);
            o2Sprite.randomEndPoint = NO;
            o2Sprite.endPoint = ccp(1107/2, 768 - 560/2);
            o2Sprite.isRandomDuration = YES;
            o2Sprite.duration = 1.f;
            o2Sprite.delayCreationTime = i * 0.5f;
            o2Sprite.endScale = 0.6;
            o2Sprite.isDetroySelf = NO;
            o2Sprite.isBezierMove = YES;
            o2Sprite.name = [NSString stringWithFormat:@"o2_%d", i + 1];
            o2Sprite.isMoveStart = YES;
            [clNode addChild:o2Sprite z:2];
        }
//        co2
        int zOrders[] = {4, 6, 8, 10};
        for (int i = 0; i < CO2NUMBER; i++) {
            MoveSprite* co2Sprite = [MoveSprite spriteWithImageNamed:i%2 ? @"co2_green_observe.png" : @"co2_blue_observe.png"];
            co2Sprite.randomStartPoint = NO;
            co2Sprite.startPoint = ccp(1107/2, 768 - 560/2);
            co2Sprite.randomEndPoint = YES;
            co2Sprite.endPointLow = ccp(665/2 + 500, 768 - 667/2);
            co2Sprite.endPointHigh = ccp(665/2 + 500, 768 - 268/2);
            co2Sprite.isRandomDuration = YES;
            co2Sprite.duration = 1.5f;
            co2Sprite.delayCreationTime = 1.f + i * 0.5f;
            co2Sprite.endScale = 0.6;
            co2Sprite.isDetroySelf = NO;
            co2Sprite.isBezierMove = NO;
            co2Sprite.name = [NSString stringWithFormat:@"co2_%d", i + 1];
            co2Sprite.isMoveStart = YES;
            [clNode addChild:co2Sprite z:zOrders[i/2]];
        }
        
        __unsafe_unretained ObserveScene* weakSelf = self;
        [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:3.f], [CCActionCallBlock actionWithBlock:^{
            [weakSelf createGoNextSprite];
        }], nil]];
//        [self performSelector:@selector(createGoNextSprite) withObject:nil afterDelay:3.f];
    }], nil]];
}

#pragma mark - bladder
-(void)observeBladder{
    if (_isShowAnimation) {
        return;
    }
    _isShowAnimation = YES;
    [self handleButtons:NO];
    self.homeButton.enabled = NO;
//    bladder bg
    CCSprite* bladderBgSprite = [CCSprite spriteWithImageNamed:@"bladder_bg_observe.png"];
    bladderBgSprite.position = ccp(964/2, 768 - 949/2);
    bladderBgSprite.name = @"bladderBg";
    [_backgroundNode addChild:bladderBgSprite z:FISHORDER + 1];
//    circle
    CCSprite* circleSprite = [CCSprite spriteWithImageNamed:@"circle_bladder_observe.png"];
    circleSprite.position = ccp(1029/2, 768 - 767/2);
    circleSprite.name = @"bladderCircle";
    circleSprite.scale = 0.f;
    [_backgroundNode addChild:circleSprite z:FISHORDER + 4];
    CCSprite* waterCircleSprite = [CCSprite spriteWithImageNamed:@"water_circle_observe.png"];
    waterCircleSprite.position = circleSprite.position;
    waterCircleSprite.scale = 0.f;
    [_backgroundNode addChild:waterCircleSprite z:FISHORDER + 3];
    
    [waterCircleSprite runAction:[CCActionSpawn actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionScaleTo actionWithDuration:1.f scale:2.5f], nil]];
    [circleSprite runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.5f scale:1.15f], [CCActionScaleTo actionWithDuration:0.1f scale:0.9f], [CCActionScaleTo actionWithDuration:0.1f scale:1.05f], [CCActionScaleTo actionWithDuration:0.1f scale:0.98f], [CCActionScaleTo actionWithDuration:0.1f scale:1.f], [CCActionCallBlock actionWithBlock:^{
        [self bladderAnimationStart:circleSprite];
    }], nil]];
}

-(void)bladderAnimationStart:(CCSprite* )circle{
//    clip node
    CCSprite* clipRect = [CCSprite spriteWithImageNamed:@"clip_bladder_observe.png"];
    clipRect.position = circle.position;
    CCClippingNode* clNode = [CCClippingNode clippingNodeWithStencil:clipRect];
    clNode.contentSize = self.contentSize;
    clNode.alphaThreshold = 0.f;
    [_backgroundNode addChild:clNode z:FISHORDER + 5];
    
//    water
    for (int i = 0; i < 10; i++) {
        CCSprite* waterSprite = [CCSprite spriteWithImageNamed:@"water_bladder_observe.png"];
        waterSprite.position = ccp(i%2 ? 1142/2 : 1025/2, 768 - (1351 - 9 * 90)/2 - 90/2 * i);
        waterSprite.opacity = 0;
        [clNode addChild:waterSprite z:1];
        [waterSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionMoveBy actionWithDuration:1.f position:ccp(i%2 ? 4 : -4, 0)], nil], [CCActionCallBlock actionWithBlock:^{
            [waterSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:5.f + arc4random()%10*0.1f position:ccp(i%2 ? -20 : 20, 0)], [CCActionMoveBy actionWithDuration:5.f + arc4random()%10*0.1f position:ccp(i%2 ? 20 : -20, 0)], nil]]];
        }], nil]];
    }
//    plants
    CGPoint points[] = {ccp(824/2, 768 - 808/2), ccp(680/2, 768 - 866/2), ccp(1331/2, 768 - 767/2), ccp(902/2, 768 - 860/2), ccp(705/2, 768 - 914/2), ccp(1480/2, 768 - 907/2), ccp(1516/2, 768 - 1001/2), ccp(941/2, 768 - 831/2)};
    int zOrders[] = {10, 9, 8, 6, 5, 4, 3, 2};
    for (int i = 0; i < 8; i++) {
        CCSprite* plant = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"plant%d_bladder_observe.png", i + 1]];
        plant.opacity = 0;
        CGFloat angle = 0.f;
        if (i < 3) {
            plant.anchorPoint = ccp(0, 0);
            plant.position = ccp(points[i].x - plant.contentSize.width/2, points[i].y - plant.contentSize.height/2);
            angle = 1.f;
        }
        else if(i < 7){
            plant.anchorPoint = ccp(1, 0);
            plant.position = ccp(points[i].x + plant.contentSize.width/2, points[i].y - plant.contentSize.height/2);
            angle = -1.f;
        }
        else{
            plant.position = points[i];
        }
        [clNode addChild:plant z:zOrders[i]];
        plant.position = ccp(plant.position.x, plant.position.y - plant.contentSize.height);
        [plant runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionMoveBy actionWithDuration:2.f position:ccp(0, plant.contentSize.height)], nil], [CCActionCallBlock actionWithBlock:^{
            [plant runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRotateBy actionWithDuration:5.f + arc4random()%20*0.1f angle:3.f*angle], [CCActionRotateBy actionWithDuration:5.f + arc4random()%20*0.1f angle:-3.f*angle], nil]]];
        }], nil]];
    }
    
//    physics
    CCPhysicsNode* physicsNode = [CCPhysicsNode node];
    physicsNode.gravity = ccp(0, -150);
    physicsNode.collisionDelegate = self;
//    physicsNode.debugDraw = YES;
    [clNode addChild:physicsNode z:7];
    
//    bottom
    CCNode* bottomNode = [CCNode node];
    bottomNode.anchorPoint = ccp(0, 0);
    bottomNode.contentSize = CGSizeMake(clipRect.contentSize.width + 500, 200);
    bottomNode.position = ccp(clipRect.position.x - clipRect.contentSize.width/2 - 250, clipRect.position.y - clipRect.contentSize.height/2 - 250);
    bottomNode.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, bottomNode.contentSize} cornerRadius:0];
    bottomNode.physicsBody.type = CCPhysicsBodyTypeStatic;
    bottomNode.physicsBody.elasticity = 0.5f;
    bottomNode.physicsBody.friction = 0.f;
    bottomNode.physicsBody.collisionType = @"obstacle";

    [physicsNode addChild:bottomNode z:1];
//    top
    CCNode* topNode = [CCNode node];
    topNode.anchorPoint = ccp(0, 0);
    topNode.contentSize = CGSizeMake(clipRect.contentSize.width + 500, 200);
    topNode.position = ccp(clipRect.position.x - clipRect.contentSize.width/2 - 250, clipRect.position.y + clipRect.contentSize.height/2 - 100);
    topNode.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, topNode.contentSize} cornerRadius:0];
    topNode.physicsBody.type = CCPhysicsBodyTypeStatic;
    topNode.physicsBody.collisionType = @"obstacle";
    topNode.physicsBody.elasticity = 1.f;
    topNode.physicsBody.friction = 0.f;
    [physicsNode addChild:topNode z:1];
//    left
    CCNode* leftNode = [CCNode node];
    leftNode.anchorPoint = ccp(0, 0);
    leftNode.contentSize = CGSizeMake(200, clipRect.contentSize.height);
    leftNode.position = ccp(clipRect.position.x - clipRect.contentSize.width/2 - 200 - 250, clipRect.position.y - clipRect.contentSize.height/2 - 50);
    leftNode.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, leftNode.contentSize} cornerRadius:0];
    leftNode.physicsBody.type = CCPhysicsBodyTypeStatic;
    leftNode.physicsBody.elasticity = 5.f;
    leftNode.physicsBody.friction = 0.f;
    leftNode.physicsBody.collisionType = @"left";
    [physicsNode addChild:leftNode z:1];
//    right
    CCNode* rightNode = [CCNode node];
    rightNode.anchorPoint = ccp(0, 0);
    rightNode.contentSize = CGSizeMake(200, clipRect.contentSize.height);
    rightNode.position = ccp(clipRect.position.x + clipRect.contentSize.width/2 + 250, clipRect.position.y - clipRect.contentSize.height/2 - 50);
    rightNode.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, rightNode.contentSize} cornerRadius:0];
    rightNode.physicsBody.type = CCPhysicsBodyTypeStatic;
    rightNode.physicsBody.elasticity = 5.f;
    rightNode.physicsBody.friction = 0.f;
    rightNode.physicsBody.collisionType = @"right";

//    fish
    FishSprite* fishSprite = [FishSprite spriteWithImageNamed:@"carp_well1_puzzle.png"];
    fishSprite.position = ccp(1048/2, 768 - 740/2);
    fishSprite.scale = 0.45f;
    fishSprite.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, fishSprite.contentSize} cornerRadius:0.f];
    fishSprite.physicsBody.collisionType = @"fish";
    fishSprite.physicsBody.type = CCPhysicsBodyTypeStatic;
    fishSprite.state = initial;
    fishSprite.direction = moveToLeft;
    [physicsNode addChild:fishSprite z:1];
    
    CCAnimation* fishAnimation = [CCAnimation animationWithFile:@"carp_well" withSuffix:@"_puzzle" frameCount:4 delay:0.15f];
    [fishSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:fishAnimation]]];
    
    _bladderSprite = [CCSprite spriteWithImageNamed:@"bladder_small_observe.png"];
    _bladderSprite.scale = 1/0.45f;
    _bladderSprite.anchorPoint = ccp(0.3f, 0.5f);
    _bladderSprite.position = [fishSprite convertToNodeSpace:ccp(524 - 30, 398 - 8)];
    [fishSprite addChild:_bladderSprite z:1];
    
    fishSprite.position = ccp(clipRect.position.x + clipRect.contentSize.width/2 + fishSprite.contentSize.width/2 * 0.45f, fishSprite.position.y);
    [fishSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionMoveTo actionWithDuration:2.f position:ccp(1048/2, 768 - 740/2)], [CCActionCallBlock actionWithBlock:^{
        [_bladderSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionBlink actionWithDuration:0.8f blinks:3], [CCActionDelay actionWithDuration:0.5f], nil]]];
        fishSprite.userInteractionEnabled = YES;
        [physicsNode addChild:rightNode z:1];
    }], nil]];
    
    __unsafe_unretained FishSprite* fishSpriteTemp = fishSprite;
    __unsafe_unretained CCSprite* bladderSpriteTemp = _bladderSprite;
    __unsafe_unretained ObserveScene* weafSelf = self;
//    __block BOOL physicsLauchedTemp = _physicsLauched;
//    __block BOOL isTouchBladderTemp = _isTouchBladder;
    fishSprite.touchBegan = ^(UITouch* touch){
        if (fishSpriteTemp.state == initial) {
            [bladderSpriteTemp stopAllActions];
            bladderSpriteTemp.visible = YES;
            fishSpriteTemp.state = lauched;
            fishSpriteTemp.physicsBody.type = CCPhysicsBodyTypeDynamic;
            _physicsLauched = YES;
            _isTouchBladder = YES;
            
            [weafSelf runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionCallBlock actionWithBlock:^{
                [weafSelf createGoNextSprite];
            }], nil]];
//            [weafSelf performSelector:@selector(createGoNextSprite) withObject:nil afterDelay:2.f];
        }
        else if (fishSpriteTemp.state == lauched) {
            _isTouchBladder = NO;
        }
        CGFloat xSpeed = 0.f;
        if (fishSpriteTemp.direction == moveToLeft) {
            xSpeed = fishSpriteTemp.physicsBody.velocity.x < -50 ? fishSpriteTemp.physicsBody.velocity.x : -50;
        }
        else{
            xSpeed = fishSpriteTemp.physicsBody.velocity.x > 50 ? fishSpriteTemp.physicsBody.velocity.x : 50;
        }
        fishSpriteTemp.physicsBody.velocity = ccp(xSpeed, 100);
        [weafSelf bladderGrowBig:fishSpriteTemp];
    };
    fishSprite.touchEnded = ^(UITouch* touch){
        _isTouchBladder = YES;
    };
    
    _observedClNode = clNode;
    _isSceneOver = YES;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair fish:(CCNode *)nodeA left:(CCNode *)nodeB{
    FishSprite* fishSprite = (FishSprite* )nodeA;
    fishSprite.flipX = YES;
    _bladderSprite.flipX = YES;
    _bladderSprite.anchorPoint = ccp(0.7f, 0.5f);
    _bladderSprite.position = [fishSprite convertToNodeSpace:ccp(fishSprite.position.x + 30, fishSprite.position.y - 8)];
    fishSprite.direction = moveToRight;
    fishSprite.rotation = 0.f;
    return YES;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair fish:(CCNode *)nodeA right:(CCNode *)nodeB{
    FishSprite* fishSprite = (FishSprite* )nodeA;
    fishSprite.flipX = NO;
    _bladderSprite.flipX = NO;
    _bladderSprite.anchorPoint = ccp(0.3f, 0.5f);
    _bladderSprite.position = [fishSprite convertToNodeSpace:ccp(fishSprite.position.x - 30, fishSprite.position.y - 8)];
    fishSprite.direction = moveToLeft;
    fishSprite.rotation = 0.f;
    return YES;
}

-(void)bladderGrowBig:(CCSprite* )fishSprite{
    _bladderSprite.scale = 1/0.45f * 1.3f;
}

-(void)createGoNextSprite{
//    TouchSprite* goNextSprite = [TouchSprite spriteWithImageNamed:@"play.png"];
//    goNextSprite.position = ccp(1797/2, 768 - 1358/2);
//    goNextSprite.opacity = 0;
//    goNextSprite.userInteractionEnabled = YES;
//    [_backgroundNode addChild:goNextSprite z:1000];
//    __unsafe_unretained ObserveScene* weakSelf = self;
//    __unsafe_unretained TouchSprite* goNextSpriteTemp = goNextSprite;
//    goNextSprite.touchBegan = ^(UITouch* touch){
//        goNextSpriteTemp.userInteractionEnabled = NO;
//        [goNextSpriteTemp stopAllActions];
//        goNextSpriteTemp.scale = 1;
//        [weakSelf prepareNextObserving];
//    };
//    _goNextSprite = goNextSprite;
//    
//    [goNextSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionDelay actionWithDuration:0.f], [CCActionCallBlock actionWithBlock:^{
//        [goNextSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.2f scale:1.2f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.2f scale:0.9f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.1f scale:1.05f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.1f scale:1.f], [CCActionDelay actionWithDuration:0.8f], nil]]];
//    }], nil]];
    self.step++;
    self.nextButton.visible = YES;
    self.nextButton.enabled = YES;
}

-(void)prepareNextObserving{
//    remove
    [_observedClNode.stencil runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:0.f], [CCActionCallBlock actionWithBlock:^{
//        spark
        SparkNode* spark = [SparkNode node];
        spark.imageNamesArray = @[@"spark1_observe.png", @"spark2_observe.png"];
        spark.numberOfDirections = 8;
        spark.imageAngleOffset = 0;
        spark.isDestroySelf = YES;
        spark.duration = 0.5f;
        spark.distance = 150;
        spark.position = _observedClNode.stencil.position;
        [_backgroundNode addChild:spark z:1000];
//        fireworks
        Fireworks* bubbles = [Fireworks node];
        bubbles.position = _observedClNode.stencil.position;
        bubbles.imageString = @"bubble";
        bubbles.imageCount = 5;
        bubbles.fireworkNumber = 5;
        bubbles.minScale = 0.4f;
        bubbles.maxScale = 1.f;
        bubbles.minLifeCycle = 0.8f;
        bubbles.maxLifeCycle = 2.2f;
        bubbles.distance = 180;
        bubbles.isFadeToZero = YES;
        [_backgroundNode addChild:bubbles z:999];
    }], [CCActionCallBlock actionWithBlock:^{
//        remove
        if ([_observedSprite.name isEqualToString:@"bladder"]) {
            _physicsLauched = NO;
            FishSprite* fishSprite = (FishSprite* )_bladderSprite.parent;
            [_bladderSprite removeFromParent];
            _bladderSprite = nil;
            [fishSprite.parent removeAllChildren];
        }
        while (_observedClNode.children.count) {
            CCSprite* sprite = _observedClNode.children.firstObject;
            if ([sprite isKindOfClass:[MoveSprite class]]) {
                MoveSprite* tempSprite = (MoveSprite* )sprite;
                tempSprite.isDetroySelf = YES;
            }
            [sprite removeFromParent];
        }
        _observedClNode.stencil = nil;
        [_observedClNode removeFromParent];
        _observedClNode = nil;
        
    }], nil]];//, [CCActionScaleTo actionWithDuration:0.1f scale:0.f], nil]];
    
    CCSprite* bgSprite = (CCSprite* )[_backgroundNode getChildByName:[NSString stringWithFormat:@"%@Bg", _observedSprite.name] recursively:NO];
    CCSprite* circleSprite = (CCSprite* )[_backgroundNode getChildByName:[NSString stringWithFormat:@"%@Circle", _observedSprite.name] recursively:NO];
    [bgSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.7f], [CCActionFadeTo actionWithDuration:0.3f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
        [bgSprite removeFromParent];
    }], nil]];
//        go next sprite
//    [_goNextSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.7f],[CCActionFadeTo actionWithDuration:0.3f opacity:0], [CCActionCallBlock actionWithBlock:^{
//        _goNextSprite.touchBegan = nil;
//        [_goNextSprite removeFromParent];
//        _goNextSprite = nil;
//    }], nil]];
    [circleSprite runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:[_observedSprite.name isEqualToString:@"bladder"] ? 3 : 0], [CCActionCallBlock actionWithBlock:^{
        if ([_observedSprite.name isEqualToString:@"gill"]) {
            [circleSprite removeFromParent];
        }
        _isShowAnimation = NO;
        
//        [self observerGoBack];
        [_observerSprite removeFromParent];
        _observerSprite = nil;
        
//        next
        if (_isSceneOver) {
            [self goOver];
            return;
        }
        [self createObservedSprite];
        self.step = 3;
        [self handleButtons:YES];
        self.homeButton.enabled = YES;
    }], nil]];
//    [self performSelector:@selector(observerGoBack) withObject:nil afterDelay:1.f];
//    next
//    if (_isSceneOver) {
//        return;
//    }
//    [self performSelector:@selector(createObservedSprite) withObject:nil afterDelay:1.f];
}

-(void)goOver{
//    CCSprite* board = (CCSprite* )[_backgroundNode getChildByName:@"observerBoard" recursively:NO];
//    [board runAction:[CCActionMoveBy actionWithDuration:1.f position:ccp(_observerSprite.parent.contentSize.width, 0)]];
//    [_observerSprite stopAllActions];
//    [_observerSprite runAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:1.f position:ccp(_observerSprite.parent.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
//        [board removeFromParent];
//        [_observerSprite removeFromParent];
//        _observerSprite = nil;
//        
////        next scene
//        [self replaceToNextScene];
//    }], nil]];
    
    [_observerSprite removeFromParent];
    _observerSprite = nil;
    
//        next scene
    [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.5f], [CCActionCallBlock actionWithBlock:^{
        [self replaceToNextScene];
    }], nil]];
}

-(void)replaceToNextScene{
    CGSize winSize = [[CCDirector sharedDirector] viewSize];
//    截图方法
    CCRenderTexture* texture = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
    [texture begin];
    [self visit];
    [texture end];

    SubmarineScene* submarineScene = [SubmarineScene scene];
    texture.anchorPoint = ccp(0.5f, 0.5f);
    texture.position = ccp(winSize.width, winSize.height);
    [submarineScene addChild:texture z:1];
    submarineScene.isFromObserveScene = YES;
    [[CCDirector sharedDirector] replaceScene:submarineScene];
}


-(void)onExit{
    [_backgroundNode removeAllChildren];
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

@end
