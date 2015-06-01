//
//  RiverFishScene.m
//  DDT-Carp
//
//  Created by Z on 14/12/30.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "RiverFishScene.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "TouchSprite.h"
#import "ActionProvider.h"
#import "CCTextureCache.h"
#import "TouchFishSprite.h"
#import "FishSwimSprite.h"
#import "SwimOceanNode.h"

//#import "ContentScene.h"

#define SKYORDER 100
#define WATERORDER 200
#define FISHORDER 300
#define MUDORDER 400
#define SANDORDER 500
#define PLANTORDER 600
#define STONEORDER 700
#define BOARDORDER 800
#define BUTTONORDER 900

#define WATERHEIGHT 550

@interface RiverFishScene ()
{
    CCNode* _backgroundNode;
    NSMutableArray* _crashSpriteArray;
    NSMutableArray* _crashFishArray;
    NSMutableArray* _touchFishes;
    NSMutableArray* _fishMaxNumArray;
}
@end

@implementation RiverFishScene
+(RiverFishScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _backgroundNode = [CCNode node];
        _backgroundNode.contentSize = self.contentSize;
        _backgroundNode.anchorPoint = ccp(0, 0);
        _backgroundNode.position = ccp(0, 0);
        [self addChild:_backgroundNode z:1];
        
//    home
        TouchSprite* homeSprite = [TouchSprite spriteWithImageNamed:@"menu.png"];
        homeSprite.position = ccp(115/2, 768 - 120/2);
        [_backgroundNode addChild:homeSprite z:10000];
        homeSprite.userInteractionEnabled = YES;
        __unsafe_unretained TouchSprite* homeSpriteTemp = homeSprite;
        homeSprite.touchBegan = ^(UITouch* touch){
            homeSpriteTemp.userInteractionEnabled = NO;
            [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
//             replaceScene:[ContentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
        };
        
        _crashSpriteArray = [[NSMutableArray alloc] init];
        _crashFishArray = [[NSMutableArray alloc] init];
        _touchFishes = [[NSMutableArray alloc] init];
        _fishMaxNumArray = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"2", @"3", nil];
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createBackground];
}

-(void)createBackground{
//    water
//    SwimOceanNode* waterSprite = [[SwimOceanNode alloc] initWithImageNamed:@"water_river.png" andTexture:[CCTexture textureWithFile:@"water_river.png"]];
    CCSprite* waterSprite = [CCSprite spriteWithImageNamed:@"water_river.png"];
    waterSprite.position = ccp(512, -waterSprite.contentSize.height/2);
    [_backgroundNode addChild:waterSprite z:WATERORDER];
    [waterSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.5f position:ccp(512, 768 - 730/2.f)], [CCActionCallBlock actionWithBlock:^{
//        waterSprite.isStartShake = YES;
    }], nil]];
    
//    sky
    CCSprite* skySprite = [CCSprite spriteWithImageNamed:@"sky_river.png"];
    skySprite.anchorPoint = ccp(0, 0);
    skySprite.position = ccp(0, 0);
    skySprite.opacity = 0.f;
    [_backgroundNode addChild:skySprite z:SKYORDER];
    [skySprite runAction:[CCActionFadeTo actionWithDuration:1.5f opacity:1.f]];
    
//    sand
    CCSprite* sandSprite = [CCSprite spriteWithImageNamed:@"sand_river.png"];
    sandSprite.anchorPoint = ccp(0, 0);
    sandSprite.position = ccp(0, 0);
    sandSprite.opacity = 0.f;
    [_backgroundNode addChild:sandSprite z:SANDORDER];
    [sandSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.5f], [CCActionFadeTo actionWithDuration:1.5f opacity:1.f], nil]];
    
