//
//  SecondObserveScene.m
//  DDT-Carp
//
//  Created by Z on 14/12/23.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "SecondObserveScene.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "TouchSprite.h"
#import "ActionProvider.h"
#import "CCTextureCache.h"
#import "SparkNode.h"
#import "Fireworks.h"
#import "CCAnimation+Helper.h"

#import "SubmarineScene.h"
#import "ContentScene.h"
#import "FishLivingEnvironmentScene.h"

#define FISHORDER 100
#define WORLDORDER 1000

@interface SecondObserveScene ()
{
    CCNode* _backgroundNode;
    NSMutableArray* _spriteCount;
    NSMutableArray* _observedNames;
    NSMutableArray* _observedPositions;
    NSMutableArray* _removeSprites;
    TouchSprite* _observerSprite;
    
//    observed
    NSMutableArray* _observedSpriteArray;
    
//    observe control
    BOOL _isShowAnimation;
    
//    fin
    CCSprite* _boardSprite;
    CCClippingNode* _finClippingNode;
    int _puzzleCount;
}
@end

@implementation SecondObserveScene
+(SecondObserveScene *)scene{
    return [[self alloc] init];
}

+(SecondObserveScene *)sceneForScale{
    return [[self alloc] initForScale:@"scale"];
}

-(id)initForScale:(NSString* )scale{
    self = [super init];
    if (self) {
        _isShowAnimation = NO;
        
        if (scale == nil) {
            _observedNames = [NSMutableArray arrayWithObjects:@"fin", @"scale", nil];
            _observedPositions = [NSMutableArray arrayWithObjects:[NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(649.5/2.f, 768 - 1241/2.f)], [NSValue valueWithCGPoint:ccp(1066.f/2.f, 768 - 1264/2.f)], nil], [NSValue valueWithCGPoint:ccp(1023.5/2.f, 768 - 969/2.f)], nil];
            _spriteCount = [NSMutableArray arrayWithObjects:@"2", @"1", nil];
        }
        else{
            self.step = 3;
            self.nextButton.visible = NO;
            self.nextButton.enabled = NO;
            _observedNames = [NSMutableArray arrayWithObjects:@"scale", nil];
            _observedPositions = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(1023.5/2.f, 768 - 969/2.f)], nil];
            _spriteCount = [NSMutableArray arrayWithObjects:@"1", nil];
        }
        
        _observedSpriteArray = [[NSMutableArray alloc] init];
        _removeSprites = [[NSMutableArray alloc] init];
        _puzzleCount = 0;
    }
    return self;
}

- (instancetype)init
{
    return [self initForScale:nil];
}

-(void)onEnter{
    [super onEnter];
    [self createBackgroud];
}

