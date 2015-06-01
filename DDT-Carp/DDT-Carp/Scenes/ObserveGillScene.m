//
//  ObserveGillScene.m
//  DDT-Carp
//
//  Created by Z on 15/2/3.
//  Copyright (c) 2015年 ZY. All rights reserved.
//

#import "ObserveGillScene.h"
#import "BubbleRise.h"
#import "CCAnimation+Helper.h"
#import "MoveSprite.h"
#import "SparkNode.h"
#import "Fireworks.h"
#import "CCTextureCache.h"

#import "LiveEnvironmentScene.h"
#import "ObserveBladderScene.h"

#define FISHORDER 100
#define O2NUMBER 4
#define CO2NUMBER 8

@interface ObserveGillScene ()
{
    CCClippingNode* _observedClNode;
    BOOL _isShowAnimation;
    NSMutableArray* _tipsArray;
}
@end

@implementation ObserveGillScene
+(ObserveGillScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isJumpHere = NO;
        _isShowAnimation = NO;
        _tipsArray = [[NSMutableArray alloc] init];
        
//        base words
        self.prevButton.visible = NO;
        self.nextButton.visible = NO;
        self.homeButton.visible = NO;
        self.currentScene = @"gill";
        self.imageSuffix = @"observe";
        
//        base observed
        self.observedName = @"gill";
        self.observedCount = 1;
        self.observedPositions = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(491.5/2, 768 - 989.5/2)], nil];
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createBackground];
}

-(void)prevPress:(CCButton *)button{
    if(self.step == 1){
        [[CCDirector sharedDirector] replaceScene:[LiveEnvironmentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    [self handleButtons:NO];
}

-(void)nextPress:(CCButton *)button{
    if (self.step == 1) {
        [[CCDirector sharedDirector] replaceScene:[ObserveBladderScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    else if(self.step == 2){
        [self gillGoOver];
    }
    [self handleButtons:NO];
}

-(void)createBackground{
//    bg
    CCSprite* oldBgSprite = [CCSprite spriteWithImageNamed:@"water_left_puzzle.png"];
    oldBgSprite.anchorPoint = ccp(0, 0);
    oldBgSprite.position = ccp(0, 0);
    [self.backgroundNode addChild:oldBgSprite z:1];
    
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_observe.png"];
    bgSprite.anchorPoint = ccp(0, 0);
    bgSprite.position = ccp(0, 0);
    bgSprite.opacity = 0;
    [self.backgroundNode addChild:bgSprite z:1];
    
//    fish
    CCSprite* oldFishSprite = [CCSprite spriteWithImageNamed:@"carp_puzzle.png"];
    oldFishSprite.scale = 0.6;
    oldFishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [self.backgroundNode addChild:oldFishSprite z:FISHORDER];
    
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_observe.png"];
    fishSprite.opacity = 0;
    fishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [self.backgroundNode addChild:fishSprite z:FISHORDER];
    
//    actions
    if (_isJumpHere) {
        bgSprite.opacity = 1.f;
        fishSprite.opacity = 1.f;
        [oldBgSprite removeFromParent];
        [oldFishSprite removeFromParent];
    }
    else{
        [oldFishSprite runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:2.f scale:1], [CCActionCallBlock actionWithBlock:^{
            [bgSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionCallBlock actionWithBlock:^{
                [oldBgSprite removeFromParent];
            }], nil]];
            [fishSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionCallBlock actionWithBlock:^{
                [oldFishSprite removeFromParent];
            }], nil]];
        }], nil]];
    }
}

