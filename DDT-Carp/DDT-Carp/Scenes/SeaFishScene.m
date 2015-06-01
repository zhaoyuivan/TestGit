//
//  SeaFishScene.m
//  DDT-Carp
//
//  Created by Z on 14/12/30.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "SeaFishScene.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "TouchSprite.h"
#import "MoveSprite.h"
#import "FishSwimSprite.h"
#import "TouchFishSprite.h"
#import "CCAnimation+Helper.h"
#import "ScrollViewNode.h"
#import "CCTextureCache.h"

//#import "ContentScene.h"

#define SKYORDER 100
#define WATERORDER 200
#define HILLORDER 300
#define CORALORDER 400
#define LIGHTORDER 500
#define WAVEORDER 600

#define WATERHEIGHT 550
#define LEFTHILLHEIGHT 200
#define RIGHTHILLHEIGHT 100

@interface SeaFishScene ()<CCScrollViewDelegate>
{
    ScrollViewNode* _backgroundNode;
    CCScrollView * _scrollView;
    NSMutableArray* _movedSprites;
    NSMutableArray* _touchFishes;
    NSMutableArray* _fishMaxNumArray;
}
@end

@implementation SeaFishScene
+(SeaFishScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//    home
        TouchSprite* homeSprite = [TouchSprite spriteWithImageNamed:@"menu.png"];
        homeSprite.position = ccp(115/2, 768 - 120/2);
        [self addChild:homeSprite z:10000];
        homeSprite.userInteractionEnabled = YES;
        __unsafe_unretained TouchSprite* homeSpriteTemp = homeSprite;
        homeSprite.touchBegan = ^(UITouch* touch){
            homeSpriteTemp.userInteractionEnabled = NO;
            [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
//            [[CCDirector sharedDirector] replaceScene:[ContentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
        };
        
        _movedSprites = [[NSMutableArray alloc] init];
        _touchFishes = [[NSMutableArray alloc] init];
        _fishMaxNumArray = [[NSMutableArray alloc] initWithObjects:@"5", @"4", @"3", @"4", @"3", nil];
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createScrollView];
}

-(void)createScrollView{
    _scrollView = [[CCScrollView alloc] initWithContentNode:[self createBackgroud]];
    _scrollView.contentSize = (CGSize){1, 1};
    _scrollView.anchorPoint = ccp(0, 0);
    _scrollView.position = ccp(0, 0);
    _scrollView.verticalScrollEnabled = YES;
    _scrollView.horizontalScrollEnabled = NO;
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    [self addChild:_scrollView];
    _backgroundNode.parentScrollView = _scrollView;
}

-(CCNode* )createBackgroud{
    _backgroundNode = [ScrollViewNode node];
    CGFloat height = 2317/4.f - (768 - 1526.5/2.f) + 768;
    _backgroundNode.scrollViewSize = (CGSize){1024, height};
    _backgroundNode.contentSize = (CGSize){1, height/768.f};
    
//    sky
    CCSprite* skySprite = [CCSprite spriteWithImageNamed:@"sky_sea.png"];
    skySprite.position = ccp(512, 570);
    skySprite.opacity = 0.f;
    [_backgroundNode addChild:skySprite z:SKYORDER];
    [skySprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
    
//    water
    [self createWaters];
    
//    light
    [self createLights];

//    hill
    CGPoint hillPositions[] = {ccp(834/2.f, 768 - 1854/2.f + LEFTHILLHEIGHT), ccp(1675/2.f, 768 - 1935/2.f + RIGHTHILLHEIGHT)};
    for (int i = 0 ; i < 2; i++) {
        CCSprite* hillSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"hill%d_sea.png", i + 1]];
        hillSprite.name = [NSString stringWithFormat:@"hill%d", i + 1];
        hillSprite.position = hillPositions[i];
        hillSprite.opacity = 0.f;
        [_backgroundNode addChild:hillSprite z:HILLORDER];
        [hillSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
    }

//    coral
    CGPoint coralPositions[] = {ccp(502/2.f, 768 - 1435.5/2.f), ccp(490/2.f, 768 - 1681.5/2.f), ccp(582.5/2.f, 768 - 983.5/2.f)};
    for (int i = 0; i < 3; i++) {
        CCSprite* coralSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"coral%d_sea.png", i + 1]];
        coralSprite.position = coralPositions[i];
        coralSprite.opacity = 0.f;
        [_backgroundNode addChild:coralSprite z:CORALORDER + 2 - i];
        [coralSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
    }
    
//    wave
    for (int i = 0; i < 2; i++) {
        CCSprite* waveSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"wave%d_sea.png", i + 1]];
        waveSprite.position = ccp(1025/2.f, 768 - 1476/2.f);
        waveSprite.opacity = 0.f;
        [_backgroundNode addChild:waveSprite z:CORALORDER];
        [waveSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
    }