-(void)prevPress:(CCButton *)button{
    if(self.step == 1){
        [[CCDirector sharedDirector] replaceScene:[SubmarineScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    else if(self.step == 3){
        [[CCDirector sharedDirector] replaceScene:[SecondObserveScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    [self handleButtons:NO];
}

-(void)nextPress:(CCButton *)button{
    if (self.step == 1) {
        [[CCDirector sharedDirector] replaceScene:[SecondObserveScene sceneForScale] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    else if(self.step == 2){
        [self finGoOver:nil];
    }
    else if(self.step == 3){

    }
    else{
        [self scaleGoOver:nil];
    }
    [self handleButtons:NO];
}

-(void)createBackgroud{
//    init
    _backgroundNode = [CCNode node];
    _backgroundNode.contentSize = [[CCDirector sharedDirector] viewSize];
    _backgroundNode.anchorPoint = ccp(0, 0);
    _backgroundNode.position = ccp(0, 0);
    [self addChild:_backgroundNode z:1];
    
//    home
//    TouchSprite* homeSprite = [TouchSprite spriteWithImageNamed:@"home.png"];
//    homeSprite.position = ccp(161/2, 768 - 142/2);
//    [_backgroundNode addChild:homeSprite z:2000];
//    homeSprite.userInteractionEnabled = YES;
//    homeSprite.name = @"home";
//    __unsafe_unretained TouchSprite* homeSpriteTemp = homeSprite;
//    homeSprite.touchBegan = ^(UITouch* touch){
//        homeSpriteTemp.userInteractionEnabled = NO;
//        [homeSpriteTemp runAction:[ActionProvider getPressBeginAction]];
//        [[CCDirector sharedDirector] replaceScene:[ContentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
//    };
    
//    bg
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_observe.png"];
    bgSprite.anchorPoint = ccp(0, 0);
    bgSprite.position = ccp(0, 0);
    [_backgroundNode addChild:bgSprite z:1];
    
//    fish
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_observe.png"];
    fishSprite.name = @"carp";
    fishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [_backgroundNode addChild:fishSprite z:FISHORDER];
    
//    gill
    CCSprite* gillSprite = [CCSprite spriteWithImageNamed:@"gill_observe.png"];
    gillSprite.position = ccp(491.5/2, 768 - 989.5/2);
    [_backgroundNode addChild:gillSprite z:FISHORDER];
    
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
//    __unsafe_unretained SecondObserveScene* weakSelf = self;
    
//    actions
//    [boardSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionMoveBy actionWithDuration:0.5f position:ccp(-boardSprite.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
//        [_observerSprite removeFromParent];
//        _observerSprite.position = ccp(1798.5/2, 768 - 1354.5/2);
//        [_backgroundNode addChild:_observerSprite z:1000];
//        _observerSprite.touchBegan = ^(UITouch* touch){
//            [weakSelf observerTouchBegan:touch];
//        };
//        
//        _observerSprite.touchMoved = ^(UITouch* touch){
//            [weakSelf observerTouchMoved:touch];
//        };
//        
//        _observerSprite.touchEnded = ^(UITouch* touch){
//            [weakSelf observerTouchEnded:touch];
//        };
//        
//        _observerSprite.touchCanceled = ^(UITouch* touch){
//            [weakSelf observerTouchCanceled:touch];
//        };
//        [self runObserverPrompt];
//    }], nil]];
    [self createObservedSprite];
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
    
    __unsafe_unretained SecondObserveScene* weakSelf = self;
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
    
    int count = [_spriteCount.firstObject intValue];
    for (int i = 0; i < count; i++) {
        CCSprite* observedSprite = [CCSprite spriteWithImageNamed:count == 1 ? [NSString stringWithFormat:@"%@_observe.png", _observedNames.firstObject] : [NSString stringWithFormat:@"%@%d_observe.png", _observedNames.firstObject, i + 1]];
        observedSprite.opacity = 0;
        observedSprite.name = count == 1 ? _observedNames.firstObject : [NSString stringWithFormat:@"%@%d", _observedNames.firstObject, i + 1];
        observedSprite.position = count == 1 ? [_observedPositions.firstObject CGPointValue] : [_observedPositions.firstObject[i] CGPointValue];
        [_backgroundNode addChild:observedSprite z:FISHORDER + 2];
        [_observedSpriteArray addObject:observedSprite];
        [observedSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionDelay actionWithDuration:3.f], [CCActionCallBlock actionWithBlock:^{
            [observedSprite runAction:[ActionProvider getRepeatBlinkPrompt]];
        }], nil]];
//        if (i == count - 1) {
//            
//        }
    }
}

-(void)runObserverPrompt{
    [_observerSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.2f], [CCActionCallBlock actionWithBlock:^{
        [_observerSprite runAction:[ActionProvider getRepeatShakePrompt]];
    }], nil]];
}

-(void)observerTouchBegan:(UITouch* )touch{
    [_observerSprite stopAllActions];
    _observerSprite.userInteractionEnabled = NO;
    _observerSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"magnifier_real_observe.png"];
    _observerSprite.rotation = 0.f;
    _observerSprite.position = [touch locationInNode:_backgroundNode];
    __unsafe_unretained SecondObserveScene* weakSelf = self;
    _observerSprite.touchMoved = ^(UITouch* touch){
        [weakSelf observerTouchMoved:touch];
    };
}

-(void)observerTouchMoved:(UITouch* )touch{
    CGPoint center = CGPointZero;
    NSString* name = nil;
    if (_observedSpriteArray.count == 2) {
        center = ccpMidpoint([(CCSprite* )_observedSpriteArray.firstObject position], [(CCSprite* )_observedSpriteArray.lastObject position]);
        name = [[(CCSprite* )_observedSpriteArray.firstObject name] substringToIndex:[(CCSprite* )_observedSpriteArray.firstObject name].length - 1];
    }
    else{
        center = [(CCSprite* )_observedSpriteArray.firstObject position];
        name = [(CCSprite* )_observedSpriteArray.firstObject name];
    }
    CGRect rect = CGRectMake(center.x - 150, center.y - 150, 300, 300);
    if (CGRectContainsPoint(rect, _observerSprite.position)) {
//        watching
        for (CCSprite* observedSprite in _observedSpriteArray) {
            [observedSprite stopAllActions];
            observedSprite.visible = YES;
        }
        _observerSprite.userInteractionEnabled = NO;
        _observerSprite.zOrder = FISHORDER + 3;
        [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"observe%@",name.capitalizedString]) withObject:nil afterDelay:0.f];
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
    CGPoint center = CGPointZero;
    NSString* name = nil;
    if (_observedSpriteArray.count == 2) {
        center = ccpMidpoint([(CCSprite* )_observedSpriteArray.firstObject position], [(CCSprite* )_observedSpriteArray.lastObject position]);
//        NSLog(@"%@", NSStringFromCGPoint(center));
        name = [[(CCSprite* )_observedSpriteArray.firstObject name] substringToIndex:[(CCSprite* )_observedSpriteArray.firstObject name].length - 1];
    }
    else{
        center = [(CCSprite* )_observedSpriteArray.firstObject position];
        name = [(CCSprite* )_observedSpriteArray.firstObject name];
    }
    CGRect rect = CGRectMake(center.x - 150, center.y - 150, 300, 300);
    if (CGRectContainsPoint(rect, _observerSprite.position)) {
//        watching
        for (CCSprite* observedSprite in _observedSpriteArray) {
            [observedSprite stopAllActions];
            observedSprite.visible = YES;
        }
        _observerSprite.zOrder = FISHORDER + 3;
        [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"observe%@", name.capitalizedString]) withObject:nil afterDelay:0.f];
        [_observerSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.1f position:ccp(center.x + 150/4, center.y - 150/4)], nil]];
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
    }], [CCActionDelay actionWithDuration:1.f], [CCActionCallBlock actionWithBlock:^{
        if (_observedNames.count == 0) {
            [self goOver];
        }
    }], nil]];
}