-(void)createScene{
    [self createObservedSprite];
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
    [self.backgroundNode addChild:gillBgSprite z:FISHORDER + 1];
    
//    circle
    CCSprite* circleSprite = [CCSprite spriteWithImageNamed:@"circle_observe.png"];
    circleSprite.position = ccp(1221/2, 768 - 519.5/2);
    circleSprite.name = @"gillCircle";
    circleSprite.opacity = 0;
    [self.backgroundNode addChild:circleSprite z:FISHORDER + 4];
    
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
    [self.backgroundNode addChild:clNode z:FISHORDER + 5];
    
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
    
//    tips
    const CGFloat defaultLength = 30.f;
    
    NSString* tipOne = NSLocalizedString(@"gill_tip1", nil);
    NSString* tipTwo = NSLocalizedString(@"gill_tip2", nil);
    CGFloat fontSize = [NSLocalizedString(@"gill_tip_font_size", nil) doubleValue];
    CGFloat letterWidth = [NSLocalizedString(@"gill_tip_letter_width", nil) doubleValue];
    
    CGPoint rectPositions[] = {ccp(552/2.f, 768 - 437/2.f), ccp(1662/2.f, 768 - 788/2.f)};
    CGPoint labelPositions[] = {ccp(471/2.f, 768 - 437/2.f), ccp(1779/2.f, 768 - 788/2.f)};
    NSArray* tips = @[tipOne, tipTwo];
    ccColor4F fontColors[] = {ccc4f(123/255.f, 243/255.f, 219/255.f, 1.f), ccc4f(1.f, 232/255.f, 81/255.f, 1.f)};
    CGSize fontDimensions[] = {(CGSize){10 * defaultLength, 0.f}, (CGSize){6 * defaultLength, 0.f}};
    
    for (int i = 0; i < 2; i++) {
        CGFloat rectScaleY = 1.f;
        if ([(NSString* )tips[i] length] * letterWidth / fontDimensions[i].width > 2.f) {
            int row = ceil([(NSString* )tips[i] length] * letterWidth / fontDimensions[i].width);
            rectScaleY = row/2.f;
        }
        
        CCSprite* rect = [CCSprite spriteWithImageNamed:@"tips_bg.png"];
        
        CCNode* tipNode = [CCNode node];
        tipNode.contentSize = rect.contentSize;
        tipNode.anchorPoint = ccp(!i ? 1.f : 0.f, 0.5f);
        tipNode.position = ccp(rectPositions[i].x + rect.contentSize.width/2.f * (!i ? 1 : -1), rectPositions[i].y);
//        tipNode.scaleY = rectScaleY;
        [self.backgroundNode addChild:tipNode z:FISHORDER + 3];
        
        rect.position = [tipNode convertToNodeSpace:rectPositions[i]];
        rect.scaleY = rectScaleY;
        [tipNode addChild:rect z:1];
        
        CCLabelTTF* tip = [CCLabelTTF labelWithString:tips[i] fontName:@"STYuanti-SC-Regular" fontSize:fontSize dimensions:fontDimensions[i]];
        tip.position = [tipNode convertToNodeSpace:labelPositions[i]];
        tip.horizontalAlignment = CCTextAlignmentCenter;
        tip.color = [CCColor colorWithCcColor4f:fontColors[i]];
        [tipNode addChild:tip z:1];
        
        [_tipsArray addObject:tipNode];
        
        tipNode.scaleX = 0.f;
    }
    
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
        
        __unsafe_unretained ObserveGillScene* weakSelf = self;
        [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:3.f], [CCActionCallBlock actionWithBlock:^{
            [weakSelf goNextStep];
        }], nil]];
        
        for (CCNode* tipNode in _tipsArray) {
            [tipNode runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scaleX:1.f scaleY:1.f], nil]];
        }
//        [self performSelector:@selector(createGoNextSprite) withObject:nil afterDelay:3.f];
    }], nil]];
}

-(void)goNextStep{
    self.step++;
    self.nextButton.visible = YES;
    self.nextButton.enabled = YES;
}

-(void)gillGoOver{
//    remove
    [_observedClNode.stencil runAction:[CCActionSequence actions:[CCActionCallBlock actionWithBlock:^{
        for (CCNode* tipNode in _tipsArray) {
            [tipNode runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scaleX:0.f scaleY:1.f], [CCActionCallBlock actionWithBlock:^{
                [tipNode removeAllChildren];
                [tipNode removeFromParent];
            }], nil]];
        }
        [_tipsArray removeAllObjects];
    }], [CCActionDelay actionWithDuration:1.f], [CCActionScaleTo actionWithDuration:1.f scale:0.f], [CCActionCallBlock actionWithBlock:^{
//        spark
        SparkNode* spark = [SparkNode node];
        spark.imageNamesArray = @[@"spark1_observe.png", @"spark2_observe.png"];
        spark.numberOfDirections = 8;
        spark.imageAngleOffset = 0;
        spark.isDestroySelf = YES;
        spark.duration = 0.5f;
        spark.distance = 150;
        spark.position = _observedClNode.stencil.position;
        [self.backgroundNode addChild:spark z:1000];
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
        [self.backgroundNode addChild:bubbles z:999];
    }], [CCActionCallBlock actionWithBlock:^{
//        remove
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
    
    CCSprite* bgSprite = (CCSprite* )[self.backgroundNode getChildByName:[NSString stringWithFormat:@"%@Bg", [(CCSprite* )self.observedSpriteArray.firstObject name]] recursively:NO];
    CCSprite* circleSprite = (CCSprite* )[self.backgroundNode getChildByName:[NSString stringWithFormat:@"%@Circle", [(CCSprite* )self.observedSpriteArray.firstObject name]] recursively:NO];
    [bgSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.7f], [CCActionFadeTo actionWithDuration:0.3f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
        [bgSprite removeFromParent];
    }], nil]];
    [circleSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionScaleTo actionWithDuration:1.f scale:0], [CCActionCallBlock actionWithBlock:^{
        [circleSprite removeFromParent];
        _isShowAnimation = NO;
        [self.observerSprite removeFromParent];
        self.observerSprite = nil;
        
//        next
        [self goOver];
    }], nil]];
}

-(void)goOver{
//        next scene
    [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.5f], [CCActionCallBlock actionWithBlock:^{
        [[CCDirector sharedDirector] replaceScene:[ObserveBladderScene scene]];
    }], nil]];
}





-(void)onExit{
    [_tipsArray removeAllObjects];
    [self.backgroundNode removeAllChildren];
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{
    
}
@end
