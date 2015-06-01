//
//  SubmarineScene.m
//  DDT-Carp
//
//  Created by Z on 14/11/12.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "SubmarineScene.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "TouchSprite.h"
#import "MoveSprite.h"
#import "CCTextureCache.h"
#import "CCAnimation+Helper.h"
#import "CCTextureCache.h"
#import "SubmarineLevelManager.h"
#import "FishNode.h"
#import "BubbleBlowNode.h"
#import "OALSimpleAudio.h"

#import "ContentScene.h"
#import "ObserveBladderScene.h"
#import "ObserveFinScene.h"

#define SKYORDER 100
#define WATERORDER 200
#define HILLORDER 300
#define WAVEORDER 400
#define LIGHTORDER 500
#define PHYSICSORDER 600
#define SUBMARINEORDER 700
#define PRESSORDER 700
#define COMPLETEORDER 10000

@interface SubmarineScene ()<CCPhysicsCollisionDelegate>
{
    CCNode* _backgroundNode;
    NSMutableArray* _movedSprites;
    NSMutableArray* _movedFish;
    
//    physics
    CCPhysicsNode* _physicsNode;
    TouchSprite* _submarineSprite;
    
//    level
    int _currentLevel;
    
//    game control
    BOOL _gameStart;
    
//    tip
    CCNode* _tipNode;
    BOOL _showTip;
    BOOL _showingTipOne;
    BOOL _showingTipTwo;
    BOOL _showingTipThree;
    int _tipStep;
    BOOL _fishEnabled;
    BOOL _touchEnabled;
    
//    press
    CCSprite* _pressWater;
    CCSprite* _bigPointer;
    CCSprite* _smallPointer;
}
@end

@implementation SubmarineScene
+(SubmarineScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        _gameStart = NO;
        _currentLevel = 0;
        _movedSprites = [[NSMutableArray alloc] init];
        _movedFish = [[NSMutableArray alloc] init];
        
//        tip
        _showingTipOne = NO;
        _showingTipTwo = NO;
        _showingTipThree = NO;
        NSString* tip = [[NSUserDefaults standardUserDefaults] objectForKey:@"submarine"];
        if (tip == nil || [tip isEqualToString:@""]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"tip" forKey:@"submarine"];
            _showTip = YES;
            _tipStep = 1;
        }
        else{
            _showTip = NO;
            _tipStep = 0;
        }
//        _showTip = YES;
//        _tipStep = 1;
        _fishEnabled = !_showTip;
        _touchEnabled = !_showTip;
        
//        base words
        
        if (_showTip) {
            self.prevButton.visible = NO;
            self.nextButton.visible = NO;
            self.homeButton.visible = NO;
            self.currentScene = @"submarine";
            self.imageSuffix = @"observe";
            self.wordsOffset = ccp(0.f, 100.f);
        }
    }
    return self;
}

-(void)update:(CCTime)delta{
    if (_gameStart) {
        if (_fishEnabled) {
            for (int i = 0; i < _movedFish.count; i++) {
                FishNode* fishNode = _movedFish[i];
                if (fishNode.position.x <= 512 && [fishNode.fishInfo[@"level"] intValue] == _currentLevel) {
                    _currentLevel++;
                    [self addFishToPhysicsWorld];
                }
//                tip three
                if (_showTip) {
                    if (fishNode.position.x <= 924 && [fishNode.fishInfo[@"level"] intValue] == 1) {
                        if (_tipStep == 3) {
                            _tipStep = 0;
                            [self showTip:3];
                            _fishEnabled = NO;
                        }
                    }
                }
                if (fishNode.position.x <= -512) {
                    [fishNode removeFromParent];
                    [_movedFish removeObject:fishNode];
                    i--;
                    continue;
                }
                CGFloat duration = [fishNode.fishInfo[@"duration"] doubleValue];
                CGFloat xOffset = 1024.f/duration * delta;
                fishNode.position = ccpAdd(fishNode.position, ccp(-xOffset, 0));
            }
        }
        
//        press
//        81 - 549
        CGFloat lowestY = _submarineSprite.contentSize.height/2;
        CGFloat highestY = 630 - _submarineSprite.contentSize.height/2 + 55;
        CGFloat heightRange = highestY - lowestY;
        CGFloat ratio = (_submarineSprite.position.y - lowestY)/heightRange;
//        NSLog(@"%f, %f, %f", _submarineSprite.position.y, heightRange, ratio);
        _bigPointer.rotation = ratio * 360.f;
        _smallPointer.rotation = ratio * 360.f * 3;
        _pressWater.scaleY = (1 - ratio) * 1.22f;
        
//        tip two
        if (_showTip) {
            if(_submarineSprite.position.y <= lowestY + 5){
                if (_tipStep == 2) {
                    _tipStep = 3;
                    [self showTip:2];
                }
            }
            
        }
        
//        complete
        if(_movedFish.count == 0){
            [self gameEnd];
        }
    }
}

-(void)onEnter{
    [super onEnter];
    [self createBackground];
    [self createPhysicsWorld];
}

