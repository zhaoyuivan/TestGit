//
//  LiveEnvironmentScene.m
//  DDT-Carp
//
//  Created by Z on 14/10/27.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "LiveEnvironmentScene.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "CCTextureCache.h"
#import "TouchSprite.h"
#import "BubbleRise.h"
#import "Fireworks.h"
#import "BoardSprite.h"
#import "CCAnimation+Helper.h"

#import "PuzzleScene.h"
#import "ContentScene.h"
#import "ObserveGillScene.h"
#import "ObserveScene.h"

#define FISHORDER 100
#define LIVEBOARDORDER 200

@interface LiveEnvironmentScene ()
{
    CCNode* _backgroundNode;
    TouchSprite* _goSprite;
    CCSprite* _fishSprite;
    
//    live
    NSMutableArray* _sideBarArray;
    NSString* _currentEnvironment;
    BOOL _isLastLastDeleted;
    CCNode* _lastLastNode;
    NSMutableArray* _mutableTouchArray;
    
//    water bubble
    BOOL _bubbleStart;
    CGFloat _createBubbleTime;
    
//    go next
    BOOL _isGoingRight;
    
}
@end

@implementation LiveEnvironmentScene
+(LiveEnvironmentScene* )scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _backgroundNode = [CCNode node];
        _backgroundNode.contentSize = [[CCDirector sharedDirector] viewSize];
        _backgroundNode.anchorPoint = ccp(0, 0);
        _backgroundNode.position = ccp(0, 0);
        [self addChild:_backgroundNode];
        
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

        
        _isGoingRight = NO;
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createBackground];
}

-(void)prevPress:(CCButton *)button{
    [[CCDirector sharedDirector] replaceScene:[PuzzleScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    button.enabled = NO;
    self.nextButton.enabled = NO;
}

-(void)nextPress:(CCButton *)button{
    if(self.step == 1){
        ObserveGillScene* nextScene = [ObserveGillScene scene];
        nextScene.isJumpHere = YES;
        [[CCDirector sharedDirector] replaceScene:nextScene withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
        [self handleButtons:NO];
    }
    else if(self.step == 2){
        [self goTransition];
        [self handleButtons:NO];
    }
    else{
        BoardSprite* boardSprite = (BoardSprite* )[_backgroundNode getChildByName:@"popBoard" recursively:NO];
        [boardSprite getGoNextHandle:boardSprite];
        [self handleButtons:NO];
    }
}

-(void)createBackground{
//    bg
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_puzzle.png"];
    bgSprite.name = @"none";
    bgSprite.anchorPoint = ccp(0, 0);
    bgSprite.position = ccp(0, 0);
    [_backgroundNode addChild:bgSprite z:1];
    
//    fish
    _fishSprite = [CCSprite spriteWithImageNamed:@"carp_well1_puzzle.png"];
    _fishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [_backgroundNode addChild:_fishSprite z:1];

//    start
    [self showLiveEnvironment];
}

-(void)showLiveEnvironment{
//    init
    _currentEnvironment = @"none";
    _mutableTouchArray = [[NSMutableArray alloc] init];
    _isLastLastDeleted = YES;
    _lastLastNode = nil;
    self.userInteractionEnabled = NO;
    _bubbleStart = NO;
    _createBubbleTime = 10.f;
    
//    live board
    CCSprite* liveBoardSprite = [CCSprite spriteWithImageNamed:@"live_board_puzzle.png"];
    liveBoardSprite.anchorPoint = ccp(0, 0);
    liveBoardSprite.position = ccp(0, 0);
    liveBoardSprite.opacity = 0;
    liveBoardSprite.name = @"liveBoard";
    [_backgroundNode addChild:liveBoardSprite z:LIVEBOARDORDER];
    [liveBoardSprite runAction:[CCActionFadeTo actionWithDuration:5.f opacity:1]];
    
//    prompt
    __block CCSprite* selectPromptSprite = [CCSprite spriteWithImageNamed:@"select_prompt_puzzle.png"];
    selectPromptSprite.position = [liveBoardSprite convertToNodeSpace:ccp(1840/2, 768 - 212.5/2)];
    selectPromptSprite.opacity = 0;
    selectPromptSprite.name = @"selectPrompt";
    [liveBoardSprite addChild:selectPromptSprite z:2];
    
//   sidebar
    _sideBarArray = [NSMutableArray arrayWithCapacity:4];
    NSArray* environmentNameArray = @[@"sky", @"water", @"grass", @"sand"];
    for(int i = 0; i < 4; i++){
        CCSprite* sideBarSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"sidebar%d_puzzle.png", i+1]];
        sideBarSprite.opacity = 0;
        sideBarSprite.name = environmentNameArray[i];
        sideBarSprite.position = ccp(1840/2, 768 - 212.5/2 - i * 184);
        [_sideBarArray addObject:sideBarSprite];
        [liveBoardSprite addChild:sideBarSprite z:1];
        [sideBarSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:2.5f opacity:1], [CCActionCallBlock actionWithBlock:^{
        }], nil]];
    }
    