#pragma mark - fin observe
-(void)observeFin{
    if(_isShowAnimation){
        return;
    }
    _isShowAnimation = YES;
    [self handleButtons:NO];
    self.homeButton.enabled = NO;
    
//    fin bg
    CCSprite* finBgSprite = [CCSprite spriteWithImageNamed:@"fin_bg_observe.png"];
    finBgSprite.name = @"fin_bg";
    finBgSprite.position = ccp(429, 142);
    [_backgroundNode addChild:finBgSprite z:FISHORDER + 1];
    
//   show board
    _boardSprite = [CCSprite spriteWithImageNamed:@"board_fin_observe.png"];
    _boardSprite.position = ccp(1024 + _boardSprite.contentSize.width/2, 768 - _boardSprite.contentSize.height/2 - 20);
    [_backgroundNode addChild:_boardSprite z:FISHORDER + 4];
    
    __unsafe_unretained SecondObserveScene* weakSelf = self;
    [_boardSprite runAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:1.f position:ccp(-_boardSprite.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
        [weakSelf createFinSprites];
    }], nil]];
}

-(void)createFinSprites{
//    tag
    CGPoint positions[] = {ccp(534/2.f, 768 - 242.5/2.f), ccp(534/2.f, 768 - 523.5/2.f)};
    NSArray* iconName = @[@"quant_fin_observe.png", @"dudu_fin_observe.png"];
    CGPoint iconPositions[] = {ccp(484/2.f, 768 - 242.5/2.f), ccp(478/2.f, 768 - 532.5/2.f)};
    NSMutableArray* rightRects = [[NSMutableArray alloc] initWithObjects:
                                          [NSMutableArray arrayWithObjects:
                                           [NSValue valueWithCGRect:(CGRect){1270.5/2.f - 155.5/2.f, 768 - 667/2.f - 107, 155.5, 214}],
                                           [NSValue valueWithCGRect:(CGRect){1534.5/2.f - 155.5/2.f, 768 - 672/2.f - 107, 155.5, 214}],
                                           nil],
                                          [NSMutableArray arrayWithObjects:
                                           [NSValue valueWithCGRect:(CGRect){1313/2.f - 80, 768 - 538/2.f - 82, 160, 164}],
                                           [NSValue valueWithCGRect:(CGRect){1577/2.f - 80, 768 - 543/2.f - 82, 160, 164}],
                                           nil],
                                          nil];
    __block NSMutableArray* rightRectsTemp = rightRects;
    
    for (int i = 0; i < 2; i++) {
        CCSprite* tagSprite = [CCSprite spriteWithImageNamed:@"tag_fin_observe.png"];
        tagSprite.position = positions[i];
        tagSprite.name = [NSString stringWithFormat:@"tag%d", i + 1];
        [_backgroundNode addChild:tagSprite z:FISHORDER + 3];
        
        TouchSprite* iconSprite = [TouchSprite spriteWithImageNamed:iconName[i]];
        iconSprite.position = [tagSprite convertToNodeSpace:iconPositions[i]];
        iconSprite.name = [iconName[i] componentsSeparatedByString:@"_"].firstObject;
        [tagSprite addChild:iconSprite z:1];
        iconSprite.userInteractionEnabled = NO;
        
        __block TouchSprite* iconSpriteBlock = iconSprite;
        __unsafe_unretained TouchSprite* iconSpriteTemp = iconSprite;
        __unsafe_unretained CCNode* backgroundNodeTemp = _backgroundNode;
        __unsafe_unretained SecondObserveScene* weakSelf = self;
        __block CGPoint iconPointTemp = iconPositions[i];
        tagSprite.position = ccpAdd(positions[i], ccp(tagSprite.contentSize.width, 0));
        [tagSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f position:positions[i]], [CCActionCallBlock actionWithBlock:^{
            [iconSpriteBlock removeFromParent];
            iconSpriteBlock.position = iconPointTemp;
            iconSpriteBlock.userInteractionEnabled = YES;
            [backgroundNodeTemp addChild:iconSpriteBlock z:FISHORDER + 10];
        }], nil]];
        
        iconSprite.touchBegan = ^(UITouch* touch){
            [weakSelf iconTouchBeganBlock:touch sender:iconSpriteTemp];
        };
        
        iconSprite.touchMoved = ^(UITouch* touch){
            [weakSelf iconTouchMovedBlock:touch sender:iconSpriteTemp];
        };
        
        iconSprite.touchEnded = ^(UITouch* touch){
            [weakSelf iconTouchEndedBlock:touch sender:iconSpriteTemp andRectArray:rightRectsTemp];
        };
        
        iconSprite.touchCanceled = ^(UITouch* touch){
            [weakSelf iconTouchCanceledBlock:touch sender:iconSpriteTemp];
        };
    }
    