//    fish board
    CCSprite* fishBoard = [CCSprite spriteWithImageNamed:@"board_sea.png"];
    fishBoard.anchorPoint = ccp(1.f, 0.5f);
    fishBoard.position = ccp(1024, 768 - 137/2.f);
    [self addChild:fishBoard z:100];
    
    CGPoint fishPositions[] = {ccp(512/2.f, 768 - 143/2.f), ccp(727/2.f, 768 - 135/2.f), ccp(1004/2.f, 768 - 135/2.f), ccp(1321/2.f, 768 - 143/2.f), ccp(1652/2.f, 768 - 140/2.f)};
    
    __unsafe_unretained SeaFishScene* weakSelf = self;
    for (int i = 0; i < 5; i++) {
        TouchFishSprite* fishSprite = [TouchFishSprite spriteWithImageNamed:[NSString stringWithFormat:@"fish%d%@_sea.png", i + 1, (i == 2 ? @"_1" : @"")]];
        fishSprite.position = [fishBoard convertToNodeSpace:fishPositions[i]];
        fishSprite.name = [NSString stringWithFormat:@"fish%d%@", i + 1, (i == 2 ? @"_1" : @"")];
        fishSprite.userInteractionEnabled = NO;
        fishSprite.isTouching = NO;
        [fishBoard addChild:fishSprite];
        if (i == 4) {
            CCSprite* lightSprite = [CCSprite spriteWithImageNamed:@"light_sea.png"];
            lightSprite.position = [fishSprite convertToNodeSpace:ccp(1516/2.f, 768 - 56/2.f)];
            [fishSprite addChild:lightSprite];
        }
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
    TouchSprite* fishButton = [TouchSprite spriteWithImageNamed:@"button_sea.png"];
    fishButton.position = ccp(1932/2.f, 768 - 136/2.f);
    fishButton.opacity = 0.f;
    fishButton.userInteractionEnabled = NO;
    [self addChild:fishButton z:100];
    
    [fishButton runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.5f], [CCActionFadeTo actionWithDuration:1.5f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
        fishButton.userInteractionEnabled = YES;
        [fishButton runAction:[ActionProvider getRepeatScalePrompt]];
        for (MoveSprite* sprite in _movedSprites) {
            sprite.isMoveStart = YES;
        }
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
    return _backgroundNode;
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
            lightSprite.endPoint =  [_backgroundNode convertPosition:ccp(1043/2 + 1024 * (i == 0 ? -1 : 1), 768 - 898/2)];
            lightSprite.isDetroySelf = NO;
            lightSprite.endScale = 1.f;
            lightSprite.isRandomDuration = NO;
            lightSprite.duration = j == 0 ? 18.f : 36.f;
            lightSprite.delayCreationTime = 0.f;
            __unsafe_unretained MoveSprite* lightSpriteTemp = lightSprite;
            __unsafe_unretained ScrollViewNode* backgroundNodeTemp = _backgroundNode;
            __block int iTemp = i;
            lightSprite.cycleBlock = ^(){
                lightSpriteTemp.startPoint = [backgroundNodeTemp convertPosition:ccp(1043/2 + 1024 * (iTemp == 0 ? 1 : -1), 768 - 898/2)];
                lightSpriteTemp.endPoint =  [backgroundNodeTemp convertPosition:ccp(1043/2 + 1024 * (iTemp == 0 ? -1 : 1), 768 - 898/2)];
                lightSpriteTemp.duration = 36.f;
            };
            lightSprite.isMoveStart = YES;
            [_backgroundNode addChild:lightSprite z:LIGHTORDER];
            lightSprite.opacity = 0;
            [lightSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
        }
    }
}

