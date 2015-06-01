//
//  ObserveScaleScene.m
//  DDT-Carp
//
//  Created by Z on 15/2/3.
//  Copyright (c) 2015年 ZY. All rights reserved.
//
#import "SparkNode.h"
#import "Fireworks.h"
#import "CCTextureCache.h"

#import "ObserveScaleScene.h"
#import "ObserveFinScene.h"
#import "FishLivingEnvironmentScene.h"

#define FISHORDER 100
#define WORLDORDER 1000

@interface ObserveScaleScene ()
{
//    observe control
    BOOL _isShowAnimation;
    
//    scale tips
    NSMutableArray* _tipsArray;
}
@end

@implementation ObserveScaleScene
+(ObserveScaleScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isShowAnimation = NO;
        _tipsArray = [[NSMutableArray alloc] init];
        
//        base words
        self.prevButton.visible = NO;
        self.nextButton.visible = NO;
        self.homeButton.visible = NO;
        self.currentScene = @"scale";
        self.imageSuffix = @"observe";
        
//        base observed
        self.observedName = @"scale";
        self.observedCount = 1;
        self.observedPositions = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(1023.5/2.f, 768 - 969/2.f)], nil];
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createBackground];
}

-(void)prevPress:(CCButton *)button{
    if(self.step == 1){
        [[CCDirector sharedDirector] replaceScene:[ObserveFinScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    [self handleButtons:NO];
}

-(void)nextPress:(CCButton *)button{
    if (self.step == 1) {

    }
    else if(self.step == 2){
        [self scaleGoOver];
    }
    [self handleButtons:NO];
}

-(void)createBackground{
//    bg
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_observe.png"];
    bgSprite.anchorPoint = ccp(0, 0);
    bgSprite.position = ccp(0, 0);
    [self.backgroundNode addChild:bgSprite z:1];
    
//    fish
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_observe.png"];
    fishSprite.name = @"carp";
    fishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [self.backgroundNode addChild:fishSprite z:FISHORDER];
    
//    gill
    CCSprite* gillSprite = [CCSprite spriteWithImageNamed:@"gill_observe.png"];
    gillSprite.position = ccp(491.5/2, 768 - 989.5/2);
    [self.backgroundNode addChild:gillSprite z:FISHORDER];
}

-(void)createScene{
    self.nextButton.visible = NO;
    [self createObservedSprite];
}

#pragma mark - scale observe
-(void)observeScale{
    if(_isShowAnimation){
        return;
    }
    _isShowAnimation = YES;
    [self handleButtons:NO];
    self.homeButton.enabled = NO;
    
//    circle
    CCSprite* scaleCircleSprite = [CCSprite spriteWithImageNamed:@"circle_scale_observe.png"];
    scaleCircleSprite.scale = 0.5f;
    scaleCircleSprite.name = @"scaleCircle1";
    scaleCircleSprite.position = ccp(603.5/2.f + 80, 768 - 306.5/2.f - 200);
    [self.backgroundNode addChild:scaleCircleSprite z:FISHORDER + 3];
    __unsafe_unretained CCNode* backgroundTemp = self.backgroundNode;
    [scaleCircleSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:0.5f position:ccp(603.5/2.f, 768 - 306.5/2.f)], [CCActionScaleTo actionWithDuration:1.f scale:1.f], nil], [CCActionCallBlock actionWithBlock:^{
//        wave
        CCSprite* wave = [CCSprite spriteWithImageNamed:@"wave_scale_observe.png"];
        wave.name = @"wave";
        wave.position = ccp(603.5/2.f, 768 - 306.5/2.f);
        wave.scale = 0.7f;
        [backgroundTemp addChild:wave z:FISHORDER + 2];
        
        [wave runAction:[CCActionSequence actions:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionScaleTo actionWithDuration:1.2f scale:1.3f], [CCActionFadeTo actionWithDuration:1.2f opacity:0.f], nil], [CCActionCallBlock actionWithBlock:^{
            wave.scale = 0.7f;
            wave.opacity = 1.f;
        }], [CCActionDelay actionWithDuration:1.f], nil]], nil]];
    }], nil]];
    