//    clipping node
    CCSprite* stencilSprite = [CCSprite spriteWithImageNamed:@"clip_fin_observe.png"];
    stencilSprite.anchorPoint = ccp(0.5, 0.5);
    stencilSprite.position = ccp(1024 - stencilSprite.contentSize.width/2, 768 - 503.5/2.f - 20);
    _finClippingNode = [CCClippingNode clippingNodeWithStencil:stencilSprite];
    _finClippingNode.contentSize = self.contentSize;
    _finClippingNode.alphaThreshold = 0.f;
    [_backgroundNode addChild:_finClippingNode z:FISHORDER + 5];
    
//    water
    CCSprite* waterSprite = [CCSprite spriteWithImageNamed:@"water1_fin_observe.png"];
    waterSprite.position = ccp(1360/2.f, 768 - 812/2.f - waterSprite.contentSize.height);
    waterSprite.name = @"water";
    [_finClippingNode addChild:waterSprite];

//    __block CCSprite* waterSpriteTemp = waterSprite;
//    __unsafe_unretained CCSprite* boardSpriteTemp = _boardSprite;
    [waterSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:1.f position:ccp(1360/2.f, 768 - 812/2.f)], [CCActionCallBlock actionWithBlock:^{
//        [waterSpriteTemp removeFromParent];
//        [boardSpriteTemp addChild:waterSpriteTemp z:1];
//        waterSpriteTemp.position = [boardSpriteTemp convertToNodeSpace:waterSpriteTemp.position];
    }], nil]];
    
//    ship
    CCSprite* shipSprite = [CCSprite spriteWithImageNamed:@"ship_fin_observe.png"];
    shipSprite.position = ccp(1024 + shipSprite.contentSize.width/2, 768 - 459.5/2.f);
    shipSprite.name = @"ship";
    [_backgroundNode addChild:shipSprite z:FISHORDER + 6];
    
    [shipSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionMoveTo actionWithDuration:1.f position:ccp(1423/2.f, 768 - 459.5/2.f)], [CCActionCallBlock actionWithBlock:^{
        
    }], nil]];
    
//    dark dudu
    CGPoint duduPositions[] = {ccp(1313/2.f, 768 - 538/2.f), ccp(1577/2.f, 768 - 543/2.f)};
    CGPoint handPositions[] = {ccp(1275/2.f, 768 - 588.5/2.f), ccp(1539/2.f, 768 - 593.5/2.f)};
    CGPoint quantPositions[] = {ccp(1270.5/2.f, 768 - 667/2.f), ccp(1534.5/2.f, 768 - 672/2.f)};
    for (int i = 0; i < 2; i++) {
        CCSprite* darkDuduSprite = [CCSprite spriteWithImageNamed:@"dudu_dark_fin_observe.png"];
        darkDuduSprite.position = duduPositions[i];
        darkDuduSprite.opacity = 0.f;
        [_backgroundNode addChild:darkDuduSprite z:FISHORDER + 5];
        
        CCSprite* quantSprite = [CCSprite spriteWithImageNamed:@"quant_dark_fin_observe.png"];
        quantSprite.position = quantPositions[i];
        quantSprite.opacity = 0.f;
        [_backgroundNode addChild:quantSprite z:FISHORDER + 7];
        
        CCSprite* handSprite = [CCSprite spriteWithImageNamed:@"hand_dark_fin_observe.png"];
        handSprite.position = handPositions[i];
        handSprite.opacity = 0.f;
        [_backgroundNode addChild:handSprite z:FISHORDER + 8];
        
        [darkDuduSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
        [quantSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
        [handSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
        [_removeSprites addObject:darkDuduSprite];
        [_removeSprites addObject:quantSprite];
        [_removeSprites addObject:handSprite];
    }
    
//    clouds
    CGPoint cloudPositions[] = {ccp(500, 650), ccp(900, 660), ccp(800, 680)};
    for (int i = 0; i < 3; i++) {
        CCSprite* cloudSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"cloud%d_fin_observe.png", i + 1]];
        cloudSprite.position = cloudPositions[i];//[_boardSprite convertToNodeSpace:cloudPositions[i]];
        cloudSprite.opacity = 0.f;
        [_finClippingNode addChild:cloudSprite z:3 - i];
        __block CCSprite* cloudSpriteTemp = cloudSprite;
        [cloudSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
            [cloudSpriteTemp runAction:[ActionProvider getRepeatSlowMove:5.f + i andDistance:30.f + i * 5.f]];
        }], nil]];
    }
}