-(void)createWaters{
    CGFloat ys[] = {768 - 1526.5/2.f, 768 - 480/2.f, 768 - 434/2.f};
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 2; j++) {
            MoveSprite* water = [MoveSprite spriteWithImageNamed:[NSString stringWithFormat:@"water%d_sea.png", i + 1]];
            water.anchorPoint = ccp(0, 0.5f);
            water.name = [NSString stringWithFormat:@"water%d", i + 1];
            __unsafe_unretained MoveSprite* waterTemp = water;
            if (j == 0) {
                water.position = ccp(0, - water.contentSize.height/2.f - 180 + i * 60);
                [water runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f + i * 0.f position: [_backgroundNode convertPosition:ccp(0, ys[i])]], [CCActionCallBlock actionWithBlock:^{
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
            water.startPoint = [_backgroundNode convertPosition:ccp(j == 0 ? 0 : 1024, ys[i])];;
            water.endPoint = [_backgroundNode convertPosition:ccp(-1024, ys[i])];
            water.endScale = 1.f;
            water.duration = (25.f + i * 3) * (j == 0 ? 1.f : 2.f);
            water.delayCreationTime = 0.f;
            __block CGFloat yTemp = ys[i];
            __block int iTemp = i;
            __unsafe_unretained ScrollViewNode* backgroudNodeTemp = _backgroundNode;
            water.cycleBlock = ^(){
                waterTemp.startPoint = [backgroudNodeTemp convertPosition:ccp(1023, yTemp)];
                waterTemp.duration = 2.f * (25.f + 3 * iTemp);
            };
        }
    }
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
                [self addChild:touchFish z:1000];
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
    fishSprite.position = [touch locationInNode:self];
    fishSprite.isTouching = YES;
    fishSprite.userInteractionEnabled = NO;
}

-(void)fishSpriteTouchMovedBlock:(UITouch* )touch onFish:(TouchFishSprite* )fishSprite{
    fishSprite.position = [touch locationInNode:self];
}

-(void)fishSpriteTouchEndedBlock:(UITouch* )touch onFish:(TouchFishSprite* )fishSprite withOriginalPosition:(CGPoint)originalPosition{
//    CGRect rect = CGRectZero;
//    if ([[fishSprite.name substringWithRange:(NSRange){4, 1}] intValue] < 4) {
//        rect = (CGRect){0, _scrollView.scrollPosition.y, 1024, WATERHEIGHT};
//    }
//    else{
//        rect = (CGRect){0, 0, 1024, _scrollView.scrollPosition.y};
//    }
    CGRect rect = (CGRect){0, 0, 1024, WATERHEIGHT};
    if (CGRectContainsPoint(rect, fishSprite.position)) {
//        add fish
        CGRect swimRect = (CGRect){0, 0, 1024, WATERHEIGHT};
        if([fishSprite.name isEqualToString:@"fish5"] || [fishSprite.name isEqualToString:@"fish4"]){
            swimRect = (CGRect){0, -150, 1024, 768 - _backgroundNode.scrollViewSize.height + 180};
        }
        else if([fishSprite.name isEqualToString:@"fish3_1"]){
            swimRect = (CGRect){0, -150, 1024, 350};
        }
        FishSwimSprite* fish = [[FishSwimSprite alloc] initWithImageNamed:[NSString stringWithFormat:@"%@_sea.png", fishSprite.name] andSwimRect:swimRect];
        if ([fishSprite.name isEqualToString:@"fish5"]) {
            CCSprite* lightSprite = [CCSprite spriteWithImageNamed:@"light_sea.png"];
             lightSprite.position = ccpSub(ccp(1516/2.f, 768 - 56/2.f), ccp(1652/2.f - fishSprite.contentSize.width/2.f, 768 - 140/2.f - fishSprite.contentSize.height/2.f));
            [fish addChild:lightSprite];
            [lightSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:2.f scale:2.0f], [CCActionDelay actionWithDuration:0.1f], [CCActionScaleTo actionWithDuration:2.f scale:0.5f], [CCActionDelay actionWithDuration:0.1f], nil]]];
        }
        else if (fishSprite.name.length > 5){
            fish.showAnimation = YES;
            fish.animationCount = 4;
            fish.animationDelayTime = 1/6.f;
            fish.animationFileName = @"fish3_";
            fish.animationFileSuffix = @"_sea";
        }
//        if ([fishSprite.name isEqualToString:@"fish1"]) {
//            fish.species = blackCarp;
//            [_crashFishArray addObject:fish];
//        }
//        else if([fishSprite.name isEqualToString:@"fish2"]){
//            fish.species = catfish;
//            [_crashFishArray addObject:fish];
//        }
        fish.isNeedConvertPosition = YES;
        fish.position = ccpSub(fishSprite.position, _scrollView.scrollPosition);
        fish.userInteractionEnabled = YES;
        int fishOrderArray[] = {HILLORDER, CORALORDER, CORALORDER + 2};
        [_backgroundNode addChild:fish z:fishOrderArray[arc4random()%3]];
        
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
            [fishSprite removeAllChildren];
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

-(void)scrollViewDidScroll:(CCScrollView *)scrollView{
    NSLog(@"%@", NSStringFromCGPoint(scrollView.scrollPosition));
    CCSprite* hillLeft = (CCSprite* )[_backgroundNode getChildByName:@"hill1" recursively:NO];
    CCSprite* hillRight = (CCSprite* )[_backgroundNode getChildByName:@"hill2" recursively:NO];
    hillLeft.position = [_backgroundNode convertPosition:ccp(834/2.f, 768 - 1854/2.f + LEFTHILLHEIGHT - scrollView.scrollPosition.y/574.5f * LEFTHILLHEIGHT)];
    hillRight.position = [_backgroundNode convertPosition:ccp(1675/2.f, 768 - 1935/2.f + RIGHTHILLHEIGHT - scrollView.scrollPosition.y/574.5f * RIGHTHILLHEIGHT)];
}







-(void)onExit{
    [_backgroundNode removeAllChildren];
    _scrollView.contentNode = nil;
    [self removeAllChildren];
    [_movedSprites removeAllObjects];
    [_touchFishes removeAllObjects];
    [_fishMaxNumArray removeAllObjects];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{
    
}
@end
