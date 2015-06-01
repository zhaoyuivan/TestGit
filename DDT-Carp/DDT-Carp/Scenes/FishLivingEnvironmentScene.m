//
//  FishLivingEnvironmentScene.m
//  DDT-Carp
//
//  Created by Z on 14/12/26.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "FishLivingEnvironmentScene.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "TouchSprite.h"
#import "FishNode.h"
#import "FishMoveSprite.h"
#import "CCTextureCache.h"
#import "CCAnimation+Helper.h"
#import "ActionProvider.h"
#import "RiverFishScene.h"

#import "ContentScene.h"

#define FISHORDER 100

#define RIVERFISHNUM 15
#define MIGRATIONFISHNUM 8

@interface FishLivingEnvironmentScene ()
{
    CCNode* _backgroundNode;
    int _fishCount;
    BOOL _isGoingNextScene;
    NSString* _goTo;
}
@end

@implementation FishLivingEnvironmentScene
+(FishLivingEnvironmentScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _backgroundNode = [CCNode node];
        _backgroundNode.anchorPoint = ccp(0.f, 0.f);
        _backgroundNode.position = ccp(0.f, 0.f);
        _backgroundNode.contentSize = self.contentSize;
        [self addChild:_backgroundNode z:1];
        _fishCount = 0;
        _isGoingNextScene = NO;
        _goTo = @"noWhere";
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    if (![_goTo isEqualToString:@"noWhere"]) {
        [self resumeScene];
        return;
    }
    [self createBackground];
}

-(void)createBackground{
//    bg
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_life.png"];
    CGPoint center = ccp([[CCDirector sharedDirector] viewSize].width/2.f, [[CCDirector sharedDirector] viewSize].height/2.f);
    bgSprite.position = center;
    [_backgroundNode addChild:bgSprite z:1];
    
    __unsafe_unretained FishLivingEnvironmentScene* weakSelf = self;
    [bgSprite runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.8f + 5.f scale:1.2f], [CCActionCallBlock actionWithBlock:^{
        [weakSelf createFishSchools];
    }], nil]];
    
//    river fish
    for (int i = 0; i < RIVERFISHNUM; i++) {
        FishMoveSprite* riverFish = [[FishMoveSprite alloc] initWithImageNamed:@"river_fish_life.png" withScale:0.2f + arc4random()%60 * 0.01f andDelayTime:i < 5 ? 0.f * i : (arc4random()%20 + 2)];
        riverFish.visible = NO;
        [_backgroundNode addChild:riverFish z:FISHORDER];
    }
    
//    clouds
//    small -> big
    CCTime delayTime[] = {0.f, 0.f, 0.f, 0.f};
    CCTime scaleTime[] = {5.f, 3.5f, 3.5f, 3.f};
    CGFloat endScale[] = {10.f, 4.f, 5.f, 10.f};
    for (int i = 0; i < 4; i++) {
        CCSprite* cloudSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"cloud%d_life.png", i + 1]];
        cloudSprite.name = [NSString stringWithFormat:@"cloud%d", i + 1];
                cloudSprite.position = center;
        [_backgroundNode addChild:cloudSprite z:i + 101];
        
        [cloudSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.8f + delayTime[i]], [CCActionSpawn actions:[CCActionScaleTo actionWithDuration:scaleTime[i] scale:endScale[i]], [CCActionFadeOut actionWithDuration:scaleTime[i]], nil], [CCActionCallBlock actionWithBlock:^{
            [cloudSprite removeFromParent];
        }], nil]];
    }
    
    CCNodeColor* whiteNode = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
    whiteNode.position = ccp(0.f, 0.f);
    whiteNode.contentSize = self.contentSize;
    [_backgroundNode addChild:whiteNode z:1000];
    [whiteNode runAction:[CCActionFadeOut actionWithDuration:1.f]];
}

