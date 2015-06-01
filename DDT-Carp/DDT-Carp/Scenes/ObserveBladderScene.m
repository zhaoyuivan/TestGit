//
//  ObserveBladderScene.m
//  DDT-Carp
//
//  Created by Z on 15/2/3.
//  Copyright (c) 2015年 ZY. All rights reserved.
//

#import "ObserveBladderScene.h"
#import "BubbleRise.h"
#import "CCTextureCache.h"
#import "FishSprite.h"
#import "CCAnimation+Helper.h"
#import "SparkNode.h"
#import "Fireworks.h"

#import "ObserveGillScene.h"
#import "SubmarineScene.h"

#define FISHORDER 100

@interface ObserveBladderScene ()<CCPhysicsCollisionDelegate>
{
    CCClippingNode* _observedClNode;
    BOOL _isShowAnimation;
    
//    bubble
    BOOL _bubbleStart;
    CGFloat _createBubbleTime;
    
//    bladder
    BOOL _physicsLauched;
    BOOL _isTouchBladder;
    CCSprite* _bladderSprite;
}
@end

@implementation ObserveBladderScene
+(ObserveBladderScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bubbleStart = YES;
        _createBubbleTime = 10.f;
        _isShowAnimation = NO;
        _physicsLauched = NO;
        
//        base words
        self.prevButton.visible = NO;
        self.nextButton.visible = NO;
        self.homeButton.visible = NO;
        self.currentScene = @"bladder";
        self.imageSuffix = @"observe";
        
//        base observed
        self.observedName = @"bladder";
        self.observedCount = 1;
        self.observedPositions = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(962/2, 768 - 946/2)], nil];
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createBackground];
}