//    scales
    TouchSprite* scalesSprite = [TouchSprite spriteWithImageNamed:@"scales_scale_observe.png"];
    scalesSprite.position = ccp(603.5/2.f, 768 - 306.5/2.f);
    scalesSprite.opacity = 0;
    scalesSprite.userInteractionEnabled = NO;
    [self.backgroundNode addChild:scalesSprite z:FISHORDER + 4];
    [scalesSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
        [scalesSprite removeFromParent];
        scalesSprite.position = [scaleCircleSprite convertToNodeSpace:scalesSprite.position];
        [scaleCircleSprite addChild:scalesSprite z:1];
        scalesSprite.userInteractionEnabled = YES;
    }], nil]];
    
    __unsafe_unretained ObserveScaleScene* weakSelf = self;
    __unsafe_unretained TouchSprite* scalesSpriteTemp = scalesSprite;
    scalesSprite.touchBegan = ^(UITouch* touch){
        scalesSpriteTemp.userInteractionEnabled = NO;
        scalesSpriteTemp.touchBegan = nil;
        [weakSelf createAScale];
    };
}

-(void)createAScale{
//    circle
    CCSprite* scaleCircleSprite = [CCSprite spriteWithImageNamed:@"circle_scale_observe.png"];
    scaleCircleSprite.name = @"scaleCircle2";
    scaleCircleSprite.position = ccp(603.5/2.f, 768 - 306.5/2.f);
    [self.backgroundNode addChild:scaleCircleSprite z:FISHORDER + 2];
    
    [scaleCircleSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.5f position:ccp(1267.5/2.f, 768 - 306.5/2.f)], [CCActionCallBlock actionWithBlock:^{
        
    }], nil]];
    
//    a scale
    CCSprite* aScaleSprite = [CCSprite spriteWithImageNamed:@"scale_scale_observe.png"];
    aScaleSprite.position = ccp(1267.5/2.f, 768 - 306.5/2.f);
    aScaleSprite.opacity = 0;
    [self.backgroundNode addChild:aScaleSprite z:FISHORDER + 3];
    __unsafe_unretained ObserveScaleScene* weakSelf = self;
    [aScaleSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionDelay actionWithDuration:1.f], [CCActionCallBlock actionWithBlock:^{
        [aScaleSprite removeFromParent];
        aScaleSprite.position = [scaleCircleSprite convertToNodeSpace:aScaleSprite.position];
        [scaleCircleSprite addChild:aScaleSprite z:1];
        [weakSelf createGoNextSprite];
    }], nil]];
    
//    wave stop
    CCSprite* wave = (CCSprite* )[self.backgroundNode getChildByName:@"wave" recursively:NO];
    [wave stopAllActions];
    __unsafe_unretained CCSprite* waveTemp = wave;
    [wave runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:0.5f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
        [waveTemp removeFromParent];
    }], nil]];
    