-(void)prevPress:(CCButton *)button{
    if (self.step == 1 && _showTip == YES) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"submarine"];
    }
    [[CCDirector sharedDirector] replaceScene:[ObserveBladderScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    [self handleButtons:NO];
}

-(void)nextPress:(CCButton *)button{
    if (self.step == 1) {
        if (_showTip == YES) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"submarine"];
        }
        [[CCDirector sharedDirector] replaceScene:[ObserveFinScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    else{
        TouchSprite* replaySprite = (TouchSprite* )[_backgroundNode getChildByName:@"replay" recursively:YES];
        [replaySprite.parent runAction:[CCActionSequence actions:[ActionProvider getJumpOutToBottomFrom:replaySprite.parent.position andEndPosition:ccp(replaySprite.parent.position.x, -replaySprite.parent.contentSize.height/2) andDuration:1.f], [CCActionCallBlock actionWithBlock:^{
            [replaySprite.parent removeFromParent];
            [replaySprite.parent removeAllChildren];
            [self isReplayGame:NO andIsPerfect:[button.name intValue] == 3 ? YES : NO];
            button.name = nil;
        }], nil]];
    }
    [self handleButtons:NO];
}

//tip
-(void)showTip:(int)index{
    const CGFloat defaultLength = 30.f;
    
    NSString* tipStr = [NSString stringWithFormat:@"submarine_tip%d", index];
    NSString* tip = NSLocalizedString(tipStr, nil);
    CGFloat fontSize = [NSLocalizedString(@"submarine_tip_font_size", nil) doubleValue];
    CGFloat letterWidth = [NSLocalizedString(@"submarine_tip_letter_width", nil) doubleValue];
    
    CGSize fontDimension = (CGSize){12 * defaultLength, 0.f};
    
    CGFloat rectScaleY = 1.f;
    if (tip.length * letterWidth / fontDimension.width > 2.f) {
        int row = ceil(tip.length * letterWidth / fontDimension.width);
        rectScaleY = row/2.f;
    }
    
    CCSprite* rect = [CCSprite spriteWithImageNamed:@"tips_bg_submarine.png"];
    
    _tipNode = [CCNode node];
    _tipNode.contentSize = rect.contentSize;
    _tipNode.anchorPoint = ccp(0.5f, 0.5f);
    _tipNode.position = ccp(512, 384);
    [_backgroundNode addChild:_tipNode z:COMPLETEORDER];
    
    rect.position = [_tipNode convertToNodeSpace:ccp(512, 384)];
    rect.scaleY = rectScaleY;
    [_tipNode addChild:rect z:1];
    
    CCLabelTTF* tipLabel = [CCLabelTTF labelWithString:tip fontName:@"STYuanti-SC-Regular" fontSize:fontSize dimensions:fontDimension];
    tipLabel.position = [_tipNode convertToNodeSpace:ccp(512, 384)];
    tipLabel.horizontalAlignment = CCTextAlignmentCenter;
    tipLabel.color = [CCColor whiteColor];
    [_tipNode addChild:tipLabel z:1];
    
//    _tipNode.scaleX = 0.f;
    _tipNode.name = @"tipNode";
//    [_tipNode runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scaleX:1.f scaleY:1.f], [CCActionCallBlock actionWithBlock:^{
//        switch (index) {
//            case 1:
//                _showingTipOne = YES;
//                break;
//            case 2:
//                _showingTipTwo = YES;
//                break;
//            case 3:
//                _showingTipThree = YES;
//                break;
//            default:
//                break;
//        }
//    }], nil]];
    rect.opacity = 0.f;
    [rect runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
    tipLabel.opacity = 0.f;
    [tipLabel runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
        switch (index) {
            case 1:
                _showingTipOne = YES;
                break;
            case 2:
                _showingTipTwo = YES;
                break;
            case 3:
                _showingTipThree = YES;
                break;
            default:
                break;
        }
    }], nil]];
}

-(void)createBackground{
//    init
    _backgroundNode = [CCNode node];
    _backgroundNode.contentSize = [[CCDirector sharedDirector] viewSize];
    _backgroundNode.anchorPoint = ccp(0, 0);
    _backgroundNode.position = ccp(0, 0);
    [self addChild:_backgroundNode z:1];
    
//    sky
    CCSprite* skySprite = [CCSprite spriteWithImageNamed:@"sky_submarine.png"];
    skySprite.anchorPoint = ccp(0, 0);
    skySprite.position = ccp(0, 0);
    skySprite.name = @"sky";
    [_backgroundNode addChild:skySprite z:SKYORDER];
    if (self.isFromObserveScene) {
        skySprite.opacity = 0;
        [skySprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:2.f opacity:1], [CCActionCallBlock actionWithBlock:^{
            
        }], nil]];
    }

//    cloud
    [self createClouds];
//    water
    [self createWaters];
//    hill
    [self createHills];
    
//    wave
    CCSprite* waveSprite = [CCSprite spriteWithImageNamed:@"wave_submarine.png"];
    waveSprite.name = @"wave";
    waveSprite.anchorPoint = ccp(0, 0);
    waveSprite.position = ccp(0, 0);
    [_backgroundNode addChild:waveSprite z:WAVEORDER];
    waveSprite.opacity = 0;
    [waveSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
    
//    light
    [self createLights];
    
//    submarine
    [self createSubmarine:!_showTip];
    
//    press
    [self createPress];
}