//    stone
    CCSprite* stoneSprite = [CCSprite spriteWithImageNamed:@"stone_river.png"];
    stoneSprite.position = ccp(502, 148);
    stoneSprite.opacity = 0.f;
    [_backgroundNode addChild:stoneSprite z:STONEORDER];
    [stoneSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.5f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
    
//    plants
    CCSprite* leftPlant = [CCSprite spriteWithImageNamed:@"plant_river.png"];
    leftPlant.position = ccp(60, 575);
    leftPlant.opacity = 0.f;
    [_backgroundNode addChild:leftPlant z:PLANTORDER];
    [leftPlant runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.5f], [CCActionFadeTo actionWithDuration:1.5f opacity:1.f], nil]];
    
    CGPoint plantPosition[] = {ccp(357/2.f, 768 - 956/2.f), ccp(1582/2.f, 768 - 1109/2.f), ccp(1635/2.f, 768 - 1158/2.f), ccp(1794/2.f, 768 - 865/2.f), ccp(1728/2.f, 768 - 959/2.f), ccp(436/2.f, 768 - 1083/2.f), ccp(561/2.f, 768 - 1206/2.f)};
    for (int i = 0; i < 7; i++) {
        CCSprite* plant = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"plant%d_river.png", i + 1]];
        plant.anchorPoint = ccp(0.5f, 0.f);
        plant.position = ccp(plantPosition[i].x, plantPosition[i].y - plant.contentSize.height/2.f);
        plant.opacity = 0.f;
        int zOrder = PLANTORDER;
        if (i == 3) {
            zOrder = SANDORDER - 1;
        }
        else if(i == 4 || i == 6){
            zOrder = FISHORDER - 1;
        }
        [_backgroundNode addChild:plant z:zOrder];
        [_crashSpriteArray addObject:plant];
        [plant runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.5f], [CCActionFadeTo actionWithDuration:1.5f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
            [plant runAction:[self plantShakeAction]];
        }], nil]];
    }
    
//    fish school
    FishSwimSprite* fishSchool = [[FishSwimSprite alloc] initWithImageNamed:@"fish_school_river.png" andSwimRect:(CGRect){0, 80, 1024, WATERHEIGHT - 150} andFaceTo:right];
    fishSchool.isLockBezierMoveCount = YES;
    fishSchool.bezierMoveCount = 0;
    fishSchool.position = ccp(512, WATERHEIGHT/2.f);
    fishSchool.opacity = 0.f;
    fishSchool.userInteractionEnabled = NO;
    [_backgroundNode addChild:fishSchool z:FISHORDER];
    [fishSchool runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.5f], [CCActionFadeTo actionWithDuration:1.5f opacity:1.f], [CCActionCallBlock actionWithBlock:^{

    }], nil]];
    
//    fish board
    CCSprite* fishBoard = [CCSprite spriteWithImageNamed:@"board_river.png"];
    fishBoard.anchorPoint = ccp(1.f, 0.5f);
    fishBoard.position = ccp(1024, 768 - 137/2.f);
    [_backgroundNode addChild:fishBoard z:BOARDORDER];
    
    CGPoint fishPositions[] = {ccp(510/2.f, 768 - 159/2.f), ccp(857/2.f, 768 - 157/2.f), ccp(1127/2.f, 768 - 146/2.f), ccp(1381/2.f, 768 - 153/2.f), ccp(1641/2.f, 768 - 156/2.f)};
    
    __unsafe_unretained RiverFishScene* weakSelf = self;
    for (int i = 0; i < 5; i++) {
        TouchFishSprite* fishSprite = [TouchFishSprite spriteWithImageNamed:[NSString stringWithFormat:@"fish%d_river.png", i + 1]];
        fishSprite.position = [fishBoard convertToNodeSpace:fishPositions[i]];
        fishSprite.name = [NSString stringWithFormat:@"fish%d", i + 1];
        fishSprite.userInteractionEnabled = NO;
        fishSprite.isTouching = NO;
        [fishBoard addChild:fishSprite];
        [_touchFishes addObject:fishSprite];
        __block CGPoint originalPosition = fishPositions[i];
        __unsafe_unretained TouchFishSprite* fishSpriteTemp = fishSprite;
        fishSprite.touchBegan = ^(UITouch* touch){
            [weakSelf fishSpriteTouchBeganBlock:touch onFish:fishSpriteTemp];
        };
        
        fishSprite.touchMoved = ^(UITouch* touch){
            [weakSelf fishSpriteTouchMovedBlock:touch onFish:fishSpriteTemp];
        };
        
        fishSprite.touchEnded = ^(UITouch* touch){
            [weakSelf fishSpriteTouchEndedBlock:touch onFish:fishSpriteTemp withOriginalPosition:originalPosition];
        };
        
        fishSprite.touchCanceled = ^(UITouch* touch){
            [weakSelf fishSpriteTouchCanceledBlock:touch onFish:fishSpriteTemp withOriginalPosition:originalPosition];
        };
    }
    
    fishBoard.position = ccp(fishBoard.contentSize.width + 1024, 768 - 137/2.f);
    