-(void)createFishSchools{
//    home
    TouchSprite* homeSprite = [TouchSprite spriteWithImageNamed:@"home.png"];
    homeSprite.position = ccp(115/2, 768 - 120/2);
    homeSprite.opacity = 0.f;
    [_backgroundNode addChild:homeSprite z:1000];
    homeSprite.userInteractionEnabled = YES;
    __unsafe_unretained TouchSprite* homeSpriteTemp = homeSprite;
    homeSprite.touchBegan = ^(UITouch* touch){
        homeSpriteTemp.userInteractionEnabled = NO;
        [homeSpriteTemp runAction:[ActionProvider getPressBeginAction]];
        [[CCDirector sharedDirector] replaceScene:[ContentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    };
    [homeSprite runAction:[CCActionFadeIn actionWithDuration:1.f]];
    
//    ship
    CCSprite* shipSprite = [CCSprite spriteWithImageNamed:@"ship1_life.png"];
    shipSprite.position = ccp(1024 + shipSprite.contentSize.width, 700);
    [_backgroundNode addChild:shipSprite z:FISHORDER];
    
    CCAnimation* shipAnimation = [CCAnimation animationWithFile:@"ship" withSuffix:@"_life" frameCount:8 delay:1/5.f];
    [shipSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:shipAnimation]]];
    
    [shipSprite runAction:[CCActionMoveTo actionWithDuration:5.f position:ccp(1050, 600)]];
    
//    sea fishes
    NSDictionary* seaFishesDict =
    @{
        @"image"            :       @"sea_fish_life.png",
        @"count"            :       @"12",
        @"position"         :       @"1300,384",
        @"fishScales"       :       @[@"0.7", @"0.5", @"0.6", @"0.7", @"1.0", @"0.7", @"0.5", @"0.7", @"1.0", @"0.5", @"0.5", @"1.0"],
        @"fishPositions"    :       @[@"-6.5,-123", @"-96,-162.5", @"9,-183.5", @"142,-195", @"-97.5,-237", @"62.5,-232.5", @"-216.5,-299", @"-113.5,-319", @"0,-285.5", @"144,-273.5", @"-48.5,-357.5", @"105,-347.5"]
    };
    FishNode* seaFishes = [[FishNode alloc] initWithFishInfo:seaFishesDict isUsePhysics:NO];
    seaFishes.opacity = 0.8f;
    [_backgroundNode addChild: seaFishes z:FISHORDER];
    __unsafe_unretained FishLivingEnvironmentScene* weakSelf = self;
    [seaFishes runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:3.f position:ccp(810, 384)], [CCActionCallBlock actionWithBlock:^{
        [weakSelf createPromptCircle:@"seaFish"];
    }], nil]];
    
//    rive fishes
//    for (int i = 0; i < RIVERFISHNUM; i++) {
//        FishMoveSprite* riverFish = [[FishMoveSprite alloc] initWithImageNamed:@"river_fish_life.png" withScale:0.2f + arc4random()%60 * 0.01f andDelayTime:i < 5 ? 0.f * i : (arc4random()%20 + 2)];
//        [_backgroundNode addChild:riverFish z:FISHORDER];
//    }
    for (CCNode* riverFish in _backgroundNode.children) {
        if([riverFish isKindOfClass:[FishMoveSprite class]]){
            riverFish.visible = YES;
        }
    }
    [self createPromptCircle:@"riverFish"];
    
//    migration fishes
    CGFloat startRotations[] = {50.f, -130.f};
    CGPoint startPositions[] = {ccp(480, 131), ccp(368, 302)};
    CGPoint endPositions[] = {ccp(368, 302), ccp(480, 131)};
    for(int i = 0; i < MIGRATIONFISHNUM; i++){
        CCSprite* fish = [CCSprite spriteWithImageNamed:@"migration_fish_life.png"];
        int index = arc4random()%2;
        fish.rotation = startRotations[index];
        int random = arc4random()%30 * (arc4random()%2 ?1 : -1);
        fish.opacity = 0.f;
        fish.scale = 0.5 + arc4random()%6 * 0.1f;
        fish.position = ccpAdd(startPositions[index], ccp(random, random));
        [_backgroundNode addChild:fish z:FISHORDER];
//        [CCActionFadeTo actionWithDuration:0 opacity:0.f], [CCActionDelay actionWithDuration:0.f], [CCActionFadeTo actionWithDuration:0 opacity:1.f], [CCActionDelay actionWithDuration:0.f], 
        CCTime duration = 3 + arc4random()%3;
        [fish runAction:[CCActionRepeatForever actionWithAction:
                         [CCActionSequence actions:
                          [CCActionDelay actionWithDuration:arc4random()%4],
                          [CCActionSpawn actions:
                           [CCActionMoveTo actionWithDuration:duration position:ccpAdd(endPositions[index], ccp(random, random))],
                           [CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionDelay actionWithDuration:duration - 2.f], [CCActionFadeTo actionWithDuration:1.f opacity:0.f], nil], nil],
                          [CCActionRotateTo actionWithDuration:0.f angle:startRotations[!index]],
                          [CCActionDelay actionWithDuration:arc4random()%4],
                          [CCActionSpawn actions:
                           [CCActionMoveTo actionWithDuration:duration position:ccpAdd(endPositions[!index], ccp(random, random))],
                           [CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionDelay actionWithDuration:duration - 2.f], [CCActionFadeTo actionWithDuration:1.f opacity:0.f], nil],
                           nil],
                          [CCActionRotateTo actionWithDuration:0.f angle:startRotations[index]],
                          nil]]];
    }
    [self createPromptCircle:@"migrationFish"];
    
}