-(void)createClouds{
    CGPoint cloudPoints[] = {ccp(541/2, 768 - 105/2), ccp(1096/2, 768 - 107/2), ccp(1758/2, 768 - 87/2), ccp(800, 688)};
    for (int i = 0; i < 4; i++) {
        MoveSprite* cloud = [MoveSprite spriteWithImageNamed:i != 3 ? [NSString stringWithFormat:@"cloud%d_submarine.png", i + 1] : @"rain1_submarine.png"];
        cloud.name = [NSString stringWithFormat:@"cloud%d", i + 1];
        cloud.position = ccpAdd(cloudPoints[i], i != 3 ? ccp(0, 400) : ccp(1024, 0));
        if (i != 3) {
            [cloud runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:2.f position:cloudPoints[i]], nil]];
        }
        else{
            CCAnimation* rainAnimation = [CCAnimation animationWithFile:@"rain" withSuffix:@"_submarine" frameCount:2 delay:1/6.f];
            [cloud runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:rainAnimation]]];
        }
        [_movedSprites addObject:cloud];
        [_backgroundNode addChild:cloud z:SKYORDER];
        cloud.isBezierMove = NO;
        cloud.randomStartPoint = NO;
        cloud.randomEndPoint = NO;
        cloud.isRandomDuration = NO;
        cloud.isDetroySelf = NO;
        cloud.startPoint = i != 3 ? cloudPoints[i] : ccpAdd(cloudPoints[i], ccp(1024, 0));
        cloud.endPoint = ccpAdd(cloudPoints[i], ccp(-1024, 0));
        cloud.endScale = 1.f;
        CGFloat duration = 35.f + arc4random()%5;
        cloud.duration = i != 3 ? duration : 2.f * duration;
        cloud.delayCreationTime = 0.f;
//        __block MoveSprite* cloudTemp = cloud;
        __block CGPoint pointTemp = cloudPoints[i];
        __unsafe_unretained MoveSprite* cloudTemp = cloud;
//        __unsafe_unretained CGPoint pointTemp = cloudPoints[i];
        cloud.cycleBlock = ^(){
            cloudTemp.startPoint = ccpAdd(pointTemp, ccp(1024, 0));
            cloudTemp.duration = (35.f + arc4random()%5) * 2.f;
        };
    }
}

-(void)createWaters{
    CGFloat ys[] = {768 - 896/2.f, 768 - 380.5/2.f, 768 - 333/2.f};
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 2; j++) {
            MoveSprite* water = [MoveSprite spriteWithImageNamed:[NSString stringWithFormat:@"water%d_submarine.png", i + 1]];
            water.anchorPoint = ccp(0, 0.5f);
            water.name = [NSString stringWithFormat:@"water%d", i + 1];
            __unsafe_unretained MoveSprite* waterTemp = water;
            if (j == 0) {
                water.position = ccp(0, - water.contentSize.height - 180 + i * 60);
                [water runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f + i * 0.f position:ccp(0, ys[i])], [CCActionCallBlock actionWithBlock:^{
                    waterTemp.isMoveStart = NO;
                }], nil]];
            }
            else{
                water.flipX = YES;
                water.position = ccp(1024, ys[i]);
            }
            [_backgroundNode addChild:water z:WATERORDER + 2 - i];
            [_movedSprites addObject:water];

            water.randomStartPoint = NO;
            water.randomEndPoint = NO;
            water.isBezierMove = NO;
            water.isRandomDuration = NO;
            water.isDetroySelf = NO;
            water.startPoint = ccp(j == 0 ? 0 : 1024, ys[i]);
            water.endPoint = ccp(-1024, ys[i]);
            water.endScale = 1.f;
            water.duration = (15.f + i * 3) * (j == 0 ? 1.f : 2.f);
            water.delayCreationTime = 0.f;
            __block CGFloat yTemp = ys[i];
            __block int iTemp = i;
            water.cycleBlock = ^(){
                waterTemp.startPoint = ccp(1023, yTemp);
                waterTemp.duration = 2.f * (15.f + 3 * iTemp);
            };
        }
    }
}

-(void)createHills{
    CGPoint hillPoints[] = {ccp(265, 0.f), ccp(745, 0.f), ccp(1591/2.f, 0.f), ccp(526.5/2.f, 0.f)};
    CGFloat durations[] = {25.f, 30.f, 35.f, 40.f};
    for (int i = 0; i < 4; i++) {
        MoveSprite* hillSprite = [MoveSprite spriteWithImageNamed:[NSString stringWithFormat:@"hill%d_submarine.png", i + 1]];
        hillSprite.name = [NSString stringWithFormat:@"hill%d", i + 1];
        hillSprite.anchorPoint = ccp(0.5f, 0.f);
        hillSprite.position = ccpAdd(hillPoints[i], i < 2 ? ccp(1024, 0) : ccp(0, 0));
        [_backgroundNode addChild:hillSprite z:HILLORDER + 3 - i];
        [_movedSprites addObject:hillSprite];
        if (i > 1) {
            hillSprite.opacity = 0;
            [hillSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1], nil]];
        }
        hillSprite.randomStartPoint = NO;
        hillSprite.randomEndPoint = NO;
        hillSprite.isRandomDuration = NO;
        hillSprite.isDetroySelf = NO;
        hillSprite.isBezierMove = NO;
        hillSprite.startPoint = i > 1 ? hillPoints[i] : ccpAdd(hillPoints[i], ccp(1024, 0));
        hillSprite.endPoint = ccpAdd(hillPoints[i], ccp(-1024, 0));
        hillSprite.endScale = 1.f;
        hillSprite.duration = (i > 1 ? 1.f : 2.f) * durations[i];
        hillSprite.delayCreationTime = 0.f;
        __unsafe_unretained MoveSprite* hillTemp = hillSprite;
        __block CGPoint hillPointTemp = hillPoints[i];
        __block CGFloat durationTemp = durations[i];
        hillSprite.cycleBlock = ^(){
            hillTemp.startPoint = ccpAdd(hillPointTemp, ccp(1024, 0));
            hillTemp.duration = durationTemp * 2.f;
        };
    }
}