-(void)prevPress:(CCButton *)button{
    if(self.step == 1){
        ObserveGillScene* nextScene = [ObserveGillScene scene];
        nextScene.isJumpHere = YES;
        [[CCDirector sharedDirector] replaceScene:nextScene withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    [self handleButtons:NO];
}

-(void)nextPress:(CCButton *)button{
    if (self.step == 1) {
        [[CCDirector sharedDirector] replaceScene:[SubmarineScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    }
    else if(self.step == 2){
        [self bladderGoOver];
    }
    [self handleButtons:NO];
}

-(void)update:(CCTime)delta{
    if (_bubbleStart) {
        _createBubbleTime += delta;
        if (_createBubbleTime >= 10.f) {
            _createBubbleTime = 0.f;
            BubbleRise* bubbleRise = [BubbleRise node];
            CGFloat x = 100.0 + arc4random()%650;
            CGFloat y = 50.0 + arc4random()%50;
            bubbleRise.position = ccp(x, y);
            bubbleRise.numberOfBubbles = 4;
            bubbleRise.riseTime = (768 + bubbleRise.contentSize.height)/70.f;
            bubbleRise.randomNumberOfBubbles = YES;
            bubbleRise.imageName = @"bubble";
            bubbleRise.imageSuffixName = @"_puzzle";
            bubbleRise.numberOfImages = 4;
            bubbleRise.isDestroySelf = YES;
            [self.backgroundNode addChild:bubbleRise z:1];
        }
    }
    if (_physicsLauched) {
        FishSprite* fishSprite = (FishSprite* )_bladderSprite.parent;
        CGPoint position = fishSprite.position;
        CGFloat lowY = _observedClNode.stencil.position.y - _observedClNode.stencil.contentSize.height/2;
        CCPhysicsNode* physicsNode = (CCPhysicsNode* )fishSprite.parent;
//        398 - -100 lowY - 120
        CGFloat lowGravity = 100;
        CGFloat gravityRatio = (-100 - lowGravity)/(398 - lowY);
        physicsNode.gravity = ccp(0, (position.y - lowY) * gravityRatio + lowGravity);
        if (_isTouchBladder) {
//            bladder
//            398 - 1/0.45 lowY - 0.7/0.45
            CGFloat lowScaleX = 0.7f/0.45f;
            CGFloat ratioX = (1/0.45f - lowScaleX)/(398.f - lowY);
            CGFloat lowScaleY = 0.2f;
            CGFloat ratioY = (1/0.45f - lowScaleY)/(398.f - lowY);
            _bladderSprite.scaleX = (position.y - lowY) * ratioX + lowScaleX;
            _bladderSprite.scaleY = (position.y - lowY) * ratioY + lowScaleY;
        }
    }
}

-(void)createBackground{
//    bg
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_observe.png"];
    bgSprite.anchorPoint = ccp(0, 0);
    bgSprite.position = ccp(0, 0);
    [self.backgroundNode addChild:bgSprite z:1];
    
//    fish
    CCSprite* fishSprite = [CCSprite spriteWithImageNamed:@"carp_observe.png"];
    fishSprite.position = ccp(1047/2, 768 - 915.5/2);
    [self.backgroundNode addChild:fishSprite z:FISHORDER];
    
//    gill
    CCSprite* gillSprite = [CCSprite spriteWithImageNamed:@"gill_observe.png"];
    gillSprite.name = @"gill";
    gillSprite.position = ccp(491.5/2, 768 - 989.5/2);
    [self.backgroundNode addChild:gillSprite z:FISHORDER + 2];
}

-(void)createScene{
    [self createObservedSprite];
}

#pragma mark - bladder
-(void)observeBladder{
    if (_isShowAnimation) {
        return;
    }
    _isShowAnimation = YES;
    [self handleButtons:NO];
    self.homeButton.enabled = NO;
//    bladder bg
    CCSprite* bladderBgSprite = [CCSprite spriteWithImageNamed:@"bladder_bg_observe.png"];
    bladderBgSprite.position = ccp(964/2, 768 - 949/2);
    bladderBgSprite.name = @"bladderBg";
    [self.backgroundNode addChild:bladderBgSprite z:FISHORDER + 1];
//    circle
    CCSprite* circleSprite = [CCSprite spriteWithImageNamed:@"circle_bladder_observe.png"];
    circleSprite.position = ccp(1029/2, 768 - 767/2);
    circleSprite.name = @"bladderCircle";
    circleSprite.scale = 0.f;
    [self.backgroundNode addChild:circleSprite z:FISHORDER + 4];
    CCSprite* waterCircleSprite = [CCSprite spriteWithImageNamed:@"water_circle_observe.png"];
    waterCircleSprite.position = circleSprite.position;
    waterCircleSprite.scale = 0.f;
    [self.backgroundNode addChild:waterCircleSprite z:FISHORDER + 3];
    
    [waterCircleSprite runAction:[CCActionSpawn actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionScaleTo actionWithDuration:1.f scale:2.5f], nil]];
    [circleSprite runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.5f scale:1.15f], [CCActionScaleTo actionWithDuration:0.1f scale:0.9f], [CCActionScaleTo actionWithDuration:0.1f scale:1.05f], [CCActionScaleTo actionWithDuration:0.1f scale:0.98f], [CCActionScaleTo actionWithDuration:0.1f scale:1.f], [CCActionCallBlock actionWithBlock:^{
        [self bladderAnimationStart:circleSprite];
    }], nil]];
}

-(void)bladderAnimationStart:(CCSprite* )circle{
//    clip node
    CCSprite* clipRect = [CCSprite spriteWithImageNamed:@"clip_bladder_observe.png"];
    clipRect.position = circle.position;
    CCClippingNode* clNode = [CCClippingNode clippingNodeWithStencil:clipRect];
    clNode.contentSize = self.contentSize;
    clNode.alphaThreshold = 0.f;
    [self.backgroundNode addChild:clNode z:FISHORDER + 5];
    
//    water
    for (int i = 0; i < 10; i++) {
        CCSprite* waterSprite = [CCSprite spriteWithImageNamed:@"water_bladder_observe.png"];
        waterSprite.position = ccp(i%2 ? 1142/2 : 1025/2, 768 - (1351 - 9 * 90)/2 - 90/2 * i);
        waterSprite.opacity = 0;
        [clNode addChild:waterSprite z:1];
        [waterSprite runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionMoveBy actionWithDuration:1.f position:ccp(i%2 ? 4 : -4, 0)], nil], [CCActionCallBlock actionWithBlock:^{
            [waterSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:5.f + arc4random()%10*0.1f position:ccp(i%2 ? -20 : 20, 0)], [CCActionMoveBy actionWithDuration:5.f + arc4random()%10*0.1f position:ccp(i%2 ? 20 : -20, 0)], nil]]];
        }], nil]];
    }