//    fish
    CCAnimation* fishAnimation = [CCAnimation animationWithFile:@"carp_well" withSuffix:@"_puzzle" frameCount:4 delay:0.15f];
    [_fishSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:fishAnimation]]];
    [_fishSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:2.5f position:ccp(625/2, 768 - 809/2)], [CCActionCallBlock actionWithBlock:^{
        [_fishSprite stopAllActions];
        self.userInteractionEnabled = YES;
        [self performSelector:@selector(liveEnvironmentPrompt:) withObject:selectPromptSprite afterDelay:5.f];
    }], nil]];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInNode:_backgroundNode];
    if (!_isGoingRight) {
        for (CCSprite* sideBar in _sideBarArray) {
            if (CGRectContainsPoint(sideBar.boundingBox, touchPoint)) {
                CCSprite* prompt = (CCSprite* )[sideBar.parent getChildByName:@"selectPrompt" recursively:NO];
                [self liveEnvironmentSelect:prompt andSelectedEnvironment:sideBar];
                break;
            }
        }
    }
    else{
        self.userInteractionEnabled = NO;
        CCNode* waterNode = [_backgroundNode getChildByName:@"waterNode" recursively:NO];
//        move sprite
        CCSprite* leftWaterBg = (CCSprite* )[_backgroundNode getChildByName:@"leftWaterBg" recursively:YES];
        CCSprite* leafSprite = (CCSprite* )[waterNode getChildByName:@"leftLeaf" recursively:NO];
        CCSprite* rightWaterBg = (CCSprite* )[waterNode getChildByName:@"waterBg" recursively:NO];
        CCSprite* midBgOne = (CCSprite* )[waterNode getChildByName:@"plantLeft" recursively:NO];
        CCSprite* midBgTwo = (CCSprite* )[waterNode getChildByName:@"plantRight" recursively:NO];
        CCSprite* frontBg = (CCSprite* )[waterNode getChildByName:@"plantFront" recursively:NO];
        NSArray* moveSprites = @[leftWaterBg, rightWaterBg, midBgOne, midBgTwo, frontBg, leafSprite];
        for (int i = 0; i < moveSprites.count; i++) {
            CCSprite* sprite = moveSprites[i];
            [sprite stopAllActions];
            if (i == 0) {
                sprite.opacity = 0.f;
                sprite.position = ccp(0, 0);
                [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
            }
            else{
                [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], nil]];
            }
        }
        [_fishSprite stopAllActions];
        __unsafe_unretained LiveEnvironmentScene* weakSelf = self;
        [_fishSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f position:ccp(1047/2, 768 - 915.5/2)], [CCActionCallBlock actionWithBlock:^{
            [weakSelf showBoard];
        }], nil]];
    }
}