//    fish button
    TouchSprite* fishButton = [TouchSprite spriteWithImageNamed:@"button_river.png"];
    fishButton.position = ccp(1896.5/2.f, 768 - 137/2.f);
    fishButton.opacity = 0.f;
    fishButton.userInteractionEnabled = NO;
    [_backgroundNode addChild:fishButton z:BUTTONORDER];
    
    [fishButton runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.5f], [CCActionFadeTo actionWithDuration:1.5f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
        fishButton.userInteractionEnabled = YES;
        [fishButton runAction:[ActionProvider getRepeatScalePrompt]];
    }], nil]];
    
    __unsafe_unretained TouchSprite* fishButtonTemp = fishButton;
    __unsafe_unretained CCSprite* fishBoardTemp = fishBoard;
    fishButton.touchBegan = ^(UITouch* touch){
        if([weakSelf fishIsTouching]){
            return;
        }
        fishButtonTemp.userInteractionEnabled = NO;
        [fishButtonTemp stopAllActions];
        [fishButtonTemp runAction:[ActionProvider getPressBeginAction]];
        [weakSelf adjustFishPositionOnFishBoard:fishBoardTemp isAfterMove:NO];
        [fishBoardTemp runAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:0.5f position:ccp(fishBoardTemp.contentSize.width * (fishBoardTemp.position.x > 1024 ? -1 : 1), 0)], [CCActionCallBlock actionWithBlock:^{
            fishButtonTemp.userInteractionEnabled = YES;
            [weakSelf adjustFishPositionOnFishBoard:fishBoardTemp isAfterMove:YES];
        }], nil]];
    };
    
    fishButton.touchEnded = ^(UITouch* touch){
        [fishButtonTemp runAction:[ActionProvider getPressEndAction]];
    };
}

-(CCActionRepeatForever* )plantShakeAction{
    CCTime duration = arc4random()%4 + 5;
    float angle = arc4random()%5 + 5;
    angle = (arc4random()%2 ? -1 : 1) * angle;
    return [CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.2f], [CCActionRotateBy actionWithDuration:duration angle:angle], [CCActionDelay actionWithDuration:0.2f], [CCActionRotateBy actionWithDuration:duration angle:-angle], nil]];
}

-(void)adjustFishPositionOnFishBoard:(CCSprite* )fishBoard isAfterMove:(BOOL)isAfterMove{
    BOOL isShown = fishBoard.position.x > 1024 ? NO : YES;
    if (!isAfterMove){
        if (isShown) {
            for (TouchFishSprite* touchFish in _touchFishes) {
                [touchFish removeFromParent];
                touchFish.position = [fishBoard convertToNodeSpace:touchFish.position];
                [fishBoard addChild:touchFish];
            }
            [self setFishSpritesTouchEnabled:NO];
        }
        else{
            return;
        }
    }
    else{
        if (isShown) {
            for (TouchFishSprite* touchFish in _touchFishes) {
                [touchFish removeFromParent];
                touchFish.position = [fishBoard convertToWorldSpace:touchFish.position];
                [_backgroundNode addChild:touchFish z:1000];
            }
            [self setFishSpritesTouchEnabled:YES];
        }
        else{
            return;
        }
    }
}