-(void)iconTouchBeganBlock:(UITouch* )touch sender:(TouchSprite* )iconSprite{
    iconSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@_real_fin_observe.png", iconSprite.name]];
    iconSprite.position = [touch locationInNode:_backgroundNode];
    iconSprite.zOrder = FISHORDER + 11;
    if([iconSprite.name isEqualToString:@"dudu"]){
        CCSprite* handSprite = [CCSprite spriteWithImageNamed:@"hand_real_fin_observe.png"];
        handSprite.position = ccpSub(ccp(1275/2.f, 768 - 588.5/2.f), ccp(1313/2.f - iconSprite.contentSize.width/2.f, 768 - 538/2.f - iconSprite.contentSize.height/2.f));
        [iconSprite addChild:handSprite];
    }
}

-(void)iconTouchMovedBlock:(UITouch* )touch sender:(TouchSprite* )iconSprite{
    CGPoint touchPoint = [touch locationInNode:_backgroundNode];
    iconSprite.position = touchPoint;
}

-(void)iconTouchEndedBlock:(UITouch* )touch sender:(TouchSprite* )iconSprite andRectArray:(NSMutableArray* )rectArray{
    iconSprite.userInteractionEnabled = NO;
    NSMutableArray* rects = nil;
    if([iconSprite.name isEqualToString:@"quant"]){
        rects = rectArray[0];
    }
    else{
        rects = rectArray[1];
    }
    [self duduGoRightPosition:rects andIconSprite:iconSprite];
}

-(void)duduGoRightPosition:(NSMutableArray* )rects andIconSprite:(TouchSprite* )iconSprite{
    int index = 0;
    for (index = 0; index < rects.count; index++) {
        if (CGRectContainsPoint([rects[index] CGRectValue], iconSprite.position)) {
            break;
        }
    }
    if (index == rects.count) {
        [self iconGoback:iconSprite];
    }
    else{
        [self iconLand:iconSprite andPosition:ccpAdd([rects[index] CGRectValue].origin, ccp(iconSprite.contentSize.width/2, iconSprite.contentSize.height/2)) withOriginalPosition:[iconSprite.name isEqualToString:@"dudu"] ? ccp(478/2.f, 768 - 532.5/2.f) : ccp(484/2.f, 768 - 242.5/2.f) andIsBack:rects.count == 1 ? NO : YES];
        [rects removeObjectAtIndex:index];
    }
}

-(void)iconLand:(TouchSprite* )iconSprite andPosition:(CGPoint)position withOriginalPosition:(CGPoint)originalPosition andIsBack:(BOOL)isBack{
    _puzzleCount++;
    __unsafe_unretained TouchSprite* iconSpriteTemp = iconSprite;
    __unsafe_unretained CCNode* backgroundTemp = _backgroundNode;
    __unsafe_unretained NSMutableArray* removeSpritesTemp = _removeSprites;
    [iconSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.1f position:position], [CCActionCallBlock actionWithBlock:^{
        iconSpriteTemp.zOrder = FISHORDER + 5;
        CCSprite* puzzle = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@_real_fin_observe.png", iconSpriteTemp.name]];
        puzzle.position = position;
        puzzle.name = [NSString stringWithFormat:@"puzzle%d", _puzzleCount];
        [backgroundTemp addChild:puzzle z:FISHORDER + 5];
        if([iconSpriteTemp.name isEqualToString:@"dudu"]){
            CCSprite* handSprite = [CCSprite spriteWithImageNamed:@"hand_real_fin_observe.png"];
            handSprite.position = [puzzle convertToWorldSpace:ccpSub(ccp(1275/2.f, 768 - 588.5/2.f), ccp(1313/2.f - puzzle.contentSize.width/2.f, 768 - 538/2.f - puzzle.contentSize.height/2.f))];
            [backgroundTemp addChild:handSprite z:FISHORDER + 8];
            [removeSpritesTemp addObject:handSprite];
        }
        else{
            puzzle.zOrder = FISHORDER + 7;
        }
        [removeSpritesTemp addObject:puzzle];
        iconSpriteTemp.opacity = 0;
        [iconSpriteTemp removeAllChildren];
        if (isBack) {
            iconSpriteTemp.zOrder = FISHORDER + 10;
            iconSpriteTemp.position = originalPosition;
            iconSpriteTemp.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@_fin_observe.png", iconSpriteTemp.name]];
            [iconSpriteTemp runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
                iconSpriteTemp.userInteractionEnabled = YES;
            }], nil]];
        }
        else{
            [iconSpriteTemp removeFromParent];
        }
        if(_puzzleCount == 4){
//            animation start
            _puzzleCount = 0;
            [self finAnimationStart];
        }
    }], nil]];
}

-(void)iconTouchCanceledBlock:(UITouch* )touch sender:(TouchSprite* )iconSprite{
    iconSprite.userInteractionEnabled = NO;
    [self iconGoback:iconSprite];
}

-(void)iconGoback:(TouchSprite* )iconSprite{
    iconSprite.zOrder = FISHORDER + 10;
    CGPoint endPosition = CGPointZero;
    CCTime duration = 0.f;
    const CGFloat speed = 1500.f;
    if ([iconSprite.name isEqualToString:@"quant"]) {
        endPosition = ccp(484/2.f, 768 - 242.5/2.f);
    }
    else{
        endPosition = ccp(478/2.f, 768 - 532.5/2.f);
    }
    duration = ccpDistance(endPosition, iconSprite.position)/speed;
    __block TouchSprite* iconSpriteTemp = iconSprite;
    [iconSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:duration position:endPosition], [CCActionCallBlock actionWithBlock:^{
        iconSpriteTemp.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@_fin_observe.png", iconSpriteTemp.name]];
        iconSpriteTemp.userInteractionEnabled = YES;
        [iconSpriteTemp removeAllChildren];
    }], nil]];
}