-(void)liveEnvironmentSelect:(CCSprite* )prompt andSelectedEnvironment:(CCSprite* )sideBarSprite{
    [prompt stopAllActions];
    prompt.scale = 1;
    prompt.opacity = 1;
    prompt.visible = YES;
    CGFloat duration = [[NSValue valueWithCGPoint:prompt.position] isEqualToValue:[NSValue valueWithCGPoint:sideBarSprite.position]] ? 0.f : 0.2f;//abs(sideBarSprite.position.y - prompt.position.y)/184 * 0.5f;
    [prompt runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionFadeTo actionWithDuration:duration opacity:1], [CCActionMoveTo actionWithDuration:duration position:sideBarSprite.position], nil], [CCActionCallBlock actionWithBlock:^{
    }], [CCActionScaleTo actionWithDuration:0.2f scale:1.2f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.2f scale:0.9f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.1f scale:1.05f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.1f scale:1.f], nil]];
    
    if (((![_currentEnvironment isEqualToString:@"none"]) && [[NSValue valueWithCGPoint:prompt.position] isEqualToValue:[NSValue valueWithCGPoint:sideBarSprite.position]]) || ([_currentEnvironment isEqualToString:sideBarSprite.name])) {
        return;
    }
    
    NSString* name = _currentEnvironment;
    CCNode* lastNode = [_backgroundNode getChildByName:[NSString stringWithFormat:@"%@Node", name] recursively:NO];
//    pause
    [self pausePreviousEnvironment:lastNode];
//    remove last last node
    if (!_isLastLastDeleted) {
        [self removeEnvironmentNode:_lastLastNode];
    }
    _isLastLastDeleted = NO;
    _lastLastNode = lastNode;
    if ([sideBarSprite.name isEqualToString:@"water"]) {
//        bingo
        Fireworks* bubbles = [Fireworks node];
        bubbles.fireworkNumber = 10;
        bubbles.imageCount = 5;
        bubbles.maxScale = 0.8f;
        bubbles.minScale = 0.4f;
        bubbles.maxLifeCycle = 3.5f;
        bubbles.minLifeCycle = 2.f;
        bubbles.distance = 150;
        bubbles.imageStingSuffix = @"";
        bubbles.imageString = @"bubble";
        bubbles.position = sideBarSprite.position;
        [sideBarSprite.parent addChild:bubbles z:2];
    }
    [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"create%@Environment:", sideBarSprite.name.capitalizedString]) withObject:lastNode afterDelay:0.f];
}

-(void)liveEnvironmentPrompt:(CCSprite* )prompt{
    if ([_currentEnvironment isEqualToString:@"none"]) {
//        prompt
        prompt.opacity = 1;
        [prompt runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionBlink actionWithDuration:1.f blinks:3], [CCActionDelay actionWithDuration:0.5f], nil]]];
    }
}

-(void)createSkyEnvironment:(CCNode* )lastNode{
    self.step = 1;
    _currentEnvironment = @"sky";
    _bubbleStart = NO;
    
    CCNode* skyNode = [CCNode node];
    skyNode.contentSize = [[CCDirector sharedDirector] viewSize];
    skyNode.name = @"skyNode";
    skyNode.anchorPoint = ccp(0, 0);
    skyNode.position = ccp(0, 0);
    [_backgroundNode addChild:skyNode z:10];
    
//    bg
    CCSprite* skyBgSprite = [CCSprite spriteWithImageNamed:@"sky_bg_puzzle.png"];
    skyBgSprite.position = ccp(819.5/2, 768 - 757.5/2);
    [skyNode addChild:skyBgSprite z:1];
    
//    sun
    CCSprite* sunSprite = [CCSprite spriteWithImageNamed:@"sun_puzzle.png"];
    sunSprite.position = ccp(1248/2, 768 - 326/2);
    [skyNode addChild:sunSprite z:30];
    
//    bird
    CCSprite* birdSprite = [CCSprite spriteWithImageNamed:@"bird1_puzzle.png"];
    birdSprite.position = ccp(407/2, 768 - 359/2);
    [skyNode addChild:birdSprite z:20];
    CCAnimation* birdAnimation = [CCAnimation animationWithFile:@"bird" withSuffix:@"_puzzle" frameCount:2 delay:0.15f];
    
//    clouds
    CGPoint positions[] = {ccp(951/2, 768 - 439/2), ccp(1459/2, 768 - 556/2), ccp(1110/2, 768 - 552/2), ccp(1423/2, 768 - 1304/2), ccp(1415/2, 768 - 947/2), ccp(706/2, 768 - 1348/2), ccp(311/2, 768 - 482/2), ccp(202/2, 768 - 1414/2)};
    int zOrders[] = {10, 50, 40, 50, 50, 60, 50, 70};
    for (int i = 0 ; i < 8; i++) {
        CCSprite* cloud = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"cloud%d_puzzle.png", i + 1]];
        cloud.position = positions[i];
        [skyNode addChild:cloud z:zOrders[i]];
        if (i == 2) {
            [cloud runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:5.f position:ccp(-50, 0)], [CCActionDelay actionWithDuration:0.1f], [CCActionMoveBy actionWithDuration:5.f position:ccp(50, 0)], [CCActionDelay actionWithDuration:0.1f], nil]]];
        }
        else if(i == 0 || i == 1 || i == 7){
            [cloud runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:4.f + i%2 * 0.5 position:ccp(50 + i%2 * 20, 0)], [CCActionDelay actionWithDuration:0.1f], [CCActionMoveBy actionWithDuration:4.f + i%2 * 0.5 position:ccp(-(50 + i%2 * 20), 0)], [CCActionDelay actionWithDuration:0.1f], nil]]];
        }
    }
    
    for (CCSprite* sprite in skyNode.children) {
        sprite.opacity = 0;
        [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], nil]];
    }
    