//    tips
    const CGFloat defaultLength = 30.f;
    
    NSString* tipOne = NSLocalizedString(@"scale_tip1", nil);
    NSString* tipTwo = NSLocalizedString(@"scale_tip2", nil);
    CGFloat fontSize = [NSLocalizedString(@"scale_tip_font_size", nil) doubleValue];
    CGFloat letterWidth = [NSLocalizedString(@"scale_tip_letter_width", nil) doubleValue];
    
    CGPoint rectPositions[] = {ccp(521/2.f, 768 - 692/2.f), ccp(1325/2.f, 768 - 692/2.f)};
    NSArray* tips = @[tipOne, tipTwo];
    ccColor4F fontColors[] = {ccc4f(123/255.f, 243/255.f, 219/255.f, 1.f), ccc4f(1.f, 232/255.f, 81/255.f, 1.f)};
    CGSize fontDimensions[] = {(CGSize){10 * defaultLength, 0.f}, (CGSize){10 * defaultLength, 0.f}};
    
    for (int i = 0; i < 2; i++) {
        CGFloat rectScaleY = 1.f;
        CGFloat offset = 0.f;
        CCSprite* rect = [CCSprite spriteWithImageNamed:@"tips_bg.png"];
        
        if ([(NSString* )tips[i] length] * letterWidth / fontDimensions[i].width > 2.f) {
            int row = ceil([(NSString* )tips[i] length] * letterWidth / fontDimensions[i].width);
            rectScaleY = row/2.f;
            NSLog(@"%f", rectScaleY);
            offset = (rectScaleY - 1) * rect.contentSize.height;
        }
        
        CCNode* tipNode = [CCNode node];
        tipNode.contentSize = rect.contentSize;
        tipNode.anchorPoint = ccp(0.5f, 0.5f);
        tipNode.position = rectPositions[i];
        [self.backgroundNode addChild:tipNode z:FISHORDER + 3];
        
        rect.position = [tipNode convertToNodeSpace:ccpSub(rectPositions[i], ccp(0.f, offset * 0.5f))];
        rect.scaleY = rectScaleY;
        [tipNode addChild:rect z:1];
        
        CCLabelTTF* tip = [CCLabelTTF labelWithString:tips[i] fontName:@"STYuanti-SC-Regular" fontSize:fontSize dimensions:fontDimensions[i]];
        tip.position = [tipNode convertToNodeSpace:ccpSub(rectPositions[i], ccp(0.f, offset * 0.5f))];
        tip.horizontalAlignment = CCTextAlignmentCenter;
        tip.color = [CCColor colorWithCcColor4f:fontColors[i]];
        [tipNode addChild:tip z:1];
        
        [_tipsArray addObject:tipNode];
        
//        tipNode.scaleX = 0.f;
    }
    
    for (int i = 0; i < _tipsArray.count; i++) {
        CCNode* tipNode = _tipsArray[i];
//        [tipNode runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionScaleTo actionWithDuration:1.f scaleX:1.f scaleY:1.f], nil]];
        CGPoint originalPosition = tipNode.position;
        tipNode.position = ccp(tipNode.position.x, 768 - 306.5/2.f);
        [tipNode runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionMoveTo actionWithDuration:1.f position:originalPosition], nil]];
        for (int j = 0; j < tipNode.children.count; j++) {
            CCNode* tip = tipNode.children[j];
            tip.opacity = 0.f;
            [tip runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.5f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
        }
    }
}