-(void)finAnimationStart{
//    tag
    for (int i = 0; i < _backgroundNode.children.count; i++) {
        CCSprite* tag = (CCSprite* )_backgroundNode.children[i];
        if (tag.name.length == 4 && [[tag.name substringToIndex:3] isEqual:@"tag"]) {
            __block CCSprite* tagTemp = tag;
            [tag runAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:0.5f position:ccp(tag.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
                [tagTemp removeFromParent];
            }], nil]];
        }
    }
    
//    remove sprites
    for (CCSprite* darkSpirte in _removeSprites) {
        [darkSpirte removeFromParent];
    }
    [_removeSprites removeAllObjects];

//    ship & water
    CCSprite* shipSprite = (CCSprite* )[_backgroundNode getChildByName:@"ship" recursively:NO];
    [shipSprite removeFromParent];
    shipSprite.position = [_finClippingNode convertToNodeSpace:shipSprite.position];
    [_finClippingNode addChild:shipSprite z:2];
    shipSprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"ship1_fin_observe.png"];
    shipSprite.position = ccp(shipSprite.position.x, shipSprite.position.y - 77.5/2.f);
    
    CCAnimation* shipAnimation = [CCAnimation animationWithFile:@"ship" withSuffix:@"_fin_observe" frameCount:14 delay:1/12.f];
    CCAnimation* waterAnimation = [CCAnimation animationWithFile:@"water" withSuffix:@"_fin_observe" frameCount:9 delay:1/4.f];
    __unsafe_unretained CCSprite* waterSpriteTemp = (CCSprite* )[_finClippingNode getChildByName:@"water" recursively:NO];
    __unsafe_unretained CCSprite* shipSpriteTemp = shipSprite;
    [shipSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionScaleTo actionWithDuration:1.f scale:0.6], [CCActionMoveBy actionWithDuration:1.f position:ccp(0, -20)], nil], [CCActionCallBlock actionWithBlock:^{
        [shipSpriteTemp runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:shipAnimation]]];
        [waterSpriteTemp runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:waterAnimation]]];
        [shipSpriteTemp runAction:[CCActionRepeatForever actionWithAction:[CCActionSpawn actions:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.25f], [CCActionJumpBy actionWithDuration:1.5f position:CGPointZero height:20 jumps:1], [CCActionDelay actionWithDuration:0.5f], nil], [CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionRepeat actionWithAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:0.25f position:ccp(0, 3)], [CCActionDelay actionWithDuration:1/16.f], [CCActionMoveBy actionWithDuration:0.25f position:ccp(0, -3)], [CCActionDelay actionWithDuration:1/16.f], nil] times:2], nil], nil]]];
    }], nil]];
    
//    clouds
    for (CCSprite* cloud in _finClippingNode.children) {
        if ([cloud.name isEqualToString:@"water"] || [cloud.name isEqualToString:@"ship"]) {
            continue;
        }
        [cloud stopAllActions];
        CGFloat distance = 1024 + cloud.contentSize.width - cloud.position.x;
        CCTime duration = distance/200.f;//(724 + cloud.contentSize.width * 2) * 5.f;
        [cloud runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:duration position:ccp(1024 + cloud.contentSize.width, cloud.position.y)], [CCActionCallBlock actionWithBlock:^{
            cloud.position = ccp(300 - cloud.contentSize.width, cloud.position.y);
            [cloud runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:(724 + cloud.contentSize.width * 2)/200.f position:ccp(1024 + cloud.contentSize.width, cloud.position.y)], [CCActionCallBlock actionWithBlock:^{
                cloud.position = ccp(300 - cloud.contentSize.width, cloud.position.y);
            }], nil]]];
        }], nil]];
        
    }
    
    [self createGoNextSprite];
}

-(void)finGoOver:(TouchSprite* )goNextSprite{
    __unsafe_unretained SecondObserveScene* weakSelf = self;
    __unsafe_unretained CCSprite* boardSpriteTemp = _boardSprite;
    __unsafe_unretained CCNode* backgroundNodeTemp = _backgroundNode;
    __unsafe_unretained CCClippingNode* clipNodeTemp = _finClippingNode;
    [_boardSprite runAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:1.f position:ccp(_boardSprite.contentSize.width, 0)], [CCActionCallBlock actionWithBlock:^{
//        [weakSelf observerGoBack];
        [boardSpriteTemp removeAllChildren];
        [boardSpriteTemp removeFromParent];
        [clipNodeTemp removeFromParent];
        clipNodeTemp.stencil = nil;
        __unsafe_unretained CCSprite* finBg = (CCSprite* )[backgroundNodeTemp getChildByName:@"fin_bg" recursively:NO];
        [finBg runAction:[CCActionSequence actions:[CCActionFadeOut actionWithDuration:1.f], [CCActionCallBlock actionWithBlock:^{
            [finBg removeFromParent];
        }], nil]];
        for (CCSprite* fin in _observedSpriteArray) {
            __block CCSprite* finTemp = fin;
            [fin runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
                [finTemp removeFromParent];
            }], nil]];
        }
        [_observedSpriteArray removeAllObjects];
        
        weakSelf.step = 3;
        [weakSelf createObservedSprite];
        weakSelf.prevButton.visible = YES;
        weakSelf.prevButton.enabled = YES;
        weakSelf.homeButton.enabled = YES;
    }], nil]];
    
    [_finClippingNode runAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:1.f position:ccp(_boardSprite.contentSize.width, 0)], nil]];
    
    [_observerSprite removeFromParent];
    _observerSprite = nil;