-(void)createLights{
    for (int i = 0; i < 2; i++) {//0 - left 1 - right
        for (int j = 0; j < 2; j++) {
            MoveSprite* lightSprite = [MoveSprite spriteWithImageNamed:@"light_submarine.png"];
            lightSprite.name = [NSString stringWithFormat:@"light%d", i * 2 + j + 1];
            lightSprite.randomStartPoint = NO;
            lightSprite.randomEndPoint = NO;
            lightSprite.isBezierMove = NO;
            lightSprite.startPoint = ccp(1043/2 + 1024 * j * (i == 0 ? 1 : -1), 768 - 898/2);
            lightSprite.endPoint =  ccp(1043/2 + 1024 * (i == 0 ? -1 : 1), 768 - 898/2);
            lightSprite.isDetroySelf = NO;
            lightSprite.endScale = 1.f;
            lightSprite.isRandomDuration = NO;
            lightSprite.duration = j == 0 ? 18.f : 36.f;
            lightSprite.delayCreationTime = 0.f;
            __unsafe_unretained MoveSprite* lightSpriteTemp = lightSprite;
            __block int iTemp = i;
            lightSprite.cycleBlock = ^(){
                lightSpriteTemp.startPoint = ccp(1043/2 + 1024 * (iTemp == 0 ? 1 : -1), 768 - 898/2);
                lightSpriteTemp.endPoint =  ccp(1043/2 + 1024 * (iTemp == 0 ? -1 : 1), 768 - 898/2);
                lightSpriteTemp.duration = 36.f;
            };
            lightSprite.isMoveStart = YES;
            [_backgroundNode addChild:lightSprite z:LIGHTORDER];
            lightSprite.opacity = 0;
            [lightSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
        }
    }
}

-(void)createSubmarine:(BOOL) isReplay{
    _submarineSprite = [TouchSprite spriteWithImageNamed:@"submarine_submarine.png"];
    _submarineSprite.position = ccp(-_submarineSprite.contentSize.width, 768 - 518/2.f);
    [_backgroundNode addChild:_submarineSprite z:SUBMARINEORDER];
    __block SubmarineScene* weakSelf = self;
    [_submarineSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionMoveTo actionWithDuration:1.f position:ccp(483/2.f, 768 - 518/2.f)], [CCActionCallBlock actionWithBlock:^{
        if (isReplay) {
            [weakSelf prepareForGameStart];
        }
    }], nil]];
}

-(void)createScene{
    [self prepareForGameStart];
}

-(void)createPress{
    CCSprite* pressSprite = [CCSprite spriteWithImageNamed:@"press_submarine.png"];
    pressSprite.name = @"press";
    pressSprite.position = ccp(1944/2.f, 768 - 279/2.f);
    [_backgroundNode addChild:pressSprite z:PRESSORDER];
    
//    circle & pointer
    CCSprite* bigCircle = [CCSprite spriteWithImageNamed:@"press_circle_big_submarine.png"];
    bigCircle.position = [pressSprite convertToNodeSpace:ccp(1928/2.f, 768 - 90/2.f)];
    [pressSprite addChild:bigCircle z:1];
    
    _bigPointer= [CCSprite spriteWithImageNamed:@"press_pointer_big_submarine.png"];
    _bigPointer.anchorPoint = ccp(0.5f, 0.f);
    _bigPointer.position = [pressSprite convertToNodeSpace:ccp(1928/2.f, 768 - 88/2.f + 5 - _bigPointer.contentSize.height/2.f)];
    [pressSprite addChild:_bigPointer z:1];
    
    CCSprite* smallCircle = [CCSprite spriteWithImageNamed:@"press_circle_small_submarine.png"];
    smallCircle.position = [pressSprite convertToNodeSpace:ccp(1889/2.f, 768 - 111/2.f)];
    [pressSprite addChild:smallCircle z:1];
    
    _smallPointer = [CCSprite spriteWithImageNamed:@"press_pointer_small_submarine.png"];
    _smallPointer.anchorPoint = ccp(0.5f, 0.f);
    _smallPointer.position = [pressSprite convertToNodeSpace:ccp(1889/2.f, 768 - 109/2.f + 4 - _smallPointer.contentSize.height/2.f)];
    [pressSprite addChild:_smallPointer z:1];
    
//    water
    _pressWater = [CCSprite spriteWithImageNamed:@"press_water_submarine.png"];
    _pressWater.anchorPoint = ccp(0.5f, 0.f);
    _pressWater.position = [pressSprite convertToNodeSpace:ccp(1915/2.f, 768 - 302/2.f -  _pressWater.contentSize.height/2.f)];
    [pressSprite addChild:_pressWater z:1];
    
//    light
    CCSprite* light = [CCSprite spriteWithImageNamed:@"press_light_submarine.png"];
    light.position = [pressSprite convertToNodeSpace:ccp(1914/2, 768 - 271/2)];
    [pressSprite addChild:light z:2];
    
    pressSprite.position = ccp(1024 + pressSprite.contentSize.width/2.f, 768 - 279/2.f);
}

-(void)prepareForGameStart{
    [_submarineSprite runAction:[ActionProvider getRepeatBlinkPrompt]];
    _submarineSprite.userInteractionEnabled = YES;
    __unsafe_unretained NSMutableArray* movedSpritesTemp = _movedSprites;
    __unsafe_unretained TouchSprite* submarineSpriteTemp = _submarineSprite;
    __unsafe_unretained SubmarineScene* weakSelf = self;
    _submarineSprite.touchBegan = ^(UITouch* touch){
//        [[OALSimpleAudio sharedInstance] playBg:@"water.mp3" loop:YES];
        [weakSelf handleButtons:NO];
        weakSelf.homeButton.enabled = NO;
        [submarineSpriteTemp stopAllActions];
        submarineSpriteTemp.visible = YES;
        submarineSpriteTemp.userInteractionEnabled = NO;
        for (MoveSprite* moveSprite in movedSpritesTemp) {
            moveSprite.isMoveStart = YES;
        }
        submarineSpriteTemp.touchBegan = nil;
        [weakSelf addSubmarineToPhysicsWorld];
        [weakSelf prepareForLevelInfo];
        [weakSelf showPress];
    };
//    [self prepareForLevelInfo];
}

