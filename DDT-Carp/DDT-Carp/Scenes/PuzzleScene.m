//
//  PuzzleScene.m
//  DDT-Carp
//
//  Created by Z on 15/1/9.
//  Copyright (c) 2015年 DDTown. All rights reserved.
//

#import "PuzzleScene.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "TouchSprite.h"
#import "TouchFishSprite.h"
#import "Fireworks.h"
#import "CCAnimation+Helper.h"
#import "BubbleRise.h"
#import "BoardSprite.h"
#import "CCTextureCache.h"

#import "ContentScene.h"
#import "LiveEnvironmentScene.h"

#define FISHORDER 100
#define BOARDORDER 100
#define BUTTONORDER 200

@interface PuzzleScene ()
{
    CCNode* _backgroundNode;
    NSMutableArray* _fishImages;
    NSMutableArray* _fishSmallPos;
    NSMutableArray* _touchFishes;
    NSMutableArray* _carpComponentsArray;
    
//    bubble
    BOOL _bubbleStart;
    CCTime _createBubbleTime;
    
//    fish
    CCSprite* _fishSprite;
}
@end

@implementation PuzzleScene
+(PuzzleScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self.prevButton removeFromParent];
        
        _backgroundNode = [CCNode node];
        _backgroundNode.contentSize = [[CCDirector sharedDirector] viewSize];
        _backgroundNode.anchorPoint = ccp(0, 0);
        _backgroundNode.position = ccp(0, 0);
        [self addChild:_backgroundNode];
        
        _fishImages = [NSMutableArray arrayWithObjects:@"eye", @"gill", @"scale", @"body", @"pectoral_fin", @"anal_fin", @"ventral_fin", @"tail_fin", @"dorsal_fin", nil];
        _fishSmallPos = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(477/2, 768 - 196/2)], [NSValue valueWithCGPoint:ccp(650/2, 768 - 181/2)], [NSValue valueWithCGPoint:ccp(1024/2, 768 - 195/2)], [NSValue valueWithCGPoint:ccp(1508/2, 768 - 187/2)], [NSValue valueWithCGPoint:ccp(485/2, 768 - 189/2)], [NSValue valueWithCGPoint:ccp(729/2, 768 - 185/2)], [NSValue valueWithCGPoint:ccp(952/2, 768 - 195/2)], [NSValue valueWithCGPoint:ccp(1171/2, 768 - 195/2)], [NSValue valueWithCGPoint:ccp(1517/2, 768 - 196/2)], nil];
        _touchFishes = [[NSMutableArray alloc] init];
        _carpComponentsArray = [[NSMutableArray alloc] init];
        _bubbleStart = YES;
        _createBubbleTime = 5.f;
        self.nextButton.visible = NO;
        self.homeButton.visible = NO;
        self.currentScene = @"puzzle";
        self.imageSuffix = @"puzzle";
    }
    return self;
}

-(void)update:(CCTime)delta{
//    bubbles
    if (_bubbleStart) {
        _createBubbleTime += delta;
        if (_createBubbleTime >= 3.f) {
            _createBubbleTime = 0.f;
            BubbleRise* bubbleRise = [BubbleRise node];
            CGFloat x = 100.0 + arc4random()%970;
            CGFloat y = 50.0 + arc4random()%50;
            bubbleRise.position = ccp(x, y);
            bubbleRise.numberOfBubbles = 5;
            bubbleRise.riseTime = (768 + bubbleRise.contentSize.height)/70.f + arc4random()%3;
            bubbleRise.randomNumberOfBubbles = YES;
            bubbleRise.imageName = @"bubble";
            bubbleRise.imageSuffixName = @"_puzzle";
            bubbleRise.numberOfImages = 4;
            bubbleRise.isDestroySelf = YES;
            [_backgroundNode addChild:bubbleRise z:1];
        }
    }
}

-(void)onEnter{
    [super onEnter];
    [self createBackground];
}