//    fish
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_dead_puzzle.png"];
    fishSprite.position = _fishSprite.position;
    fishSprite.opacity = 0;
    [skyNode addChild:fishSprite z:FISHORDER];
    
    [fishSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionCallBlock actionWithBlock:^{
//        bird
        [birdSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:birdAnimation]]];
        [birdSprite runAction:[CCActionSequence actions:[CCActionJumpTo actionWithDuration:5.f position:sunSprite.position height:50 jumps:1], [CCActionCallBlock actionWithBlock:^{
            [birdSprite stopAllActions];
            [birdSprite removeFromParent];
        }], nil]];
//        chaos
        CCSprite* chaosSprite = [CCSprite spriteWithImageNamed:@"chaos1_puzzle.png"];
        chaosSprite.position = [fishSprite convertToNodeSpace:ccp(110, 490)];
        [fishSprite addChild:chaosSprite];
        CCAnimation* chaosAnimation = [CCAnimation animationWithFile:@"chaos" withSuffix:@"_puzzle" frameCount:3 delay:0.15f];
        [chaosSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:chaosAnimation]]];
        [_fishSprite removeFromParent];
        _fishSprite = fishSprite;
//        remove
        [self removeEnvironmentNode:lastNode];
        _isLastLastDeleted = YES;
    }], nil]];
}

-(void)update:(CCTime)delta{
    if (_bubbleStart) {
        _createBubbleTime += delta;
        if (_createBubbleTime >= 10.f) {
            _createBubbleTime = 0.f;
            BubbleRise* bubbleRise = [BubbleRise node];
            CGFloat x = 100.0 + arc4random()%650;
            CGFloat y = 50.0 + arc4random()%50;
            int zOrder = 1 + arc4random()%5;
            bubbleRise.position = ccp(x, y);
            bubbleRise.numberOfBubbles = 4;
            bubbleRise.riseTime = (768 + bubbleRise.contentSize.height)/70.f;
            bubbleRise.randomNumberOfBubbles = YES;
            bubbleRise.imageName = @"bubble";
            bubbleRise.imageSuffixName = @"_puzzle";
            bubbleRise.numberOfImages = 4;
            bubbleRise.isDestroySelf = YES;
            [[_backgroundNode getChildByName:[NSString stringWithFormat:@"%@Node", _currentEnvironment] recursively:NO] addChild:bubbleRise z:zOrder];
        }
    }
}