-(void)setFishSpritesTouchEnabled:(BOOL)isEnabled{
    for (TouchFishSprite* fishSprite in _touchFishes) {
        fishSprite.userInteractionEnabled = isEnabled;
    }
}

-(void)fishSpriteTouchBeganBlock:(UITouch* )touch onFish:(TouchFishSprite* )fishSprite{
    fishSprite.position = [touch locationInNode:_backgroundNode];
    fishSprite.isTouching = YES;
    fishSprite.userInteractionEnabled = NO;
}

-(void)fishSpriteTouchMovedBlock:(UITouch* )touch onFish:(TouchFishSprite* )fishSprite{
    fishSprite.position = [touch locationInNode:_backgroundNode];
}

-(void)fishSpriteTouchEndedBlock:(UITouch* )touch onFish:(TouchFishSprite* )fishSprite withOriginalPosition:(CGPoint)originalPosition{
    CGRect rect = (CGRect){0, 0, 1024, WATERHEIGHT};
    if (CGRectContainsPoint(rect, fishSprite.position)) {
//        add fish
        FishSwimSprite* fish = [[FishSwimSprite alloc] initWithImageNamed:[NSString stringWithFormat:@"%@_river.png", fishSprite.name] andSwimRect:(CGRect){0, 50, 1024, WATERHEIGHT - 100}];
        if ([fishSprite.name isEqualToString:@"fish1"]) {
            fish.species = blackCarp;
            [_crashFishArray addObject:fish];
        }
        else if([fishSprite.name isEqualToString:@"fish2"]){
            fish.species = catfish;
            [_crashFishArray addObject:fish];
        }
        fish.position = fishSprite.position;
        fish.userInteractionEnabled = YES;
        [_backgroundNode addChild:fish z:FISHORDER];
        
        int index = [[fishSprite.name substringFromIndex:4] intValue] - 1;
        int fishMax = [_fishMaxNumArray[index] intValue] - 1;
        [_fishMaxNumArray replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%d", fishMax]];
        if (fishMax) {
            fishSprite.opacity = 0;
            fishSprite.position = originalPosition;
            [fishSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:0.5 opacity:1.f], [CCActionCallBlock actionWithBlock:^{
                fishSprite.userInteractionEnabled = YES;
                fishSprite.isTouching = NO;
            }], nil]];
        }
        else{
            [fishSprite removeFromParent];
            [_touchFishes removeObject:fishSprite];
        }
    }
    else{
        [self fishSpriteGoBack:fishSprite withOriginalPosition:originalPosition];
    }
}

-(void)fishSpriteTouchCanceledBlock:(UITouch* )touch onFish:(TouchFishSprite* )fishSprite withOriginalPosition:(CGPoint)originalPosition{
    [self fishSpriteGoBack:fishSprite withOriginalPosition:originalPosition];
}

-(void)fishSpriteGoBack:(TouchFishSprite* )fishSprite withOriginalPosition:(CGPoint)originalPosition{
    CGFloat distance = ccpDistance(originalPosition, fishSprite.position);
    const CGFloat speed = 1000.f;
    CCTime duration = distance/speed;
    [fishSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:duration position:originalPosition], [CCActionCallBlock actionWithBlock:^{
        fishSprite.userInteractionEnabled = YES;
        fishSprite.isTouching = NO;
    }], nil]];
}

-(BOOL)fishIsTouching{
    for (TouchFishSprite* fishSprite in _touchFishes) {
        if (fishSprite.isTouching == YES) {
            return YES;
        }
    }
    return NO;
}

-(void)update:(CCTime)delta{
    if (_crashFishArray.count) {
        for (FishSwimSprite* fish in _crashFishArray) {
            switch (fish.species) {
                case catfish:
                {
                    [self fishCrashMud:fish];
                    break;
                }
                case blackCarp:
                {
                    [self fishCrashPlant:fish];
                    break;
                }
                case carp:
                {
                    
                    
                    break;
                }
                default:
                    break;
            }
        }
    }
}