-(void)nextPress:(CCButton *)button{
    if(self.step == 1) {
        [[CCDirector sharedDirector] replaceScene:[LiveEnvironmentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    else{
        BoardSprite* boardSprite = (BoardSprite* )[_backgroundNode getChildByName:@"popBoard" recursively:NO];
        [boardSprite getGoNextHandle:boardSprite];
    }
    button.enabled = NO;
}

-(void)createBackground{
//    bg
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_puzzle.png"];
    bgSprite.name = @"none";
    bgSprite.anchorPoint = ccp(0, 0);
    bgSprite.position = ccp(0, 0);
    [_backgroundNode addChild:bgSprite z:1];
    
//    dark fish
    CGPoint bgPositions[] = {ccp(342.5/2, 768 - 970/2), ccp(491.5/2, 768 - 989.5/2), ccp(1023.5/2, 768 - 970/2), ccp(888.5/2, 768 - 957/2), ccp(649.5/2, 768 - 1241/2), ccp(1474.5/2, 768 - 1126.5/2), ccp(1066.5/2, 768 - 1264/2), ccp(1738.5/2, 768 - 910/2), ccp(1152/2, 768 - 653/2)};
    int bgZOrders[] = {2, 3, 2, 1, 3, 3, 3, 1, 3};
    for (int i = 0; i < _fishImages.count; i++) {
        CCSprite* fishBgSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@_bg_puzzle.png", _fishImages[i]]];
        fishBgSprite.position = bgPositions[i];
        fishBgSprite.name = [NSString stringWithFormat:@"%@_bg", _fishImages[i]];
        [_backgroundNode addChild:fishBgSprite z:FISHORDER + bgZOrders[i]];
        [_carpComponentsArray addObject:fishBgSprite];
    }
}

-(void)createScene{
//    fish board
    CCSprite* fishBoard = [CCSprite spriteWithImageNamed:@"board_puzzle.png"];
    fishBoard.anchorPoint = ccp(1.f, 0.5f);
    fishBoard.position = ccp(1024, 768 - 189/2.f);
    fishBoard.name = @"board";
    [_backgroundNode addChild:fishBoard z:BOARDORDER];

    [self loadFishesIcons:4 andIsReload:NO];
    fishBoard.position = ccp(fishBoard.contentSize.width + 1024, 768 - 189/2.f);
    
//    fish button
    TouchSprite* fishButton = [TouchSprite spriteWithImageNamed:@"button_puzzle.png"];
    fishButton.position = ccp(1900/2.f, 768 - 173/2.f);
    fishButton.userInteractionEnabled = NO;
    fishButton.name = @"button";
    [_backgroundNode addChild:fishButton z:BUTTONORDER];
    
    CCSprite* iconSprite = [CCSprite spriteWithImageNamed:@"icon_puzzle.png"];
    iconSprite.position = [fishButton convertToNodeSpace:ccp(1900/2.f, 768 - 170/2.f)];
    [fishButton addChild:iconSprite];
    
    [iconSprite runAction:[ActionProvider getRepeatShakePrompt]];
    
    fishButton.userInteractionEnabled = YES;
    
    __unsafe_unretained PuzzleScene* weakSelf = self;
    __unsafe_unretained TouchSprite* fishButtonTemp = fishButton;
    __unsafe_unretained CCSprite* fishBoardTemp = fishBoard;
    __unsafe_unretained CCSprite* iconSpriteTemp = iconSprite;
    fishButton.touchBegan = ^(UITouch* touch){
        if([weakSelf fishIsTouching]){
            return;
        }
        [iconSpriteTemp stopAllActions];
        iconSpriteTemp.rotation = 0.f;
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
    fishSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@_real_puzzle.png", fishSprite.name]];
}

-(void)fishSpriteTouchMovedBlock:(UITouch* )touch onFish:(TouchFishSprite* )fishSprite{
    fishSprite.position = [touch locationInNode:_backgroundNode];
}

-(void)fishSpriteTouchEndedBlock:(UITouch* )touch onFish:(TouchFishSprite* )fishSprite withOriginalPosition:(CGPoint)originalPosition{
    CCSprite* fishBgSprite = (CCSprite* )[_backgroundNode getChildByName:[NSString stringWithFormat:@"%@_bg", fishSprite.name] recursively:NO];
    if (CGRectContainsPoint(fishBgSprite.boundingBox, fishSprite.position)) {
        CGFloat distance = ccpDistance(fishBgSprite.position, fishSprite.position);
        const CGFloat speed = 1000.f;
        CCTime duration = distance/speed;
        __unsafe_unretained TouchFishSprite* fishSpriteTemp = fishSprite;
        __unsafe_unretained CCSprite* fishBgSpriteTemp = fishBgSprite;
        __unsafe_unretained NSMutableArray* touchFishesTemp = _touchFishes;
        __unsafe_unretained NSMutableArray* fishImagesTemp = _fishImages;
        __unsafe_unretained PuzzleScene* weakSelf = self;
        [fishSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:duration position:fishBgSprite.position], [CCActionCallBlock actionWithBlock:^{
            [fishSpriteTemp runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.1f scale:1.05f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.1f scale:0.95f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.05f scale:1.02f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.05f scale:1.f], [CCActionDelay actionWithDuration:0.f], nil]];
            fishSpriteTemp.isTouching = NO;
            fishSpriteTemp.zOrder = fishBgSpriteTemp.zOrder;
            [touchFishesTemp removeObject:fishSprite];
            if (touchFishesTemp.count == 0 && fishImagesTemp.count == 0) {
                [weakSelf puzzleGameOver];
            }
            else if (touchFishesTemp.count == 0) {
                [weakSelf loadFishesIcons:(int)fishImagesTemp.count andIsReload:YES];
            }
            
        }], nil]];
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
        fishSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@_small_puzzle.png", fishSprite.name]];
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

-(void)loadFishesIcons:(int)count andIsReload:(BOOL)isReload{
    if (count == 0) {
        return;
    }
    CCSprite* boardSprite = (CCSprite* )[_backgroundNode getChildByName:@"board" recursively:NO];
    __unsafe_unretained PuzzleScene* weakSelf = self;
    for (int i = 0; i < count; i++) {
        TouchFishSprite* fishSprite = [TouchFishSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@_small_puzzle.png", _fishImages.firstObject]];
        fishSprite.position = [boardSprite convertToNodeSpace:[_fishSmallPos.firstObject CGPointValue]];
        fishSprite.name = _fishImages.firstObject;
        fishSprite.userInteractionEnabled = NO;
        fishSprite.isTouching = NO;
        [boardSprite addChild:fishSprite];
        [_touchFishes addObject:fishSprite];
        __block CGPoint originalPosition = [_fishSmallPos.firstObject CGPointValue];
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
        
        [_carpComponentsArray addObject:fishSprite];
        [_fishImages removeObjectAtIndex:0];
        [_fishSmallPos removeObjectAtIndex:0];
    }
    if (isReload) {
        [self boardReload];
    }
}

-(void)boardReload{
    CCSprite* boardSprite = (CCSprite* )[_backgroundNode getChildByName:@"board" recursively:NO];
    TouchSprite* buttonSprite = (TouchSprite* )[_backgroundNode getChildByName:@"button" recursively:NO];
    buttonSprite.userInteractionEnabled = NO;
    for (TouchFishSprite* fish in boardSprite.children) {
        fish.opacity = 0.f;
    }
    
    __unsafe_unretained PuzzleScene* weakSelf = self;
    __unsafe_unretained CCSprite* boardSpriteTemp = boardSprite;
    __unsafe_unretained TouchSprite* buttonSpriteTemp = buttonSprite;
    [boardSprite runAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:0.5f position:ccp(boardSpriteTemp.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
        for (TouchFishSprite* fish in boardSprite.children) {
            fish.opacity = 1.f;
        }
    }], [CCActionMoveBy actionWithDuration:0.5f position:ccp(-boardSpriteTemp.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
        buttonSpriteTemp.userInteractionEnabled = YES;
        [weakSelf adjustFishPositionOnFishBoard:boardSpriteTemp isAfterMove:YES];
    }], nil]];
}

-(void)puzzleGameOver{
//    bubble stop
    _bubbleStart = NO;
    
//    fish
    _fishSprite = [CCSprite spriteWithImageNamed:@"carp_puzzle.png"];
    _fishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [_backgroundNode addChild:_fishSprite z:FISHORDER];
    
    for (CCSprite* sprite in _carpComponentsArray) {
        [sprite removeFromParent];
    }
    
    CCSprite* boardSprite = (CCSprite* )[_backgroundNode getChildByName:@"board" recursively:NO];
    TouchSprite* buttonSprite = (TouchSprite* )[_backgroundNode getChildByName:@"button" recursively:NO];
    [boardSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0], [CCActionCallBlock actionWithBlock:^{
        [boardSprite removeFromParent];
    }], nil]];
    
    buttonSprite.userInteractionEnabled = NO;
    [(CCSprite* )buttonSprite.children.firstObject runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0], [CCActionCallBlock actionWithBlock:^{
        
    }], nil]];

    [buttonSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0], [CCActionCallBlock actionWithBlock:^{
        [buttonSprite removeAllChildren];
        [buttonSprite removeFromParent];
    }], nil]];
    
    CCAnimation* carpAnimation = [CCAnimation animationWithFile:@"carp" withSuffix:@"_puzzle" frameCount:4 delay:0.15f];
    [_fishSprite runAction:[CCActionSequence actions:[CCActionRepeat actionWithAction:[CCActionAnimate actionWithAnimation:carpAnimation] times:3], [CCActionDelay actionWithDuration:0.5f], [CCActionCallBlock actionWithBlock:^{
        Fireworks* bubbles = [Fireworks node];
        bubbles.fireworkNumber = 25;
        bubbles.imageCount = 5;
        bubbles.imageStingSuffix = @"";
        bubbles.imageString = @"bubble";
        bubbles.position = _fishSprite.position;
        [_backgroundNode addChild:bubbles z:FISHORDER];
        
        __unsafe_unretained PuzzleScene* weakSelf = self;
        [_fishSprite runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:4.f scale:0.6], [CCActionCallBlock actionWithBlock:^{
            [weakSelf showBoard];
        }], nil]];
        
    }], nil]];
}

-(void)showBoard{
    BoardSprite* boardSprite = [BoardSprite spriteWithTitleImageString:@"title1_puzzle.png" andGoNextImageString:@"next.png"];
    boardSprite.name = @"popBoard";
    __unsafe_unretained CCSprite* fishSpriteTemp = _fishSprite;
    boardSprite.beforeGoDownBlock = ^(){
//    fish
        fishSpriteTemp.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"carp_well1_puzzle.png"];
        fishSpriteTemp.scale = 1;
    };
    
    boardSprite.afterGoDownBlock = ^(){
        [[CCDirector sharedDirector] replaceScene:[LiveEnvironmentScene scene]];
    };
    
    [_backgroundNode addChild:boardSprite z:BOARDORDER];
    self.step = 2;
}


-(void)onExit{
    [_backgroundNode removeAllChildren];
    [self removeAllChildren];
    [_fishImages removeAllObjects];
    [_fishSmallPos removeAllObjects];
    [_touchFishes removeAllObjects];
    [_carpComponentsArray removeAllObjects];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{
    
}

@end