-(void)createWaterEnvironment:(CCNode* )lastNode{
    _currentEnvironment = @"water";
    _bubbleStart = YES;
    
    CCNode* waterNode = [CCNode node];
    waterNode.contentSize = [[CCDirector sharedDirector] viewSize];
    waterNode.anchorPoint = ccp(0, 0);
    waterNode.position = ccp(0, 0);
    waterNode.name = @"waterNode";
    [_backgroundNode addChild:waterNode z:10];
    
//    bg
    CCSprite* waterBgSprite = [CCSprite spriteWithImageNamed:@"water_bg_puzzle.png"];
    waterBgSprite.anchorPoint = ccp(0, 0);
    waterBgSprite.position = ccp(0, 0);
    waterBgSprite.name = @"waterBg";
    [waterNode addChild:waterBgSprite z:1];
    
//    water plant
    CGPoint points[] = {ccp(277/2, 768 - 730/2 - 100), ccp(1257/2, 768 - 901/2), ccp(0, 0)};
    int zOrders[] = {3, 3, 4};
    NSArray* nameArray = @[@"plantLeft", @"plantRight", @"plantFront"];
    for (int i = 0; i < 3; i++) {
        CCSprite* waterPlant = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"water_plant%d_puzzle.png", i + 1]];
        waterPlant.anchorPoint = ccp(0, 0);
        if (i == 0) {
//            left
            waterPlant.position = ccp(points[i].x - waterPlant.contentSize.width/2, points[i].y - waterPlant.contentSize.height/2);
            waterPlant.scaleY = 1.3;
            [waterPlant runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRotateBy actionWithDuration:4.5f angle:-3], [CCActionDelay actionWithDuration:0.1f], [CCActionRotateBy actionWithDuration:4.5f angle:3], [CCActionDelay actionWithDuration:0.1], nil]]];
        }
        else if(i == 1){
            waterPlant.anchorPoint = ccp(1, 0);
            waterPlant.position = ccp(points[i].x + waterPlant.contentSize.width/2, points[i].y - waterPlant.contentSize.height/2);
            [waterPlant runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRotateBy actionWithDuration:3.5f angle:3], [CCActionDelay actionWithDuration:0.1f], [CCActionRotateBy actionWithDuration:3.5f angle:-3], [CCActionDelay actionWithDuration:0.1], nil]]];
        }
        else{
            waterPlant.position = points[i];
        }
        waterPlant.name = nameArray[i];
        [waterNode addChild:waterPlant z:zOrders[i]];
    }
    
//    tadpole
    CCSprite* tadpoleOne = [CCSprite spriteWithImageNamed:@"tadpole1_puzzle.png"];
    tadpoleOne.position = ccp(1024, 666);
    [waterNode addChild:tadpoleOne z:2];
    
    CCSprite* tadpoleTwo = [CCSprite spriteWithImageNamed:@"tadpole2_puzzle.png"];
    tadpoleTwo.position = ccp(1024, 666);
    [waterNode addChild:tadpoleTwo z:2];
    
    [tadpoleTwo runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:15.f position:ccp(-tadpoleTwo.contentSize.width, tadpoleTwo.position.y)], [CCActionCallBlock actionWithBlock:^{
        [tadpoleTwo removeFromParent];
    }], nil]];
    
    [tadpoleOne runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:3.f], [CCActionMoveTo actionWithDuration:10.f position:ccp(-tadpoleOne.contentSize.width, tadpoleOne.position.y)], [CCActionCallBlock actionWithBlock:^{
        [tadpoleOne removeFromParent];
    }], nil]];
    
//    bubbles
    BubbleRise* bubbleRise = [BubbleRise node];
    bubbleRise.name = @"fishBubble";
    bubbleRise.position = ccp(70, 768 - 809/2);
    bubbleRise.numberOfBubbles = 5;
    bubbleRise.randomNumberOfBubbles = YES;
    bubbleRise.imageName = @"bubble";
    bubbleRise.imageSuffixName = @"_puzzle";
    bubbleRise.numberOfImages = 4;
    bubbleRise.isDestroySelf = NO;
    [waterNode addChild:bubbleRise z:5];
    
    for (CCSprite* sprite in waterNode.children) {
        sprite.opacity = 0;
        [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], nil]];
    }
    
//    fish
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_well1_puzzle.png"];
    fishSprite.position = _fishSprite.position;
    fishSprite.opacity = 0;
    [waterNode addChild:fishSprite z:FISHORDER];
    
    CCAnimation* fishAnimation = [CCAnimation animationWithFile:@"carp_well" withSuffix:@"_puzzle" frameCount:4 delay:0.15];
    [fishSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionCallBlock actionWithBlock:^{
        [_fishSprite removeFromParent];
        [fishSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:fishAnimation]]];
        _fishSprite = fishSprite;
        self.step = 2;