-(void)createPromptCircle:(NSString* )fishType{
    int index = [fishType isEqualToString:@"seaFish"] ? 0 : ([fishType isEqualToString:@"riverFish"] ? 1 : 2);
    
    CGPoint positions[] = {ccp(810, 134), ccp(117, 421), ccp(416, 234)};
    
    TouchSprite* smallCircle = [TouchSprite spriteWithImageNamed:@"tip1_life.png"];
    smallCircle.position = positions[index];
    smallCircle.opacity = 0.f;
    smallCircle.userInteractionEnabled = NO;
    [_backgroundNode addChild:smallCircle z:FISHORDER + 1];
    
    CCSprite* bigCircle = [CCSprite spriteWithImageNamed:@"tip2_life.png"];
    bigCircle.position = smallCircle.position;
    bigCircle.opacity = 0.f;
    [_backgroundNode addChild:bigCircle z:FISHORDER + 1];
    
    __unsafe_unretained CCSprite* bigCircleTemp = bigCircle;
    __unsafe_unretained TouchSprite* smallCircleTemp = smallCircle;
    [smallCircle runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:index == 1 ? 4.f : (index == 2 ? 3.f : 0.5f)], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
        smallCircleTemp.userInteractionEnabled = YES;
        bigCircleTemp.opacity = 1.f;
        [bigCircleTemp runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionFadeOut actionWithDuration:1.5f], [CCActionScaleTo actionWithDuration:1.5f scale:1.5f], nil], [CCActionDelay actionWithDuration:0.2f], [CCActionCallBlock actionWithBlock:^{
            bigCircleTemp.opacity = 1.f;
            bigCircleTemp.scale = 1.f;
        }], nil]]];
    }], nil]];
    
    smallCircle.touchBegan = ^(UITouch* touch){
        [smallCircleTemp runAction:[ActionProvider getPressBeginAction]];
    };
    
    smallCircle.touchCanceled = ^(UITouch* touch){
        [smallCircleTemp runAction:[ActionProvider getPressEndAction]];
    };
    
    __unsafe_unretained FishLivingEnvironmentScene* weakSelf = self;
    smallCircle.touchEnded = ^(UITouch* touch){
        smallCircleTemp.userInteractionEnabled = NO;
        [smallCircleTemp runAction:[CCActionFadeOut actionWithDuration:1.f]];
        [bigCircleTemp stopAllActions];
        [bigCircleTemp runAction:[CCActionFadeOut actionWithDuration:1.f]];
        [weakSelf createSpeciesCircle:fishType];
    };
    
}