-(void)scaleGoOver{
    CCSprite* scaleCircleOne = (CCSprite* )[self.backgroundNode getChildByName:@"scaleCircle1" recursively:NO];
    CCSprite* scaleCircleTwo = (CCSprite* )[self.backgroundNode getChildByName:@"scaleCircle2" recursively:NO];
    
//    __unsafe_unretained SecondObserveScene* weakSelf = self;
    __unsafe_unretained CCSprite* scaleCircleTwoTemp = scaleCircleTwo;
    __unsafe_unretained CCSprite* scaleCircleOneTemp = scaleCircleOne;
    __unsafe_unretained NSMutableArray* observedSpriteArrayTemp = self.observedSpriteArray;
    [scaleCircleOne runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:0.f], [CCActionCallBlock actionWithBlock:^{
//        spark
        SparkNode* spark = [SparkNode node];
        spark.imageNamesArray = @[@"spark1_observe.png", @"spark2_observe.png"];
        spark.numberOfDirections = 8;
        spark.imageAngleOffset = 0;
        spark.isDestroySelf = YES;
        spark.duration = 0.5f;
        spark.distance = 150;
        spark.position = scaleCircleOneTemp.position;
        [self.backgroundNode addChild:spark z:1000];
//        fireworks
        Fireworks* bubbles = [Fireworks node];
        bubbles.position = scaleCircleOneTemp.position;
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
        [scaleCircleOneTemp removeAllChildren];
        [scaleCircleOneTemp removeFromParent];
    }], nil]];
    [scaleCircleTwo runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:0.f], [CCActionCallBlock actionWithBlock:^{
//        spark
        SparkNode* spark = [SparkNode node];
        spark.imageNamesArray = @[@"spark1_observe.png", @"spark2_observe.png"];
        spark.numberOfDirections = 8;
        spark.imageAngleOffset = 0;
        spark.isDestroySelf = YES;
        spark.duration = 0.5f;
        spark.distance = 150;
        spark.position = scaleCircleTwoTemp.position;
        [self.backgroundNode addChild:spark z:1000];
//        fireworks
        Fireworks* bubbles = [Fireworks node];
        bubbles.position = scaleCircleTwoTemp.position;
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
        [scaleCircleTwoTemp removeAllChildren];
        [scaleCircleTwoTemp removeFromParent];

        self.homeButton.enabled = YES;
        [self goOver];
        
        for (CCSprite* sprite in observedSpriteArrayTemp) {
            __unsafe_unretained CCSprite* spriteTemp = sprite;
            [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
                [spriteTemp removeFromParent];
            }], nil]];
        }
        [observedSpriteArrayTemp removeAllObjects];
    }], nil]];
    
    for (CCNode* tipNode in _tipsArray) {
//        [tipNode runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.7f scaleX:1.f scaleY:0.f], [CCActionCallBlock actionWithBlock:^{
//            [tipNode removeAllChildren];
//            [tipNode removeFromParent];
//        }], nil]];
        
        for (int i = 0; i < tipNode.children.count; i++) {
            CCNode* tip = tipNode.children[i];
            [tip runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:0.7f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
                if (i == 1) {
                    [tipNode removeAllChildren];
                    [tipNode removeFromParent];
                }
            }], nil]];
        }
    }
}

-(void)createGoNextSprite{
    self.step++;
    self.nextButton.visible = YES;
    self.nextButton.enabled = YES;
}

-(void)goOver{
//    bg
    CCSprite* worldBg = [CCSprite spriteWithImageNamed:@"bg_world_observe.png"];
    worldBg.position = ccp(512, 384);
    worldBg.scale = 0.f;
    [self.backgroundNode addChild:worldBg z:WORLDORDER];
    
//    plants
    CGPoint positions[] = {ccp(1053/2.f, 768 - 739/2.f), ccp(1017/2.f, 768 - 703.5/2.f)};
    for (int i = 0; i < 2; i++) {
        CCSprite* plant = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"plant%d_world_observe.png", i + 1]];
        plant.position = positions[i];
        plant.scale = 0.f;
        plant.name = [NSString stringWithFormat:@"plant%d", i + 1];
        [self.backgroundNode addChild:plant z:WORLDORDER + 2 - i];
        
        [plant runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f + 0.2f * i], [CCActionScaleTo actionWithDuration:1.f scale:1.1f], [CCActionScaleTo actionWithDuration:0.2f scale:0.95f], [CCActionScaleTo actionWithDuration:0.1f scale:1.f], nil]];
    }
    
//    board
    CCSprite* worldBoard = [CCSprite spriteWithImageNamed:@"board_world_observe.png"];
    worldBoard.position = ccp(1023.5/2.f, 768 - 781.5/2.f);
    [self.backgroundNode addChild:worldBoard z:WORLDORDER + 3];
    
//    icon
    CCSprite* iconSprite = [CCSprite spriteWithImageNamed:@"icon_world_observe.png"];
    iconSprite.position = [worldBoard convertToNodeSpace:ccp(1021/2.f, 768 - 661/2.f)];
    [worldBoard addChild:iconSprite];
    