////        go next
//        _goSprite = [TouchSprite spriteWithImageNamed:@"next.png"];
//        _goSprite.position = ccp(750, 768 - 1379/2 + 20);
//        _goSprite.opacity = 0;
//        _goSprite.userInteractionEnabled = YES;
//        [waterNode addChild:_goSprite z:FISHORDER];
//        [_goSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionDelay actionWithDuration:2.f], [CCActionCallBlock actionWithBlock:^{
//            [_goSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.2f scale:1.2f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.2f scale:0.9f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.1f scale:1.05f], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.1f scale:1.f], [CCActionDelay actionWithDuration:0.8f], nil]]];
//        }], nil]];
//        __unsafe_unretained LiveEnvironmentScene* weakSelf = self;
//        _goSprite.touchBegan = ^(UITouch* touch){
//            [weakSelf goTransition];
//        };
//        remove
        [self removeEnvironmentNode:lastNode];
        _isLastLastDeleted = YES;
    }], nil]];
}

-(void)createGrassEnvironment:(CCNode* )lastNode{
    self.step = 1;
    _currentEnvironment = @"grass";
    _bubbleStart = NO;
    
    CCNode* grassNode = [CCNode node];
    grassNode.contentSize = [[CCDirector sharedDirector] viewSize];
    grassNode.anchorPoint = ccp(0, 0);
    grassNode.position = ccp(0, 0);
    grassNode.name = @"grassNode";
    [_backgroundNode addChild:grassNode z:10];
    
//    bg
    CCSprite* grassBgSprite = [CCSprite spriteWithImageNamed:@"grass_bg_puzzle.png"];
    grassBgSprite.position = ccp(819.5/2, 768 - 757.5/2);
    [grassNode addChild:grassBgSprite z:1];
    
//    windmill
    CCSprite* windmillSprite = [CCSprite spriteWithImageNamed:@"windmill_puzzle.png"];
    windmillSprite.anchorPoint = ccp((405.5/2 - (409/2 - windmillSprite.contentSize.width/2))/windmillSprite.contentSize.width, (768 - 283.5/2 - (768 - 276/2 - windmillSprite.contentSize.height/2))/windmillSprite.contentSize.height);
    windmillSprite.position = ccp(405.5/2, 768 - 283.5/2);
    [grassNode addChild:windmillSprite z:2];
    
//    sheep
    CCSprite* sheepOne = [CCSprite spriteWithImageNamed:@"sheep1_puzzle.png"];
    sheepOne.position = ccp(1154/2, 768 - 500/2);
    [grassNode addChild:sheepOne z:2];
    
    CCSprite* sheepTwo = [CCSprite spriteWithImageNamed:@"sheep2_puzzle.png"];
    sheepTwo.position = ccp(1412/2, 768 - 691/2);
    [grassNode addChild:sheepTwo z:2];
    
    for (CCSprite* sprite in grassNode.children) {
        sprite.opacity = 0;
        [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], nil]];
    }
    
//    fish
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_dead_puzzle.png"];
    fishSprite.position = _fishSprite.position;
    fishSprite.opacity = 0;
    [grassNode addChild:fishSprite z:FISHORDER];
    
    [fishSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionCallBlock actionWithBlock:^{
//        actions
        [windmillSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:10.f angle:360]]];
        [sheepOne runAction:[CCActionSequence actions:[CCActionRotateBy actionWithDuration:0.8f angle:-50], nil]];
        [sheepTwo runAction:[CCActionSequence actions:[CCActionRotateBy actionWithDuration:1.2f angle:40], nil]];
//        chaos
        CCSprite* chaosSprite = [CCSprite spriteWithImageNamed:@"chaos1_puzzle.png"];
        chaosSprite.position = [fishSprite convertToNodeSpace:ccp(110, 490)];
        [fishSprite addChild:chaosSprite];
        CCAnimation* chaosAnimation = [CCAnimation animationWithFile:@"chaos" withSuffix:@"_puzzle" frameCount:3 delay:0.15f];
        [chaosSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:chaosAnimation]]];
        [_fishSprite removeFromParent];
        _fishSprite = fishSprite;