-(void)showPress{
//        tip one
    if (_showTip) {
        [self showTip:1];
        _physicsNode.gravity = ccp(0.f, -0.0000001f);
    }
    CCSprite* press = (CCSprite* )[_backgroundNode getChildByName:@"press" recursively:NO];
    [press runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f position:ccp(1944/2.f, 768 - 279/2.f)], [CCActionCallBlock actionWithBlock:^{

    }], nil]];
}

-(void)hidePress{
    CCSprite* press = (CCSprite* )[_backgroundNode getChildByName:@"press" recursively:NO];
    [press runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f position:ccp(1024 + press.contentSize.width/2.f, 768 - 279/2.f)], nil]];
}

-(void)addSubmarineToPhysicsWorld{
    [_submarineSprite removeFromParent];
    [_physicsNode addChild:_submarineSprite z:2];
    CCPhysicsShape* rectOne = [CCPhysicsShape rectShape:(CGRect){0, 0, _submarineSprite.contentSize.width, 97}  cornerRadius:0];
    CCPhysicsShape* rectTwo = [CCPhysicsShape rectShape:(CGRect){_submarineSprite.contentSize.width/2 - 88/2 + 10, 97, 88, 43} cornerRadius:0];
    _submarineSprite.physicsBody = [CCPhysicsBody bodyWithShapes:@[rectOne, rectTwo]];
    _submarineSprite.physicsBody.collisionType = @"submarine";
    _submarineSprite.physicsBody.type = CCPhysicsBodyTypeDynamic;
    
//    add bubbles
    BubbleBlowNode* bubbles = [BubbleBlowNode node];
    bubbles.imagesArray = @[@"bubble1.png", @"bubble2.png", @"bubble3.png", @"bubble4.png", @"bubble5.png"];
    bubbles.position = ccp(0, 0);
    bubbles.bubbleNum = 8;
    bubbles.startX = 40;
    bubbles.startYRange = (NSRange){37, 17};
    bubbles.startScaleRange = (NSRange){1, 2};
    bubbles.isRepeat = YES;
    bubbles.distance = -170;
    bubbles.duration = 1.2f;
    [_submarineSprite addChild:bubbles z:-1];
}

-(void)prepareForLevelInfo{
    SubmarineLevelManager* manager = [SubmarineLevelManager sharedSubmarineManager];
    [manager loadLevelInfo];
    _currentLevel = 1;
    [self addFishToPhysicsWorld];
    _gameStart = YES;
}

-(void)addFishToPhysicsWorld{
    SubmarineLevelManager* manager = [SubmarineLevelManager sharedSubmarineManager];
    if(_currentLevel > manager.levelInfo.count){
//        last fish school
        return;
    }
    NSArray* fish = manager.levelInfo[[NSString stringWithFormat:@"level%d", _currentLevel]][@"fishes"];
    for (int i = 0; i < fish.count; i++) {
        FishNode* fishNode = [[FishNode alloc] initWithFishInfo:fish[i]];
        [_physicsNode addChild:fishNode z:SUBMARINEORDER];
        [_movedFish addObject:fishNode];
    }
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair submarine:(CCNode *)nodeA fishNode:(CCNode *)nodeB{
    NSLog(@"eee~~");
    [self gameEnd:(FishNode* )nodeB];
    return YES;
}

-(void)stopGame{
    _gameStart = NO;
    for (MoveSprite* sprite in _movedSprites) {
        sprite.isMoveStart = NO;
    }
}

-(void)gameEnd{
    [self stopGame];
    [self hidePress];
    BubbleBlowNode* bubbles = (BubbleBlowNode* )_submarineSprite.children.firstObject;
    bubbles.isRepeat = NO;
    [bubbles removeAllChildren];
    [_submarineSprite removeChild:bubbles];
    _submarineSprite.physicsBody = nil;
    [_physicsNode removeChild:_submarineSprite];
    [_backgroundNode addChild:_submarineSprite z:SUBMARINEORDER];
    [_submarineSprite addChild:bubbles z:-1];
    bubbles.isRepeat = YES;
    __block SubmarineScene* weakSelf = self;
    [_submarineSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:2.f position:ccp(512, 300)], [CCActionCallBlock actionWithBlock:^{
        [weakSelf gameComplete:_currentLevel];
    }], nil]];
}