//    plants
    CGPoint points[] = {ccp(824/2, 768 - 808/2), ccp(680/2, 768 - 866/2), ccp(1331/2, 768 - 767/2), ccp(902/2, 768 - 860/2), ccp(705/2, 768 - 914/2), ccp(1480/2, 768 - 907/2), ccp(1516/2, 768 - 1001/2), ccp(941/2, 768 - 831/2)};
    int zOrders[] = {10, 9, 8, 6, 5, 4, 3, 2};
    for (int i = 0; i < 8; i++) {
        CCSprite* plant = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"plant%d_bladder_observe.png", i + 1]];
        plant.opacity = 0;
        CGFloat angle = 0.f;
        if (i < 3) {
            plant.anchorPoint = ccp(0, 0);
            plant.position = ccp(points[i].x - plant.contentSize.width/2, points[i].y - plant.contentSize.height/2);
            angle = 1.f;
        }
        else if(i < 7){
            plant.anchorPoint = ccp(1, 0);
            plant.position = ccp(points[i].x + plant.contentSize.width/2, points[i].y - plant.contentSize.height/2);
            angle = -1.f;
        }
        else{
            plant.position = points[i];
        }
        [clNode addChild:plant z:zOrders[i]];
        plant.position = ccp(plant.position.x, plant.position.y - plant.contentSize.height);
        [plant runAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionFadeTo actionWithDuration:1.f opacity:1], [CCActionMoveBy actionWithDuration:2.f position:ccp(0, plant.contentSize.height)], nil], [CCActionCallBlock actionWithBlock:^{
            [plant runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRotateBy actionWithDuration:5.f + arc4random()%20*0.1f angle:3.f*angle], [CCActionRotateBy actionWithDuration:5.f + arc4random()%20*0.1f angle:-3.f*angle], nil]]];
        }], nil]];
    }
    
//    physics
    CCPhysicsNode* physicsNode = [CCPhysicsNode node];
    physicsNode.gravity = ccp(0, -150);
    physicsNode.collisionDelegate = self;
//    physicsNode.debugDraw = YES;
    [clNode addChild:physicsNode z:7];
    
//    bottom
    CCNode* bottomNode = [CCNode node];
    bottomNode.anchorPoint = ccp(0, 0);
    bottomNode.contentSize = CGSizeMake(clipRect.contentSize.width + 500, 200);
    bottomNode.position = ccp(clipRect.position.x - clipRect.contentSize.width/2 - 250, clipRect.position.y - clipRect.contentSize.height/2 - 250);
    bottomNode.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, bottomNode.contentSize} cornerRadius:0];
    bottomNode.physicsBody.type = CCPhysicsBodyTypeStatic;
    bottomNode.physicsBody.elasticity = 0.5f;
    bottomNode.physicsBody.friction = 0.f;
    bottomNode.physicsBody.collisionType = @"obstacle";
    
    [physicsNode addChild:bottomNode z:1];