//        remove
        [self removeEnvironmentNode:lastNode];
        _isLastLastDeleted = YES;
    }], nil]];
    
}

-(void)createSandEnvironment:(CCNode* )lastNode{
    self.step = 1;
    _currentEnvironment = @"sand";
    _bubbleStart = NO;
    
    CCNode* sandNode = [CCNode node];
    sandNode.contentSize = [[CCDirector sharedDirector] viewSize];
    sandNode.anchorPoint = ccp(0, 0);
    sandNode.position = ccp(0, 0);
    sandNode.name = @"sandNode";
    [_backgroundNode addChild:sandNode z:10];
    
//    bg
    CCSprite* sandBgSprite = [CCSprite spriteWithImageNamed:@"sand_bg_puzzle.png"];
    sandBgSprite.position = ccp(819.5/2, 768 - 757.5/2);
    [sandNode addChild:sandBgSprite z:1];
    
//    sand
    CCSprite* sandBack = [CCSprite spriteWithImageNamed:@"sand1_puzzle.png"];
    sandBack.position = ccp(810/2, 768 - 980/2);
    [sandNode addChild:sandBack z:3];
    
    CCSprite* sandFront = [CCSprite spriteWithImageNamed:@"sand2_puzzle.png"];
    sandFront.position = ccp(819.5/2, 768 - 1019.5/2);
    [sandNode addChild:sandFront z:5];
    
//    plants
    CGPoint points[] = {ccp(209/2, 768 - 1215/2 - 50), ccp(1502/2, 768 - 497/2), ccp(454/2, 768 - 450/2)};
    int zOrders[] = {6, 4, 2};
    for (int i = 0; i < 3; i++) {
        CCSprite* plant = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"sand_plant%d_puzzle.png", i + 1]];
        plant.anchorPoint = ccp(0.5, 0);
        plant.position = ccp(points[i].x, points[i].y - plant.contentSize.height/2);
        plant.name = [NSString stringWithFormat:@"plant%d", i + 1];
        [sandNode addChild:plant z:zOrders[i]];
    }
    
    for (CCSprite* sprite in sandNode.children) {
        sprite.opacity = 0;
        [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], nil]];
    }
    
//    fish
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_dead_puzzle.png"];
    fishSprite.position = _fishSprite.position;
    fishSprite.opacity = 0;
    [sandNode addChild:fishSprite z:FISHORDER];
    
    [fishSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionCallBlock actionWithBlock:^{
//        🌵
        for (int i = 0; i < 3; i++) {
            CCSprite* plant = (CCSprite* )[sandNode getChildByName:[NSString stringWithFormat:@"plant%d", i + 1] recursively:NO];
            [plant runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.5f scaleX:1 scaleY:1.01f], [CCActionDelay actionWithDuration:0], [CCActionScaleTo actionWithDuration:0.5f scaleX:1 scaleY:0.98f], [CCActionDelay actionWithDuration:0], nil]]];
        }
//        chaos
        CCSprite* chaosSprite = [CCSprite spriteWithImageNamed:@"chaos1_puzzle.png"];
        chaosSprite.position = [fishSprite convertToNodeSpace:ccp(110, 490)];
        [fishSprite addChild:chaosSprite];
        CCAnimation* chaosAnimation = [CCAnimation animationWithFile:@"chaos" withSuffix:@"_puzzle" frameCount:3 delay:0.15f];
        [chaosSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:chaosAnimation]]];
        [_fishSprite removeFromParent];
        _fishSprite = fishSprite;
//        remove
        [self removeEnvironmentNode:lastNode];
        _isLastLastDeleted = YES;
    }], nil]];
}

-(void)pausePreviousEnvironment:(CCNode* )lastNode{
    lastNode.paused = YES;
    _fishSprite.paused = YES;
}

-(void)removeEnvironmentNode:(CCNode* )lastNode{
    [lastNode removeAllChildren];
    [lastNode removeFromParent];
}