-(void)gameEnd:(FishNode* )collisionFishNode{
    [self stopGame];
    [self hidePress];
    for (FishNode* fishNode in _movedFish) {
        fishNode.physicsBody = nil;
        [_physicsNode removeChild:fishNode];
        [_backgroundNode addChild:fishNode z:SUBMARINEORDER];
        
        __block FishNode* fishNodeTemp = fishNode;
        if (fishNode.position.x >= collisionFishNode.position.x) {
            fishNode.allFlipX = YES;
            [fishNode runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:2.f position:ccp(1300, fishNode.position.y)], [CCActionCallBlock actionWithBlock:^{
                [fishNodeTemp removeFromParent];
            }], nil]];
        }
        else{
            [fishNode runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f position:ccp(-300, fishNode.position.y)], [CCActionCallBlock actionWithBlock:^{
                [fishNodeTemp removeFromParent];
            }], nil]];
        }
    }
    BubbleBlowNode* bubbles = (BubbleBlowNode* )_submarineSprite.children.firstObject;
    bubbles.isRepeat = NO;
    [bubbles removeAllChildren];
    [_submarineSprite removeChild:bubbles];
    _submarineSprite.physicsBody = nil;
    [_physicsNode removeChild:_submarineSprite];
    [_backgroundNode addChild:_submarineSprite z:SUBMARINEORDER];
    [_submarineSprite addChild:bubbles z:-1];
    bubbles.isRepeat = YES;
    ccBezierConfig submarineBezier;
    submarineBezier.controlPoint_1 = ccp(_submarineSprite.position.x + 200, _submarineSprite.position.y);
    submarineBezier.controlPoint_2 = submarineBezier.controlPoint_1;
    submarineBezier.endPosition = ccp(_submarineSprite.position.x + 300, _submarineSprite.contentSize.height/2);
    
    __block SubmarineScene* weakSelf = self;
    __block FishNode* collisionFishNodeTemp = collisionFishNode;
    [_submarineSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionRotateTo actionWithDuration:2.f angle:90.f], [CCActionBezierTo actionWithDuration:2.f bezier:submarineBezier], nil], [CCActionCallBlock actionWithBlock:^{
        [weakSelf gameComplete:[collisionFishNodeTemp.fishInfo[@"level"] intValue]];
    }], nil]];
}

-(void)gameComplete:(int)finishLevel{
    NSLog(@"%d", finishLevel);
    NSUInteger totalLevel = [[SubmarineLevelManager sharedSubmarineManager].levelInfo count];
    int starCount = 0;
    if (finishLevel <= 1) {
        starCount = 0;
    }
    else if(finishLevel < totalLevel/2 + 2){
        starCount = 1;
    }
    else if(finishLevel < totalLevel + 1){
        starCount = 2;
    }
    else{
        starCount = 3;
    }
    [self showCompleteBoardWithLevet:starCount];
}

-(void)showCompleteBoardWithLevet:(int)starCount{
    CGSize viewSize = [[CCDirector sharedDirector] viewSize];
    CCSprite* completeBoard = [CCSprite spriteWithImageNamed:@"complete_board_submarine.png"];
    completeBoard.position = ccp(viewSize.width/2, viewSize.height/2);
    [_backgroundNode addChild:completeBoard z:COMPLETEORDER];
    
//    dark stars
    CGPoint points[] = {ccp(729/2.f, 768 - 417/2.f), ccp(1022/2.f, 768 - 348/2.f), ccp(1331/2.f, 768 - 417/2.f)};
    __block NSMutableArray* starArray = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        CCSprite* star = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"complete_star_dark%d_submarine.png", i + 1]];
        star.position = [completeBoard convertToNodeSpace:points[i]];
        star.name = [NSString stringWithFormat:@"complete_star%d_submarine.png", i + 1];
        [completeBoard addChild:star z:2];
        [starArray addObject:star];
    }
    
//    replay & go
    TouchSprite* replaySprite = [TouchSprite spriteWithImageNamed:@"complete_replay_submarine.png"];
    replaySprite.position = [completeBoard convertToNodeSpace:ccp(1022/2.f, 768 - 1300/2.f)];
    replaySprite.name = @"replay";
    [completeBoard addChild:replaySprite];
    replaySprite.userInteractionEnabled = YES;
    __unsafe_unretained TouchSprite* replaySpriteTemp = replaySprite;
    __unsafe_unretained SubmarineScene* weakSelf = self;
    __block int starCountTemp = starCount;
    replaySprite.touchBegan = ^(UITouch* touch){
        [replaySpriteTemp runAction:[ActionProvider getPressBeginAction]];
    };
    
    replaySprite.touchEnded = ^(UITouch* touch){
        replaySpriteTemp.userInteractionEnabled = NO;
//        [(TouchSprite* )replaySpriteTemp.parent getChildByName:@"go" recursively:NO].userInteractionEnabled = NO;
        [replaySpriteTemp runAction:[ActionProvider getPressEndAction]];
        [replaySpriteTemp.parent runAction:[CCActionSequence actions:[ActionProvider getJumpOutToBottomFrom:replaySpriteTemp.parent.position andEndPosition:ccp(replaySpriteTemp.parent.position.x, -replaySpriteTemp.parent.contentSize.height/2) andDuration:1.f], [CCActionCallBlock actionWithBlock:^{
            [replaySpriteTemp.parent removeFromParent];
            [replaySpriteTemp.parent removeAllChildren];
            [weakSelf isReplayGame:YES andIsPerfect:starCountTemp == 3 ? YES : NO];
        }], nil]];
    };
    
//    TouchSprite* goSprite = [TouchSprite spriteWithImageNamed:@"complete_go_submarine.png"];
//    goSprite.position = [completeBoard convertToNodeSpace:ccp(1197/2.f, 768 - 1300/2.f)];
//    goSprite.name = @"go";
//    [completeBoard addChild:goSprite];
//    goSprite.userInteractionEnabled = YES;
//    __unsafe_unretained TouchSprite* goSpriteTemp = goSprite;
//    goSprite.touchBegan = ^(UITouch* touch){
//        [goSpriteTemp runAction:[ActionProvider getPressBeginAction]];
//    };
//    
//    goSprite.touchEnded = ^(UITouch* touch){
//        goSpriteTemp.userInteractionEnabled = NO;
//        [(TouchSprite* )goSpriteTemp.parent getChildByName:@"replay" recursively:NO].userInteractionEnabled = NO;
//        [goSpriteTemp runAction:[ActionProvider getPressEndAction]];
//        [goSpriteTemp.parent runAction:[CCActionSequence actions:[ActionProvider getJumpOutToBottomFrom:goSpriteTemp.parent.position andEndPosition:ccp(goSpriteTemp.parent.position.x, -goSpriteTemp.parent.contentSize.height/2) andDuration:1.f], [CCActionCallBlock actionWithBlock:^{
//            [goSpriteTemp.parent removeFromParent];
//            [goSpriteTemp.parent removeAllChildren];
//            [weakSelf isReplayGame:NO andIsPerfect:starCountTemp == 3 ? YES : NO];
//        }], nil]];
//    };
    