-(void)createSpeciesCircle:(NSString* )fishType{
    _fishCount++;
    
    int index = [fishType isEqualToString:@"seaFish"] ? 0 : ([fishType isEqualToString:@"riverFish"] ? 1 : 2);
    CGPoint startPositions[] = {ccp(810, 134), ccp(117, 421), ccp(416, 234)};
    CGPoint endPositions[] = {ccp(815, 305), ccp(340, 593), ccp(217, 154)};
    CGPoint grayCirclePositions[] = {ccp(815, 343), ccp(340, 632), ccp(215, 194)};
    CGPoint fishPositions[] = {ccp(815, 343), ccp(336, 633), ccp(215, 193)};
    NSArray* fishName = @[@"sea_fish_icon_life.png", @"river_fish_icon_life.png", @"migration_fish_icon_life.png"];
    CGPoint wordPositions[] = {ccp(815, 258), ccp(340, 553), ccp(218, 116)};
    NSArray* wordName = @[@"sea_word", @"river_word", @"migration_word"];
    
//    circle board
    CCSprite* circleBoard = [CCSprite spriteWithImageNamed:@"board_life.png"];
    circleBoard.position = endPositions[index];
    circleBoard.name = fishType;
    [_backgroundNode addChild:circleBoard z:FISHORDER + 2];
    
//    gary circle
    CCSprite* grayCircle = [CCSprite spriteWithImageNamed:@"circle_life.png"];
    grayCircle.position = [circleBoard convertToNodeSpace:grayCirclePositions[index]];
    grayCircle.name = @"grayCircle";
    [circleBoard addChild:grayCircle];
    
//    fish
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:fishName[index]];
    fishSprite.position = [circleBoard convertToNodeSpace:fishPositions[index]];
    fishSprite.name = @"fish";
    [circleBoard addChild:fishSprite];
    
//    words
    CCSprite* wordsSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@1_life.png", wordName[index]]];
    wordsSprite.position = [circleBoard convertToNodeSpace:wordPositions[index]];
    wordsSprite.opacity = 0.f;
    wordsSprite.name = @"word";
    [circleBoard addChild:wordsSprite];
    
//    go
    TouchSprite* goSprite = [TouchSprite spriteWithImageNamed:@"go_life.png"];
    goSprite.position = [circleBoard convertToNodeSpace:grayCirclePositions[index]];
    goSprite.visible = NO;
    goSprite.name = @"go";
    goSprite.userInteractionEnabled = NO;
    [circleBoard addChild:goSprite];
    
    __unsafe_unretained TouchSprite* goSpriteTemp = goSprite;
    __unsafe_unretained FishLivingEnvironmentScene* weaKSelf = self;
    goSprite.touchBegan = ^(UITouch* touch){
        [goSpriteTemp stopAllActions];
        [goSpriteTemp runAction:[ActionProvider getPressBeginAction]];
    };
    
    goSprite.touchEnded = ^(UITouch* touch){
//        goSpriteTemp.userInteractionEnabled = NO;
        [weaKSelf goNextScene:fishType];
    };
    
    goSprite.touchCanceled = ^(UITouch* touch){
        [goSpriteTemp runAction:[ActionProvider getPressEndAction]];
    };
    
//    actions
    CCAnimation* wordAnimation = [CCAnimation animationWithFile:wordName[index] withSuffix:@"_life" frameCount:3 delay:1/6.f];
    
    circleBoard.position = startPositions[index];
    circleBoard.opacity = 0.f;
    [circleBoard runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:1.f position:endPositions[index]], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil], [CCActionCallBlock actionWithBlock:^{
        [wordsSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:wordAnimation]]];
        if (_fishCount == 3) {
            _fishCount = 0;
            [weaKSelf showGoSprites];
        }
    }], nil]];
    
    for (CCSprite* sprite in circleBoard.children) {
        sprite.opacity = 0.f;
        [sprite runAction:[CCActionFadeTo actionWithDuration:1.f opacity:1.f]];
    }
}

-(void)showGoSprites{
    CCSprite* seaFishBoard = (CCSprite* )[_backgroundNode getChildByName:@"seaFish" recursively:NO];
    CCSprite* riverFishBoard = (CCSprite* )[_backgroundNode getChildByName:@"riverFish" recursively:NO];
    CCSprite* migrationFishBoard = (CCSprite* )[_backgroundNode getChildByName:@"migrationFish" recursively:NO];
    NSArray* fishes = @[seaFishBoard, riverFishBoard, migrationFishBoard];
    for (int i = 0; i < fishes.count; i++) {
        CCSprite* fishBoard = fishes[i];
        CCSprite* fishSprite = (CCSprite* )[fishBoard getChildByName:@"fish" recursively:NO];
        TouchSprite* goSprite = (TouchSprite* )[fishBoard getChildByName:@"go" recursively:NO];
        goSprite.opacity = 0.f;
        goSprite.visible = YES;
        [fishSprite runAction:[CCActionFadeTo actionWithDuration:1.f opacity:0.3f]];
        __unsafe_unretained TouchSprite* goSpriteTemp = goSprite;
        [goSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
            goSpriteTemp.userInteractionEnabled = YES;
            [goSpriteTemp runAction:[ActionProvider getRepeatScalePrompt]];
        }], nil]];
    }
}