//    bubble
    CGPoint bubblePositions[] = {ccp(117, 221), ccp(911, 207), ccp(182, 640), ccp(637, 634), ccp(637, 97)};
    for (int i = 0; i < 5; i++) {
        CCSprite* bubble = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"bubble%d_world_observe.png", i + 1]];
        bubble.position = bubblePositions[i];
        bubble.scale = 0.f;
        bubble.opacity = 0.f;
        [self.backgroundNode addChild:bubble z:WORLDORDER + 4];
        
        CCSprite* light = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"light%d_world_observe.png", i + 1]];
        light.position = bubblePositions[i];
        light.opacity = 0.f;
        [self.backgroundNode addChild:light z:WORLDORDER + 4];
        
        CCTime duration = arc4random()%8 * 0.1f;
        [bubble runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.2f + duration], [CCActionSpawn actionOne:[CCActionScaleTo actionWithDuration:1.f scale:1.f] two:[CCActionFadeTo actionWithDuration:1.f opacity:1.f]], [CCActionCallBlock actionWithBlock:^{
            light.opacity = 1.f;
            [bubble removeFromParent];
            [light runAction:[CCActionSequence actions:[CCActionSpawn actionOne:[CCActionScaleTo actionWithDuration:0.5f scale:1.2f] two:[CCActionFadeTo actionWithDuration:0.5f opacity:0.f]], nil]];
        }], nil]];
    }
    
//    go world
    TouchSprite* goWorldSprite = [TouchSprite spriteWithImageNamed:@"go_world_observe.png"];
    goWorldSprite.position = iconSprite.position;
    goWorldSprite.opacity = 0.f;
    goWorldSprite.userInteractionEnabled = NO;
    [worldBoard addChild:goWorldSprite];
    
    __unsafe_unretained CCSprite* plantOneTemp = (CCSprite* )[self.backgroundNode getChildByName:@"plant1" recursively:NO];
    __unsafe_unretained CCSprite* plantTwoTemp = (CCSprite* )[self.backgroundNode getChildByName:@"plant2" recursively:NO];
//    __unsafe_unretained CCSprite* homeTemp = (CCSprite* )[_backgroundNode getChildByName:@"home" recursively:NO];
    __unsafe_unretained TouchSprite* goWorldSpriteTemp = goWorldSprite;
    __unsafe_unretained CCSprite* worldBoardTemp = worldBoard;
    __unsafe_unretained ObserveScaleScene* weakSelf = self;
    goWorldSprite.touchBegan = ^(UITouch* touch){
        goWorldSpriteTemp.userInteractionEnabled = NO;
        [goWorldSpriteTemp runAction:[ActionProvider getPressBeginAction]];
    };
    
    goWorldSprite.touchEnded = ^(UITouch* touch){
//        homeTemp.userInteractionEnabled = NO;
        weakSelf.homeButton.visible = NO;
        [goWorldSpriteTemp runAction:[ActionProvider getPressEndAction]];
        [plantOneTemp runAction:[CCActionScaleTo actionWithDuration:0.5f scale:0.f]];
        [plantTwoTemp runAction:[CCActionScaleTo actionWithDuration:0.5f scale:0.f]];
        [worldBoardTemp runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:0.f], [CCActionDelay actionWithDuration:0.1f], [CCActionCallBlock actionWithBlock:^{
            [[CCDirector sharedDirector] replaceScene:[FishLivingEnvironmentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:0.01f]];
        }], nil]];
    };
    
    goWorldSprite.touchCanceled = ^(UITouch* touch){
        [goWorldSpriteTemp runAction:[ActionProvider getPressEndAction]];
        goWorldSpriteTemp.userInteractionEnabled = YES;
    };
    
//    actions
    worldBoard.scale = 0.f;
    
    [worldBg runAction:[CCActionScaleTo actionWithDuration:1.f scale:3.f]];
    [worldBoard runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:1.f], [CCActionCallBlock actionWithBlock:^{
        
    }], nil]];
    
    __unsafe_unretained CCSprite* iconSpriteTemp = iconSprite;
    [goWorldSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:4.5f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
        goWorldSpriteTemp.userInteractionEnabled = YES;
        [iconSpriteTemp removeFromParent];
    }], nil]];
}




-(void)onExit{
    [_tipsArray removeAllObjects];
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{
    
}

@end