//    dudu
    CCSprite* duduSprite = [CCSprite spriteWithImageNamed:@"complete_dudu_submarine.png"];
    duduSprite.position = [completeBoard convertToNodeSpace:ccp(512, 768 - 815/2.f)];
    [completeBoard addChild:duduSprite];
    
//    actions
    completeBoard.position = ccp(completeBoard.position.x, -completeBoard.contentSize.height/2);
    [completeBoard runAction:[CCActionSequence actions:[ActionProvider getJumpInFromBottom:ccp(viewSize.width/2, viewSize.height/2) andDuration:1.f], [CCActionCallBlock actionWithBlock:^{
        for (int i = 0; i < starCountTemp; i++) {
            [weakSelf runStarAction:starArray[i] andIndex:i];
        }
        [starArray removeAllObjects];
        self.step = 2;
        [self handleButtons:YES];
        self.homeButton.enabled = YES;
        self.nextButton.name = [NSString stringWithFormat:@"%d", starCount];
    }], nil]];
}

-(void)goNextScene{
//    bg
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_observe.png"];
    bgSprite.anchorPoint = ccp(0, 0);
    bgSprite.position = ccp(0, 0);
    [_backgroundNode addChild:bgSprite z:1];
    
//    fish
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_observe.png"];
    fishSprite.name = @"carp";
    fishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [_backgroundNode addChild:fishSprite z:1];
    
//    gill
    CCSprite* gillSprite = [CCSprite spriteWithImageNamed:@"gill_observe.png"];
    gillSprite.position = ccp(491.5/2, 768 - 989.5/2);
    [_backgroundNode addChild:gillSprite z:1];
    
    CCSprite* press = (CCSprite* )[_backgroundNode getChildByName:@"press" recursively:NO];
    CCSprite* waterOne = (CCSprite* )[_backgroundNode getChildByName:@"water1" recursively:NO];
    [press removeAllChildren];
    [press removeFromParent];
    
    for (int i = 0; i < _backgroundNode.children.count; i++) {
        CCNode* sprite = _backgroundNode.children[i];
        MoveSprite* moveSprite = nil;
        if ([sprite isKindOfClass:[MoveSprite class]]) {
            moveSprite= (MoveSprite* )sprite;
            moveSprite.isMoveStart = YES;
            [moveSprite stopAllActions];
        }
        if (sprite.name.length == 6 && [[sprite.name substringToIndex:5] isEqualToString:@"light"]) {
            [sprite runAction:[CCActionFadeTo actionWithDuration:0.5f opacity:0.f]];
        }
        else if(sprite.name.length == 6 && [[sprite.name substringToIndex:5] isEqualToString:@"cloud"]){
            [sprite runAction:[CCActionMoveBy actionWithDuration:1.f position:ccp(0, 200)]];
        }
        else if(sprite.name.length == 6 && [[sprite.name substringToIndex:5] isEqualToString:@"water"]){
            [sprite runAction:[CCActionMoveBy actionWithDuration:2.f + [[sprite.name substringFromIndex:5] intValue] * 0.2f position:ccp(0, -waterOne.contentSize.height - press.contentSize.height)]];
        }
        else if(sprite.name.length == 5 && [[sprite.name substringToIndex:4] isEqualToString:@"hill"]){
            [sprite runAction:[CCActionMoveBy actionWithDuration:0.5f position:ccp(0, -sprite.contentSize.height)]];
        }
        else if([sprite.name isEqualToString:@"wave"]){
            [sprite runAction:[CCActionFadeTo actionWithDuration:0.5f opacity:0.f]];
        }
        else if([sprite.name isEqualToString:@"sky"]){
            [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:2.6f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
                [[CCDirector sharedDirector] replaceScene:[ObserveFinScene scene]];
            }], nil]];
        }
    }

}

-(void)isReplayGame:(BOOL)isReplay andIsPerfect:(BOOL)isPerfect{
    __block TouchSprite* submarineTemp = _submarineSprite;
    __block SubmarineScene* weakSelf = self;
    if (isPerfect) {
        [_submarineSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:3.f position:ccp(1024 + _submarineSprite.contentSize.width + 170, _submarineSprite.position.y)], [CCActionCallBlock actionWithBlock:^{
            [submarineTemp removeAllChildren];
            [submarineTemp removeFromParent];
            submarineTemp = nil;
            _currentLevel = 0;
            if (!isReplay) {
                [weakSelf goNextScene];
            }
            else{
                [weakSelf createSubmarine:YES];
            }
        }], nil]];
    }
    else{
        [_movedFish removeAllObjects];
        [_submarineSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:2.f position:ccp(_submarineSprite.position.x, -_submarineSprite.contentSize.height - 170)], [CCActionCallBlock actionWithBlock:^{
            [submarineTemp removeAllChildren];
            [submarineTemp removeFromParent];
            submarineTemp = nil;
            _currentLevel = 0;
            if (!isReplay) {
                [weakSelf goNextScene];
            }
            else{
                [weakSelf createSubmarine:YES];
            }
        }], nil]];
    }
}