-(void)goNextScene:(NSString* )fishType{
    if (_isGoingNextScene) {
        return;
    }
    _goTo = fishType;
    _isGoingNextScene = YES;
    NSLog(@"%@", fishType);
    CCSprite* seaFishBoard = (CCSprite* )[_backgroundNode getChildByName:@"seaFish" recursively:NO];
    CCSprite* riverFishBoard = (CCSprite* )[_backgroundNode getChildByName:@"riverFish" recursively:NO];
    CCSprite* migrationFishBoard = (CCSprite* )[_backgroundNode getChildByName:@"migrationFish" recursively:NO];
    
    NSArray* fishes = @[seaFishBoard, riverFishBoard, migrationFishBoard];
    for (int i = 0; i < fishes.count; i++) {
        CCSprite* fishBoard = fishes[i];
        [fishBoard runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], nil]];
        TouchSprite* goSprite = (TouchSprite* )[fishBoard getChildByName:@"go" recursively:NO];
        goSprite.userInteractionEnabled = NO;
        for (int j = 0; j < fishBoard.children.count; j++) {
            CCSprite* sprite = (CCSprite* )fishBoard.children[j];
            [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
//                [sprite removeFromParent];
            }], nil]];
        }
    }

    NSString* classStr = [NSString stringWithFormat:@"%@FishScene", [fishType substringToIndex:fishType.length - 4].capitalizedString];
    Class NextScene = NSClassFromString(classStr);
    id nextScene = [NextScene scene];
    
    CCSprite* fishBoard = (CCSprite* )[_backgroundNode getChildByName:fishType recursively:NO];
    CCSprite* grayCircle = (CCSprite* )[fishBoard getChildByName:@"grayCircle" recursively:NO];
    [grayCircle stopAllActions];
    [grayCircle runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:2.f scale:30.f], [CCActionCallBlock actionWithBlock:^{
        CCRenderTexture* renderTexture = [CCRenderTexture renderTextureWithWidth:self.contentSize.width height:self.contentSize.height];
        [renderTexture begin];
        [self visit];
        [renderTexture end];
        renderTexture.anchorPoint = ccp(0.f, 0.f);
        renderTexture.position = ccp(512, 384);
        [nextScene addChild:renderTexture z:0];
        [[CCDirector sharedDirector] pushScene:nextScene];
    }], nil]];
}

-(void)resumeScene{
    CCSprite* seaFishBoard = (CCSprite* )[_backgroundNode getChildByName:@"seaFish" recursively:NO];
    CCSprite* riverFishBoard = (CCSprite* )[_backgroundNode getChildByName:@"riverFish" recursively:NO];
    CCSprite* migrationFishBoard = (CCSprite* )[_backgroundNode getChildByName:@"migrationFish" recursively:NO];
    
    NSArray* fishes = @[seaFishBoard, riverFishBoard, migrationFishBoard];
    for (int i = 0; i < fishes.count; i++) {
        CCSprite* fishBoard = fishes[i];
        fishBoard.opacity = 1.f;
        TouchSprite* goSprite = (TouchSprite* )[fishBoard getChildByName:@"go" recursively:NO];
        [goSprite stopAllActions];
        [goSprite runAction:[ActionProvider getRepeatScalePrompt]];
        goSprite.userInteractionEnabled = YES;
        for (int j = 0; j < fishBoard.children.count; j++) {
            CCSprite* sprite = (CCSprite* )fishBoard.children[j];
            sprite.opacity = 1.f;
            sprite.scale = 1.f;
        }
    }
    _goTo = @"noWhere";
    _isGoingNextScene = NO;
}

-(void)onExit{
    if (![_goTo isEqualToString:@"noWhere"]) {
        return;
    }
    _fishCount = 0;
    [_backgroundNode removeAllChildren];
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{
    
}
@end