//    __block TouchSprite* goNextSpriteTemp = goNextSprite;
//    [goNextSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.7f],[CCActionFadeTo actionWithDuration:0.3f opacity:0], [CCActionCallBlock actionWithBlock:^{
//        goNextSpriteTemp.touchBegan = nil;
//        [goNextSpriteTemp removeFromParent];
//    }], nil]];
    
    [_observedNames removeObjectAtIndex:0];
    [_observedPositions removeObjectAtIndex:0];
    [_spriteCount removeObjectAtIndex:0];
    
    _isShowAnimation = NO;
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
    [_backgroundNode addChild:scaleCircleSprite z:FISHORDER + 3];
    __unsafe_unretained CCNode* backgroundTemp = _backgroundNode;
    [scaleCircleSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:0.5f position:ccp(603.5/2.f, 768 - 306.5/2.f)], [CCActionScaleTo actionWithDuration:1.f scale:1.f], nil], [CCActionCallBlock actionWithBlock:^{
        //    wave
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
    [_backgroundNode addChild:scalesSprite z:FISHORDER + 4];
    [scalesSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
        [scalesSprite removeFromParent];
        scalesSprite.position = [scaleCircleSprite convertToNodeSpace:scalesSprite.position];
        [scaleCircleSprite addChild:scalesSprite z:1];
        scalesSprite.userInteractionEnabled = YES;
    }], nil]];
    
    __unsafe_unretained SecondObserveScene* weakSelf = self;
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
    [_backgroundNode addChild:scaleCircleSprite z:FISHORDER + 2];
    
    [scaleCircleSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.5f position:ccp(1267.5/2.f, 768 - 306.5/2.f)], [CCActionCallBlock actionWithBlock:^{
        
    }], nil]];
    
//    a scale
    CCSprite* aScaleSprite = [CCSprite spriteWithImageNamed:@"scale_scale_observe.png"];
    aScaleSprite.position = ccp(1267.5/2.f, 768 - 306.5/2.f);
    aScaleSprite.opacity = 0;
    [_backgroundNode addChild:aScaleSprite z:FISHORDER + 3];
    __unsafe_unretained SecondObserveScene* weakSelf = self;
    [aScaleSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionDelay actionWithDuration:1.f], [CCActionCallBlock actionWithBlock:^{
        [aScaleSprite removeFromParent];
        aScaleSprite.position = [scaleCircleSprite convertToNodeSpace:aScaleSprite.position];
        [scaleCircleSprite addChild:aScaleSprite z:1];
        [weakSelf createGoNextSprite];
    }], nil]];
    
//    wave stop
    CCSprite* wave = (CCSprite* )[_backgroundNode getChildByName:@"wave" recursively:NO];
    [wave stopAllActions];
    __unsafe_unretained CCSprite* waveTemp = wave;
    [wave runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:0.5f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
        [waveTemp removeFromParent];
    }], nil]];
}

-(void)scaleGoOver:(TouchSprite* )goNextSprite{
    CCSprite* scaleCircleOne = (CCSprite* )[_backgroundNode getChildByName:@"scaleCircle1" recursively:NO];
    CCSprite* scaleCircleTwo = (CCSprite* )[_backgroundNode getChildByName:@"scaleCircle2" recursively:NO];
    
//    __unsafe_unretained SecondObserveScene* weakSelf = self;
    __unsafe_unretained CCSprite* scaleCircleTwoTemp = scaleCircleTwo;
    __unsafe_unretained CCSprite* scaleCircleOneTemp = scaleCircleOne;
    __unsafe_unretained NSMutableArray* observedSpriteArrayTemp = _observedSpriteArray;
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
        [_backgroundNode addChild:spark z:1000];
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
        [_backgroundNode addChild:bubbles z:999];
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
        [_backgroundNode addChild:spark z:1000];
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
        [_backgroundNode addChild:bubbles z:999];
        [scaleCircleTwoTemp removeAllChildren];
        [scaleCircleTwoTemp removeFromParent];
//        [weakSelf observerGoBack];
        self.homeButton.enabled = YES;
        if (_observedNames.count == 0) {
            [self goOver];
        }
        
        for (CCSprite* sprite in observedSpriteArrayTemp) {
            __unsafe_unretained CCSprite* spriteTemp = sprite;
            [sprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
                [spriteTemp removeFromParent];
            }], nil]];
        }
        [observedSpriteArrayTemp removeAllObjects];
    }], nil]];
    
