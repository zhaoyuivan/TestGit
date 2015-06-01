//
//  MigrationFishScene.m
//  DDT-Carp
//
//  Created by Z on 15/1/8.
//  Copyright (c) 2015年 DDTown. All rights reserved.
//

#import "MigrationFishScene.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "TouchFishSprite.h"
#import "FishSwimSprite.h"
#import "CCTextureCache.h"
#import "SwimOceanNode.h"

#define SKYORDER 100
#define WATERORDER 200
#define FISHORDER 300
#define MOUNTAINORDER 400
#define BOARDORDER 800
#define BUTTONORDER 900

#define WATERHEIGHT 550

@interface MigrationFishScene ()
{
    CCNode* _backgroundNode;
    NSMutableArray* _touchFishes;
    NSMutableArray* _fishMaxNumArray;
    
//    tip
    BOOL _showTip;
}
@end

@implementation MigrationFishScene
+(MigrationFishScene *)scene{
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
        
//        home
        TouchSprite* homeSprite = [TouchSprite spriteWithImageNamed:@"menu.png"];
        homeSprite.position = ccp(115/2, 768 - 120/2);
        [_backgroundNode addChild:homeSprite z:10000];
        homeSprite.userInteractionEnabled = YES;
        __unsafe_unretained TouchSprite* homeSpriteTemp = homeSprite;
        homeSprite.touchBegan = ^(UITouch* touch){
            homeSpriteTemp.userInteractionEnabled = NO;
            [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
//            [[CCDirector sharedDirector] replaceScene:[ContentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
        };
        
        _touchFishes = [[NSMutableArray alloc] init];
        _fishMaxNumArray = [[NSMutableArray alloc] initWithObjects:@"3", @"3", @"3", @"2", @"2", nil];
        
//        tip
        _showTip = YES;
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createBackgroud];
}

-(void)createBackgroud{
//    sky
    CCSprite* skySprite = [CCSprite spriteWithImageNamed:@"sky_migration.png"];
    skySprite.anchorPoint = ccp(0.f, 0.f);
    skySprite.position = ccp(0.f, 0.f);
    skySprite.opacity = 0.f;
    [_backgroundNode addChild:skySprite z:SKYORDER];
    [skySprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
    
//    water
    SwimOceanNode* waterSprite = [[SwimOceanNode alloc] initWithImageNamed:@"water_migration.png" andTexture:[CCTexture textureWithFile:@"water_migration.png"]];
    waterSprite.position = ccp(512, -waterSprite.contentSize.height/2.f);
    [_backgroundNode addChild:waterSprite z:WATERORDER];
    
    [waterSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f position:ccp(512, 768 - 911.5/2.f)], [CCActionCallBlock actionWithBlock:^{
        waterSprite.isStartShake = YES;
    }], nil]];
    
//    mountain
    CCSprite* mountainSprite = [CCSprite spriteWithImageNamed:@"mountain_migration.png"];
    mountainSprite.position = ccp(512, 768 - 1011.5/2.f);
    mountainSprite.opacity = 0.f;
    [_backgroundNode addChild:mountainSprite z:MOUNTAINORDER];
    [mountainSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];

//    fish board
    CCSprite* fishBoard = [CCSprite spriteWithImageNamed:@"board_migration.png"];
    fishBoard.anchorPoint = ccp(1.f, 0.5f);
    fishBoard.position = ccp(1024, 768 - 164/2.f);
    [_backgroundNode addChild:fishBoard z:BOARDORDER];
    
    CGPoint fishPositions[] = {ccp(497/2.f, 768 - 168/2.f), ccp(738/2.f, 768 - 166/2.f), ccp(968/2.f, 768 - 166/2.f), ccp(1275/2.f, 768 - 166/2.f), ccp(1637/2.f, 768 - 158/2.f)};
    
    __unsafe_unretained MigrationFishScene* weakSelf = self;
    for (int i = 0; i < 5; i++) {
        TouchFishSprite* fishSprite = [TouchFishSprite spriteWithImageNamed:[NSString stringWithFormat:@"fish%d_migration.png", i + 1]];
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
    
    fishBoard.position = ccp(fishBoard.contentSize.width + 1024, 768 - 164/2.f);
    
//    fish button
    TouchSprite* fishButton = [TouchSprite spriteWithImageNamed:@"button_migration.png"];
    fishButton.position = ccp(1920/2.f, 768 - 158/2.f);
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
//        tip once
        [self showTip];
        
//        add fish
        FishSwimSprite* fish = [[FishSwimSprite alloc] initWithImageNamed:[NSString stringWithFormat:@"%@_migration.png", fishSprite.name] andSwimRect:(CGRect){0, 50, 1024, WATERHEIGHT - 50}];
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

-(void)showTip{
    if (!_showTip) {
        return;
    }
    _showTip = NO;
    
//    tip
    const CGFloat defaultLength = 30.f;
    
    NSString* tip = NSLocalizedString(@"migration_tip", nil);
    CGFloat fontSize = [NSLocalizedString(@"migration_tip_font_size", nil) doubleValue];
    CGFloat letterWidth = [NSLocalizedString(@"migration_tip_letter_width", nil) doubleValue];
    
    CGSize fontDimension = (CGSize){10 * defaultLength, 0.f};
    
    CGFloat rectScaleY = 1.f;
    if (tip.length * letterWidth / fontDimension.width > 2.f) {
        int row = ceil(tip.length * letterWidth / fontDimension.width);
        rectScaleY = row/2.f;
    }
    
    CCSprite* rect = [CCSprite spriteWithImageNamed:@"tips_bg_migration.png"];
    
    CCNode* tipNode = [CCNode node];
    tipNode.contentSize = rect.contentSize;
    tipNode.anchorPoint = ccp(0.5f, 0.5f);
    tipNode.position = ccp(402/2.f, 768 - 1164/2.f);
    [_backgroundNode addChild:tipNode z: 1000];
    
    CCSprite* lamp = [CCSprite spriteWithImageNamed:@"tips_light.png"];
    lamp.position = [tipNode convertToNodeSpace:ccp(101/2.f, 768 - 1148/2.f)];
    [tipNode addChild:lamp z:1];
    
    rect.position = [tipNode convertToNodeSpace:ccp(402/2.f, 768 - 1164/2.f)];
    rect.scaleY = rectScaleY;
    [tipNode addChild:rect z:1];
    
    CCLabelTTF* tipLabel = [CCLabelTTF labelWithString:tip fontName:@"STYuanti-SC-Regular" fontSize:fontSize dimensions:fontDimension];
    tipLabel.position = [tipNode convertToNodeSpace:ccp(483/2.f, 768 - 1159/2.f)];
    tipLabel.horizontalAlignment = CCTextAlignmentCenter;
    tipLabel.color = [CCColor colorWithCcColor4f:ccc4f(1.f, 232/255.f, 81/255.f, 1.f)];
    [tipNode addChild:tipLabel z:1];
    
    tipNode.position = ccp(-rect.contentSize.width/2.f, tipNode.position.y);
    [tipNode runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f position:ccp(402/2.f, 768 - 1164/2.f)], nil]];
}





-(void)onExit{
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