-(void)runStarAction:(CCSprite* )star andIndex:(int)index{
    __block CCSpriteFrame* starFrame = [CCSpriteFrame frameWithImageNamed:star.name];
    __block CCSprite* starTemp = star;
    [star runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.2f + index * 1.f], [CCActionCallBlock actionWithBlock:^{
        starTemp.spriteFrame = starFrame;
        CCSprite* light = [CCSprite spriteWithImageNamed:@"complete_light_submarine.png"];
        light.position = starTemp.position;
        [starTemp.parent addChild:light z:1];
        light.scale = 0;
        __block CCSprite* lightTemp = light;
        [light runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.2f scale:0.4f], [CCActionSpawn actions:[CCActionScaleTo actionWithDuration:0.3f scale:1.f], [CCActionFadeTo actionWithDuration:0.3f opacity:0.f], nil], [CCActionCallBlock actionWithBlock:^{
            [lightTemp removeFromParent];
        }], nil]];
    }], nil]];
}

-(void)createPhysicsWorld{
    _physicsNode = [CCPhysicsNode node];
    _physicsNode.gravity = ccp(0, -100);
    _physicsNode.collisionDelegate = self;
//    _physicsNode.debugDraw = YES;
    [_backgroundNode addChild:_physicsNode z:PHYSICSORDER];
    
//      top
    CCNode* topNode = [CCNode node];
    topNode.anchorPoint = ccp(0, 0);
    topNode.contentSize = CGSizeMake(1024, 200);
    topNode.position = ccp(0, 630);
    topNode.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, topNode.contentSize} cornerRadius:0];
    topNode.physicsBody.type = CCPhysicsBodyTypeStatic;
    topNode.physicsBody.elasticity = 0.5f;
    topNode.physicsBody.friction = 0.f;
    topNode.physicsBody.collisionType = @"obstacle";
    [_physicsNode addChild:topNode z:1];

//      bottom
    CCNode* bottomNode = [CCNode node];
    bottomNode.anchorPoint = ccp(0, 1);
    bottomNode.contentSize = CGSizeMake(1024, 200);
    bottomNode.position = ccp(0, 0);
    bottomNode.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, bottomNode.contentSize} cornerRadius:0];
    bottomNode.physicsBody.type = CCPhysicsBodyTypeStatic;
    bottomNode.physicsBody.elasticity = 0.5f;
    bottomNode.physicsBody.friction = 0.f;
    bottomNode.physicsBody.collisionType = @"obstacle";
    [_physicsNode addChild:bottomNode z:1];
    
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    if (self.showWords) {
        self.showWords = NO;
        CCNode* wordsNode = [self getChildByName:@"wordsNode" recursively:NO];
        if (!wordsNode) {
            return;
        }
//        [wordsNode runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:0.f], [CCActionCallBlock actionWithBlock:^{
//            [wordsNode removeAllChildren];
//            [wordsNode removeFromParent];
//            self.homeButton.visible = YES;
//            self.nextButton.visible = YES;
//            self.prevButton.visible = YES;
//            [self createScene];
//        }], nil]];
        for (int i = 0; i < wordsNode.children.count; i++) {
            CCNode* tip = wordsNode.children[i];
            [tip runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
                if (i == 1) {
                    self.homeButton.visible = YES;
                    self.nextButton.visible = YES;
                    self.prevButton.visible = YES;
                    [self createScene];
                }
                [tip removeFromParent];
            }], nil]];
        }
    }
    if (_gameStart) {
        if (_showTip) {
            if (_showingTipOne) {
                _physicsNode.gravity = ccp(0.f, -100.f);
                _showingTipOne = NO;
                _tipStep = 2;
                [self hideTip];
            }
            if (_showingTipTwo) {
                _showingTipTwo = NO;
                _touchEnabled = YES;
                _submarineSprite.physicsBody.velocity = ccp(0, 500);
                _fishEnabled = YES;
                [self hideTip];
            }
            if (_showingTipThree) {
                _showingTipThree = NO;
                _showTip = NO;
                _fishEnabled = YES;
                [self hideTip];
            }
            if (_touchEnabled){
                _submarineSprite.physicsBody.velocity = ccp(0, 100);
            }
        }
        else{
            _submarineSprite.physicsBody.velocity = ccp(0, 100);
        }
    }
//    else{
//        _gameStart = YES;
//        for (MoveSprite* sprite in _movedSprites) {
//            sprite.isMoveStart = YES;
//        }
//    }
}

-(void)hideTip{
    CCSprite* press = (CCSprite* )[_backgroundNode getChildByName:@"press" recursively:NO];
    [press runAction:[CCActionSequence actions:[CCActionJumpTo actionWithDuration:1.f position:press.position height:30.f jumps:3], nil]];
    
//    [_tipNode runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scaleX:1.f scaleY:0.f], [CCActionCallBlock actionWithBlock:^{
//        [_tipNode removeAllChildren];
//        [_tipNode removeFromParent];
//        _tipNode = nil;
//    }], nil]];
    
    for (int i = 0; i < _tipNode.children.count; i++) {
        CCNode* tip = _tipNode.children[i];
        [tip runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
            if (i == 1) {
                [_tipNode removeAllChildren];
                [_tipNode removeFromParent];
                _tipNode = nil;
            }
        }], nil]];
    }
}






-(void)onExit{
    _submarineSprite = nil;
    _pressWater = nil;
    _bigPointer = nil;
    _smallPointer = nil;
    [_movedFish removeAllObjects];
    [_movedSprites removeAllObjects];
//    [[SubmarineLevelManager sharedSubmarineManager] purgeSubmarineLevelManager];
    [_submarineSprite removeAllChildren];
    [_physicsNode removeAllChildren];
    [_backgroundNode removeAllChildren];
    [self removeAllChildren];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{

}
@end