//    top
    CCNode* topNode = [CCNode node];
    topNode.anchorPoint = ccp(0, 0);
    topNode.contentSize = CGSizeMake(clipRect.contentSize.width + 500, 200);
    topNode.position = ccp(clipRect.position.x - clipRect.contentSize.width/2 - 250, clipRect.position.y + clipRect.contentSize.height/2 - 100);
    topNode.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, topNode.contentSize} cornerRadius:0];
    topNode.physicsBody.type = CCPhysicsBodyTypeStatic;
    topNode.physicsBody.collisionType = @"obstacle";
    topNode.physicsBody.elasticity = 1.f;
    topNode.physicsBody.friction = 0.f;
    [physicsNode addChild:topNode z:1];
//    left
    CCNode* leftNode = [CCNode node];
    leftNode.anchorPoint = ccp(0, 0);
    leftNode.contentSize = CGSizeMake(200, clipRect.contentSize.height);
    leftNode.position = ccp(clipRect.position.x - clipRect.contentSize.width/2 - 200 - 250, clipRect.position.y - clipRect.contentSize.height/2 - 50);
    leftNode.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, leftNode.contentSize} cornerRadius:0];
    leftNode.physicsBody.type = CCPhysicsBodyTypeStatic;
    leftNode.physicsBody.elasticity = 5.f;
    leftNode.physicsBody.friction = 0.f;
    leftNode.physicsBody.collisionType = @"left";
    [physicsNode addChild:leftNode z:1];
//    right
    CCNode* rightNode = [CCNode node];
    rightNode.anchorPoint = ccp(0, 0);
    rightNode.contentSize = CGSizeMake(200, clipRect.contentSize.height);
    rightNode.position = ccp(clipRect.position.x + clipRect.contentSize.width/2 + 250, clipRect.position.y - clipRect.contentSize.height/2 - 50);
    rightNode.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, rightNode.contentSize} cornerRadius:0];
    rightNode.physicsBody.type = CCPhysicsBodyTypeStatic;
    rightNode.physicsBody.elasticity = 5.f;
    rightNode.physicsBody.friction = 0.f;
    rightNode.physicsBody.collisionType = @"right";
    
//    tip
    const CGFloat defaultLength = 30.f;
    
    NSString* tip = NSLocalizedString(@"bladder_tip", nil);
    CGFloat fontSize = [NSLocalizedString(@"bladder_tip_font_size", nil) doubleValue];
    CGFloat letterWidth = [NSLocalizedString(@"bladder_tip_letter_width", nil) doubleValue];
    
    CGSize fontDimension = (CGSize){10 * defaultLength, 0.f};
    
    CGFloat rectScaleY = 1.f;
    if (tip.length * letterWidth / fontDimension.width > 2.f) {
        int row = ceil(tip.length * letterWidth / fontDimension.width);
        rectScaleY = row/2.f;
    }
        
    CCSprite* rect = [CCSprite spriteWithImageNamed:@"tips_bg_submarine.png"];
    
    CCNode* tipNode = [CCNode node];
    tipNode.contentSize = rect.contentSize;
    tipNode.anchorPoint = ccp(0.5f, 0.5f);
    tipNode.position = ccp(512, 384);
//    tipNode.scaleY = rectScaleY;
    [self.backgroundNode addChild:tipNode z:FISHORDER + 6];
    
    rect.position = [tipNode convertToNodeSpace:ccp(512, 384)];
    rect.scaleY = rectScaleY;
    [tipNode addChild:rect z:1];
    
    CCLabelTTF* tipLabel = [CCLabelTTF labelWithString:tip fontName:@"STYuanti-SC-Regular" fontSize:fontSize dimensions:fontDimension];
    tipLabel.position = [tipNode convertToNodeSpace:ccp(512, 384)];
    tipLabel.horizontalAlignment = CCTextAlignmentCenter;
    tipLabel.color = [CCColor whiteColor];
    [tipNode addChild:tipLabel z:1];
    
//    tipNode.scaleX = 0.f;
//    [tipNode runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scaleX:1.f scaleY:1.f], nil]];
    tipNode.position = ccp(tipNode.position.x, tipNode.position.y - 130);
    rect.opacity = 0.f;
    [rect runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
    tipLabel.opacity = 0.f;
    [tipLabel runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionFadeTo actionWithDuration:1.f opacity:1.f], nil]];
    