//    __unsafe_unretained TouchSprite* goNextSpriteTemp = goNextSprite;
//    [goNextSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.7f], [CCActionFadeTo actionWithDuration:0.3f opacity:0], [CCActionCallBlock actionWithBlock:^{
//        goNextSpriteTemp.touchBegan = nil;
//        [goNextSpriteTemp removeFromParent];
//    }], nil]];
//    
    [_observedNames removeObjectAtIndex:0];
    [_observedPositions removeObjectAtIndex:0];
    [_spriteCount removeObjectAtIndex:0];
}

-(void)createGoNextSprite{
//    TouchSprite* goNextSprite = [TouchSprite spriteWithImageNamed:@"play.png"];
//    goNextSprite.position = ccp(1797/2, 768 - 1358/2);
//    goNextSprite.opacity = 0;
//    goNextSprite.userInteractionEnabled = YES;
//    [_backgroundNode addChild:goNextSprite z:1000];
//    __unsafe_unretained SecondObserveScene* weakSelf = self;
//    __unsafe_unretained TouchSprite* goNextSpriteTemp = goNextSprite;
//    goNextSprite.touchBegan = ^(UITouch* touch){
//        goNextSpriteTemp.userInteractionEnabled = NO;
//        [goNextSpriteTemp stopAllActions];
//        goNextSpriteTemp.scale = 1;
//        [weakSelf performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@GoOver:", _observedNames[0]]) withObject:goNextSpriteTemp afterDelay:0.f];
//    };
//    
//    [goNextSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionDelay actionWithDuration:0.f], [CCActionCallBlock actionWithBlock:^{
//        [goNextSprite runAction:[ActionProvider getRepeatScalePrompt]];
//    }], nil]];
    self.step++;
    self.nextButton.visible = YES;
    self.nextButton.enabled = YES;
}

-(void)goOver{
//    bg
    CCSprite* worldBg = [CCSprite spriteWithImageNamed:@"bg_world_observe.png"];
    worldBg.position = ccp(512, 384);
    worldBg.scale = 0.f;
    [_backgroundNode addChild:worldBg z:WORLDORDER];
    
//    plants
    CGPoint positions[] = {ccp(1053/2.f, 768 - 739/2.f), ccp(1017/2.f, 768 - 703.5/2.f)};
    for (int i = 0; i < 2; i++) {
        CCSprite* plant = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"plant%d_world_observe.png", i + 1]];
        plant.position = positions[i];
        plant.scale = 0.f;
        plant.name = [NSString stringWithFormat:@"plant%d", i + 1];
        [_backgroundNode addChild:plant z:WORLDORDER + 2 - i];
        
        [plant runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.f + 0.2f * i], [CCActionScaleTo actionWithDuration:1.f scale:1.1f], [CCActionScaleTo actionWithDuration:0.2f scale:0.95f], [CCActionScaleTo actionWithDuration:0.1f scale:1.f], nil]];
    }
    
//    board
    CCSprite* worldBoard = [CCSprite spriteWithImageNamed:@"board_world_observe.png"];
    worldBoard.position = ccp(1023.5/2.f, 768 - 781.5/2.f);
    [_backgroundNode addChild:worldBoard z:WORLDORDER + 3];
    
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
        [_backgroundNode addChild:bubble z:WORLDORDER + 4];
        
        CCSprite* light = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"light%d_world_observe.png", i + 1]];
        light.position = bubblePositions[i];
        light.opacity = 0.f;
        [_backgroundNode addChild:light z:WORLDORDER + 4];
        
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
    
    __unsafe_unretained CCSprite* plantOneTemp = (CCSprite* )[_backgroundNode getChildByName:@"plant1" recursively:NO];
    __unsafe_unretained CCSprite* plantTwoTemp = (CCSprite* )[_backgroundNode getChildByName:@"plant2" recursively:NO];
//    __unsafe_unretained CCSprite* homeTemp = (CCSprite* )[_backgroundNode getChildByName:@"home" recursively:NO];
    __unsafe_unretained TouchSprite* goWorldSpriteTemp = goWorldSprite;
    __unsafe_unretained CCSprite* worldBoardTemp = worldBoard;
    __unsafe_unretained SecondObserveScene* weakSelf = self;
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
//        [homeTemp runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.1f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
//            [[CCDirector sharedDirector] replaceScene:[FishLivingEnvironmentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:0.01f]];
//        }], nil]];
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
//    delete？？
    [_finClippingNode removeAllChildren];
    _finClippingNode.stencil = nil;
    [_boardSprite removeAllChildren];
    [_backgroundNode removeAllChildren];
    
    _puzzleCount = 0;
    [_spriteCount removeAllObjects];
    [_observedSpriteArray removeAllObjects];
    [_observedNames removeAllObjects];
    [_observedPositions removeAllObjects];
    [_removeSprites removeAllObjects];
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{
    _boardSprite = nil;
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

@end