-(void)goTransition{
    self.userInteractionEnabled = NO;
//    _goSprite.userInteractionEnabled = NO;
//    [_goSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0], [CCActionCallBlock actionWithBlock:^{
//        [_goSprite removeFromParent];
//    }], nil]];
    
    CCSprite* liveBoard = (CCSprite* )[_backgroundNode getChildByName:@"liveBoard" recursively:NO];
    for (CCSprite* sprite in liveBoard.children) {
        [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:2.f opacity:0], nil]];
    }
    [liveBoard runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:2.f opacity:0], [CCActionCallBlock actionWithBlock:^{
        [liveBoard removeAllChildren];
        [liveBoard removeFromParent];
        [self goRight];
    }], nil]];
}

-(void)goRight{
    _isGoingRight = YES;
    self.userInteractionEnabled = YES;
    CCNode* waterNode = [_backgroundNode getChildByName:@"waterNode" recursively:NO];
    
//    left water
    CCSprite* leftWaterBg = [CCSprite spriteWithImageNamed:@"water_left_puzzle.png"];
    leftWaterBg.name = @"leftWaterBg";
    leftWaterBg.anchorPoint = ccp(0, 0);
    leftWaterBg.position = ccp(-1024, 0);
    [waterNode addChild:leftWaterBg z:1];
    
//    leaf
    CCSprite* leafSprite = [CCSprite spriteWithImageNamed:@"water_leaf_puzzle.png"];
    leafSprite.name = @"leftLeaf";
    leafSprite.anchorPoint = ccp(0, 0);
    leafSprite.position = ccp(-350, 0);
    [waterNode addChild:leafSprite z:6];
    
//    move sprite
    _fishSprite.zOrder = 5;
    CCSprite* rightWaterBg = (CCSprite* )[waterNode getChildByName:@"waterBg" recursively:NO];
    CCSprite* midBgOne = (CCSprite* )[waterNode getChildByName:@"plantLeft" recursively:NO];
    CCSprite* midBgTwo = (CCSprite* )[waterNode getChildByName:@"plantRight" recursively:NO];
    CCSprite* frontBg = (CCSprite* )[waterNode getChildByName:@"plantFront" recursively:NO];
    
    BubbleRise* bubble = (BubbleRise* )[waterNode getChildByName:@"fishBubble" recursively:NO];
    bubble.isDestroySelf = YES;

//    action
    CGPoint points[] = {ccp(0, 0), ccp(1024, 0), ccp(midBgOne.position.x + 1024, midBgOne.position.y), ccp(midBgTwo.position.x + 1024, midBgTwo.position.y), ccp(1024, 0), ccp(1024 - leafSprite.position.x + 1024 + leafSprite.contentSize.width, leafSprite.position.y)};
    CGFloat durations[] = {9.f, 9.f, 9.f, 9.f, 8.f, 6.f};
    NSArray* moveSprites = @[leftWaterBg, rightWaterBg, midBgOne, midBgTwo, frontBg, leafSprite];
    for (int i = 0; i < moveSprites.count; i++) {
        [moveSprites[i] runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:durations[i] position:points[i]], [CCActionCallBlock actionWithBlock:^{
            if (i == 0) {
                [moveSprites[i] removeFromParent];
                [_backgroundNode addChild:moveSprites[i] z:1];
                [_fishSprite stopAllActions];
                [_fishSprite removeFromParent];
                [_backgroundNode addChild:_fishSprite z:FISHORDER];
                self.userInteractionEnabled = NO;
                [self showBoard];
            }
            else{
//                [moveSprites[i] removeFromParent];
            }
        }], nil]];
    }
    [_fishSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:10.f position:ccp(1047/2, 768 - 915.5/2)], nil]];
}

-(void)showBoard{
    _bubbleStart = NO;
    BoardSprite* boardSprite = [BoardSprite spriteWithTitleImageString:@"title2_puzzle.png" andGoNextImageString:@"next.png"];
    boardSprite.name = @"popBoard";
    boardSprite.afterGoDownBlock = ^(){
        [[CCDirector sharedDirector] replaceScene:[ObserveGillScene scene]];
    };
    [_backgroundNode addChild:boardSprite z:LIVEBOARDORDER];
    self.step = 3;
    self.nextButton.enabled = YES;
    self.nextButton.visible = YES;
}









-(void)onExit{
    [_backgroundNode removeAllChildren];
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}



@end