//    fish
    FishSprite* fishSprite = [FishSprite spriteWithImageNamed:@"carp_well1_puzzle.png"];
    fishSprite.position = ccp(1048/2, 768 - 740/2);
    fishSprite.scale = 0.45f;
    fishSprite.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, fishSprite.contentSize} cornerRadius:0.f];
    fishSprite.physicsBody.collisionType = @"fish";
    fishSprite.physicsBody.type = CCPhysicsBodyTypeStatic;
    fishSprite.state = initial;
    fishSprite.direction = moveToLeft;
    [physicsNode addChild:fishSprite z:1];
    
    CCAnimation* fishAnimation = [CCAnimation animationWithFile:@"carp_well" withSuffix:@"_puzzle" frameCount:4 delay:0.15f];
    [fishSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:fishAnimation]]];
    
    _bladderSprite = [CCSprite spriteWithImageNamed:@"bladder_small_observe.png"];
    _bladderSprite.scale = 1/0.45f;
    _bladderSprite.anchorPoint = ccp(0.3f, 0.5f);
    _bladderSprite.position = [fishSprite convertToNodeSpace:ccp(524 - 30, 398 - 8)];
    [fishSprite addChild:_bladderSprite z:1];
    
    fishSprite.position = ccp(clipRect.position.x + clipRect.contentSize.width/2 + fishSprite.contentSize.width/2 * 0.45f, fishSprite.position.y);
    [fishSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionMoveTo actionWithDuration:2.f position:ccp(1048/2, 768 - 740/2)], [CCActionCallBlock actionWithBlock:^{
        [_bladderSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionBlink actionWithDuration:0.8f blinks:3], [CCActionDelay actionWithDuration:0.5f], nil]]];
        fishSprite.userInteractionEnabled = YES;
        [physicsNode addChild:rightNode z:1];
    }], nil]];
    
    __unsafe_unretained FishSprite* fishSpriteTemp = fishSprite;
    __unsafe_unretained CCSprite* bladderSpriteTemp = _bladderSprite;
    __unsafe_unretained ObserveBladderScene* weafSelf = self;
    __unsafe_unretained CCNode* tipNodeTemp = tipNode;
    fishSprite.touchBegan = ^(UITouch* touch){
        if (fishSpriteTemp.state == initial) {
//            [tipNodeTemp runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:0.f], [CCActionCallBlock actionWithBlock:^{
//                [tipNodeTemp removeAllChildren];
//                [tipNodeTemp removeFromParent];
//            }], nil]];
            
            for (int i = 0; i < tipNodeTemp.children.count; i++) {
                CCNode* tip = tipNodeTemp.children[i];
                [tip runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
                    if (i == 1) {
                        [tipNodeTemp removeAllChildren];
                        [tipNodeTemp removeFromParent];
                    }
                }], nil]];
            }
            [bladderSpriteTemp stopAllActions];
            bladderSpriteTemp.visible = YES;
            fishSpriteTemp.state = lauched;
            fishSpriteTemp.physicsBody.type = CCPhysicsBodyTypeDynamic;
            _physicsLauched = YES;
            _isTouchBladder = YES;
            
            [weafSelf runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionCallBlock actionWithBlock:^{
                [weafSelf createGoNextSprite];
            }], nil]];
        }
        else if (fishSpriteTemp.state == lauched) {
            _isTouchBladder = NO;
        }
        CGFloat xSpeed = 0.f;
        if (fishSpriteTemp.direction == moveToLeft) {
            xSpeed = fishSpriteTemp.physicsBody.velocity.x < -50 ? fishSpriteTemp.physicsBody.velocity.x : -50;
        }
        else{
            xSpeed = fishSpriteTemp.physicsBody.velocity.x > 50 ? fishSpriteTemp.physicsBody.velocity.x : 50;
        }
        fishSpriteTemp.physicsBody.velocity = ccp(xSpeed, 100);
        [weafSelf bladderGrowBig:fishSpriteTemp];
    };
    fishSprite.touchEnded = ^(UITouch* touch){
        _isTouchBladder = YES;
    };
    
    _observedClNode = clNode;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair fish:(CCNode *)nodeA left:(CCNode *)nodeB{
    FishSprite* fishSprite = (FishSprite* )nodeA;
    fishSprite.flipX = YES;
    _bladderSprite.flipX = YES;
    _bladderSprite.anchorPoint = ccp(0.7f, 0.5f);
    _bladderSprite.position = [fishSprite convertToNodeSpace:ccp(fishSprite.position.x + 30, fishSprite.position.y - 8)];
    fishSprite.direction = moveToRight;
    fishSprite.rotation = 0.f;
    return YES;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair fish:(CCNode *)nodeA right:(CCNode *)nodeB{
    FishSprite* fishSprite = (FishSprite* )nodeA;
    fishSprite.flipX = NO;
    _bladderSprite.flipX = NO;
    _bladderSprite.anchorPoint = ccp(0.3f, 0.5f);
    _bladderSprite.position = [fishSprite convertToNodeSpace:ccp(fishSprite.position.x - 30, fishSprite.position.y - 8)];
    fishSprite.direction = moveToLeft;
    fishSprite.rotation = 0.f;
    return YES;
}

-(void)bladderGrowBig:(CCSprite* )fishSprite{
    _bladderSprite.scale = 1/0.45f * 1.3f;
}

-(void)createGoNextSprite{
    self.step++;
    self.nextButton.visible = YES;
    self.nextButton.enabled = YES;
}

-(void)bladderGoOver{
//    remove
    [_observedClNode.stencil runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:0.f], [CCActionCallBlock actionWithBlock:^{
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
        _physicsLauched = NO;
        FishSprite* fishSprite = (FishSprite* )_bladderSprite.parent;
        [_bladderSprite removeFromParent];
        _bladderSprite = nil;
        [fishSprite.parent removeAllChildren];
        
        while (_observedClNode.children.count) {
            CCSprite* sprite = _observedClNode.children.firstObject;
            [sprite removeFromParent];
        }
        _observedClNode.stencil = nil;
        [_observedClNode removeFromParent];
        _observedClNode = nil;
        
    }], nil]];//, [CCActionScaleTo actionWithDuration:0.1f scale:0.f], nil]];
    
    CCSprite* bgSprite = (CCSprite* )[self.backgroundNode getChildByName:[NSString stringWithFormat:@"%@Bg", [(CCSprite*)self.observedSpriteArray.firstObject name]] recursively:NO];
    CCSprite* circleSprite = (CCSprite* )[self.backgroundNode getChildByName:[NSString stringWithFormat:@"%@Circle", [(CCSprite*)self.observedSpriteArray.firstObject name]] recursively:NO];
    [bgSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.7f], [CCActionFadeTo actionWithDuration:0.3f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
        [bgSprite removeFromParent];
    }], nil]];

    [circleSprite runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:3], [CCActionCallBlock actionWithBlock:^{
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
        [self replaceToNextScene];
    }], nil]];
}

-(void)replaceToNextScene{
    CGSize winSize = [[CCDirector sharedDirector] viewSize];
//    截图方法
    CCRenderTexture* texture = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
    [texture begin];
    [self visit];
    [texture end];
    
    SubmarineScene* submarineScene = [SubmarineScene scene];
    texture.anchorPoint = ccp(0.5f, 0.5f);
    texture.position = ccp(winSize.width, winSize.height);
    [submarineScene addChild:texture z:1];
    submarineScene.isFromObserveScene = YES;
    [[CCDirector sharedDirector] replaceScene:submarineScene];
}




-(void)onExit{
    [self.backgroundNode removeAllChildren];
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{
    
}
@end