-(void)fishCrashMud:(FishSwimSprite* )fish{
    CGRect mudRects[] = {(CGRect){250, 72, 162, 55}, (CGRect){680, 96, 137, 59}};
    int i = 0;
    for (i = 0; i < 2; i++) {
        if (CGRectContainsPoint(mudRects[i], fish.position)) {
            if (fish.isCrashing) {
                break;
            }
            fish.isCrashing = YES;
//            mud
            CGPoint mudPositions[] = {ccp(390, 140), ccp(738, 186)};
            CCSprite* mudSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"mud%d_river.png", i + 1]];
            mudSprite.position = mudPositions[i];
            mudSprite.opacity = 0.f;
            [_backgroundNode addChild:mudSprite z:MUDORDER];
            [mudSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionMoveBy actionWithDuration:1.f position:ccp(5 * (i ? -1 : 1), 5)], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil], [CCActionDelay actionWithDuration:0.2f], [CCActionSpawn actions:[CCActionMoveBy actionWithDuration:1.f position:ccp(5 * (i ? 1 : -1), -5)], [CCActionFadeTo actionWithDuration:1.f opacity:0.f], nil], [CCActionCallBlock actionWithBlock:^{
                [mudSprite removeFromParent];
            }], nil]];
            break;
        }
    }
    if (i == 2) {
        fish.isCrashing = NO;
    }
}

-(void)fishCrashPlant:(FishSwimSprite* )fish{
    CGRect plantRects[] = {(CGRect){317/2.f, 493/2.f, 41, 123}, (CGRect){1556/2.f, 299/2.f, 67/2.f, 215/2.f}, (CGRect){1592/2.f, 299/2.f, 72/2.f, 215/2.f}, (CGRect){1772/2.f, 450/2.f, 35/2.f, 439/2.f}, (CGRect){1730/2.f, 409/2.f, 35/2.f, 439/2.f}, (CGRect){407/2.f, 387/2.f, 67/2.f, 195/2.f}, (CGRect){541/2.f, 203/2.f, 58/2.f, 246/2.f}};
    int i = 0;
    for (i = 0; i < 7; i++) {
        int multNum = 0;
        if (fish.direction == left) {
            if (fish.flipX) {
                multNum = 1;
            }
            else{
                multNum = -1;
            }
        }
        else if(fish.direction == right){
            if (fish.isFlipX) {
                multNum = -1;
            }
            else{
                multNum = 1;
            }
        }
        if (CGRectContainsPoint(plantRects[i], ccp(fish.position.x + fish.contentSize.width/2.f * multNum, fish.position.y))) {
//            if (fish.isCrashing) {
//                break;
//            }
//            fish.isCrashing = YES;
            CCSprite* plant = _crashSpriteArray[i];
            [plant stopAllActions];
            
            [plant runAction:[CCActionSequence actions:[CCActionRotateTo actionWithDuration:0.1f angle:-0.2f * multNum], [CCActionRotateTo actionWithDuration:1.f angle:multNum * (arc4random()%3 + 10.f)], [CCActionDelay actionWithDuration:0.8f], [CCActionRotateTo actionWithDuration:1.5f angle:multNum * -1.f], [CCActionRotateTo actionWithDuration:0.5f angle:multNum * 0.f], [CCActionCallBlock actionWithBlock:^{
                [plant runAction:[self plantShakeAction]];
            }], nil]];
            
//            break;
        }
    }
    if (i == 7) {
//        fish.isCrashing = NO;
    }

}





-(void)onExit{
    [_crashSpriteArray removeAllObjects];
    [_crashFishArray removeAllObjects];
    [_touchFishes removeAllObjects];
    [_fishMaxNumArray removeAllObjects];
    [_backgroundNode removeAllChildren];
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{
    
}

@end
