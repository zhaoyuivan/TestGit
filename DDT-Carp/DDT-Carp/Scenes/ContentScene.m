//
//  ContentScene.m
//  DDT-Carp
//
//  Created by Z on 14-10-13.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "ContentScene.h"
#import "CCTextureCache.h"
#import "CCAnimation+Helper.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "TouchSprite.h"
#import "GestureSprite.h"

#import "PuzzleScene.h"
#import "LiveEnvironmentScene.h"
#import "ObserveScene.h"
#import "SubmarineScene.h"
#import "SecondObserveScene.h"
#import "FishLivingEnvironmentScene.h"
#import "RiverFishScene.h"
#import "SeaFishScene.h"
#import "MigrationFishScene.h"
#import "ParentControlScene.h"
#import "TeamScene.h"
#import "ObserveGillScene.h"
#import "ObserveBladderScene.h"
#import "ObserveFinScene.h"

#define LOTUSORDER 50
#define TITLEORDER 60

@interface ContentScene ()
{
    CCNode* _backgroundNode;
}
@property (nonatomic) BOOL isTouching;
@property (nonatomic) BOOL isSoundOn;
@end

@implementation ContentScene
+(ContentScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isTouching = NO;
        _isSoundOn = YES;
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createSprites];
    self.userInteractionEnabled = YES;
}

-(void)createSprites{
    _backgroundNode = [CCNode node];
    _backgroundNode.contentSize = [[CCDirector sharedDirector] viewSize];
    _backgroundNode.anchorPoint = ccp(0, 0);
    _backgroundNode.position = ccp(0, 0);
    [self addChild:_backgroundNode];
    
//    parent
    GestureSprite* parentSprite = [GestureSprite spriteWithImageNamed:@"parent.png"];
    parentSprite.name = @"parent";
    parentSprite.position = ccp(117/2.f, 768 - 93/2.f);
    parentSprite.userInteractionEnabled = YES;
    [_backgroundNode addChild:parentSprite z:1000];
    
    CCSprite* wordSprite = [CCSprite spriteWithImageNamed:@"word_prompt_content.png"];
    wordSprite.position = ccp(379/2.f, 768 - 99/2.f);
    wordSprite.opacity = 0.f;
    [_backgroundNode addChild:wordSprite z:1000];
    
    __unsafe_unretained ContentScene* weakSelf = self;
    __unsafe_unretained CCSprite* wordSpriteTemp = wordSprite;
    __unsafe_unretained TouchSprite* parentSpriteTemp = parentSprite;
    parentSprite.touchBegan = ^(UITouch* touch){
        [wordSpriteTemp stopAllActions];
        [wordSpriteTemp runAction:[CCActionFadeTo actionWithDuration:0.5f opacity:1.f]];
        [parentSpriteTemp runAction:[ActionProvider getPressBeginAction]];
    };
    
    parentSprite.touchEnded = ^(UITouch* touch){
        [wordSpriteTemp stopAllActions];
        [wordSpriteTemp runAction:[CCActionFadeTo actionWithDuration:0.5f opacity:0.f]];
        [parentSpriteTemp runAction:[ActionProvider getPressEndAction]];
    };
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
    longPress.minimumPressDuration = 2.5f;
    longPress.allowableMovement = 20.f;
    [parentSprite addGesture:longPress];
    
//    sound
    TouchSprite* soundSprite = [TouchSprite spriteWithImageNamed:@"sound_on.png"];
    soundSprite.position = ccp(1775/2.f, 768 - 93/2.f);
    soundSprite.userInteractionEnabled = YES;
    [_backgroundNode addChild:soundSprite z:1000];
    
    __unsafe_unretained TouchSprite* soundSpriteTemp = soundSprite;
    soundSprite.touchBegan = ^(UITouch* touch){
        [soundSpriteTemp runAction:[ActionProvider getPressBeginAction]];
    };
    
    soundSprite.touchEnded = ^(UITouch* touch){
        [soundSpriteTemp runAction:[ActionProvider getPressEndAction]];
        if (CGRectContainsPoint(soundSpriteTemp.boundingBox, [touch locationInWorld])) {
            weakSelf.isSoundOn = !weakSelf.isSoundOn;
            soundSpriteTemp.spriteFrame = [CCSpriteFrame frameWithImageNamed:weakSelf.isSoundOn ? @"sound_on.png" : @"sound_off.png"];
        }
    };
    
//    team
    TouchSprite* teamSprite = [TouchSprite spriteWithImageNamed:@"team.png"];
    teamSprite.position = ccp(1946/2.f, 768 - 93/2.f);
    teamSprite.userInteractionEnabled = YES;
    [_backgroundNode addChild:teamSprite z:1000];
    __unsafe_unretained TouchSprite* teamSpriteTemp = teamSprite;
    teamSprite.touchBegan = ^(UITouch* touch){
        teamSpriteTemp.userInteractionEnabled = NO;
        [teamSpriteTemp runAction:[ActionProvider getPressBeginAction]];
    };
    
    teamSprite.touchEnded = ^(UITouch* touch){
        [teamSpriteTemp runAction:[ActionProvider getPressEndAction]];
        if (CGRectContainsPoint(teamSpriteTemp.boundingBox, [touch locationInWorld])) {
            [[CCDirector sharedDirector] replaceScene:[TeamScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
        }
        else{
            teamSpriteTemp.userInteractionEnabled = YES;
        }
    };
    
//    bg
    for (int i = 0; i < 4; i++) {
        CCSprite* bgSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"bg%d_content.png", i+1]];
        bgSprite.anchorPoint = ccp(0, 0);
        bgSprite.position = ccp(0, 0);
        [_backgroundNode addChild:bgSprite z:(i+1) * 10];
    }
    
//    lotus
    CCSprite* lotusSprite = [CCSprite spriteWithImageNamed:@"lotus_content.png"];
    lotusSprite.position = ccp(1753/2, 768 - 387/2);
    [_backgroundNode addChild:lotusSprite z:LOTUSORDER];
    
//    lotus leaf
    CCSprite* lotusLeafSprite = [CCSprite spriteWithImageNamed:@"lotus_leaf_content.png"];
    lotusLeafSprite.position = ccp(1550/2, 768 - 299/2);
    [_backgroundNode addChild:lotusLeafSprite z:LOTUSORDER];
    
    CCSprite* rightLeafSprite = [CCSprite spriteWithImageNamed:@"lotus_right_leaf_content.png"];
    rightLeafSprite.anchorPoint = ccp(1, 0);
    rightLeafSprite.position = ccp(1749/2 + rightLeafSprite.contentSize.width/2, 768 - 877/2 - rightLeafSprite.contentSize.height/2);
    [_backgroundNode addChild:rightLeafSprite z:LOTUSORDER];
  
    CCSprite* leftLeafOneSprite = [CCSprite spriteWithImageNamed:@"lotus_left_leaf1_content.png"];
    leftLeafOneSprite.anchorPoint = ccp(0, 0);
    leftLeafOneSprite.position = ccp(318/2 - leftLeafOneSprite.contentSize.width/2, 768 - 862/2 - leftLeafOneSprite.contentSize.height/2);
    [_backgroundNode addChild:leftLeafOneSprite z:30];
    
    CCSprite* leftLeafTwoSprite = [CCSprite spriteWithImageNamed:@"lotus_left_leaf2_content.png"];
    leftLeafTwoSprite.anchorPoint = ccp(0, 0);
    leftLeafTwoSprite.position = ccp(48/2 - leftLeafTwoSprite.contentSize.width/2, 768 - 772/2 - leftLeafTwoSprite.contentSize.height/2);
    [_backgroundNode addChild:leftLeafTwoSprite z:30];
    
//    water plant
    CCSprite* waterPlantSprite = [CCSprite spriteWithImageNamed:@"water_plant_content.png"];
    waterPlantSprite.anchorPoint = ccp(1, 0);
    waterPlantSprite.position = ccp(1939/2 + waterPlantSprite.contentSize.width/2, 768 - 1092/2 - waterPlantSprite.contentSize.height/2);
    [_backgroundNode addChild:waterPlantSprite z:LOTUSORDER];
    
    [rightLeafSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRotateBy actionWithDuration:2.5f angle:-3], [CCActionDelay actionWithDuration:0.1f], [CCActionRotateBy actionWithDuration:2.5f angle:3], [CCActionDelay actionWithDuration:0.1], nil]]];
    
    [waterPlantSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:  [CCActionRotateBy actionWithDuration:2.f angle:-3], [CCActionDelay actionWithDuration:0.1f], [CCActionRotateBy actionWithDuration:2.f angle:3], [CCActionDelay actionWithDuration:0.1], nil]]];
    
    [leftLeafOneSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRotateBy actionWithDuration:2.2f angle:2], [CCActionDelay actionWithDuration:0.1f], [CCActionRotateBy actionWithDuration:2.2f angle:-2], [CCActionDelay actionWithDuration:0.1], nil]]];
    
    [leftLeafTwoSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionRotateBy actionWithDuration:2.5f angle:3], [CCActionDelay actionWithDuration:0.1f], [CCActionRotateBy actionWithDuration:2.5f angle:-3], [CCActionDelay actionWithDuration:0.1], nil]]];
    
//    fish
    CCSprite* rightFishSprite = [CCSprite spriteWithImageNamed:@"fish1_content.png"];
    rightFishSprite.position = ccp(1024 + rightFishSprite.contentSize.width/2, 768 - 1026/2);
    [_backgroundNode addChild:rightFishSprite z:20];
    
    CCSprite* leftFishSprite = [CCSprite spriteWithImageNamed:@"fish1_content.png"];
    leftFishSprite.scale = 0.8;
    leftFishSprite.flipX = YES;
    leftFishSprite.position = ccp(-leftFishSprite.contentSize.width/2, 768 - 998/2);
    [_backgroundNode addChild:leftFishSprite z:10];
    
    CCAnimation* fishAnimation = [CCAnimation animationWithFile:@"fish" withSuffix:@"_content" frameCount:3 delay:0.2f];
    [rightFishSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:fishAnimation]]];
    
    ccBezierConfig rightFishBezierMoveOne;
    rightFishBezierMoveOne.controlPoint_1 = ccp((rightFishSprite.position.x + 512 + 100)/2, 768 - 1026/2 + 100);
    rightFishBezierMoveOne.controlPoint_2 = ccp((rightFishSprite.position.x + 512 + 100)/2, 768 - 1026/2 - 100);
    rightFishBezierMoveOne.endPosition = ccp(512 + 100, rightFishSprite.position.y);
    
    ccBezierConfig rightFishBezierMoveTwo;
    rightFishBezierMoveTwo.controlPoint_1 = ccp((512 - 100 - rightFishSprite.contentSize.width/2)/2, 768 - 1026/2 + 100);
    rightFishBezierMoveTwo.controlPoint_2 = ccp((512 - 100 - rightFishSprite.contentSize.width/2)/2, 768 - 1026/2 - 100);
    rightFishBezierMoveTwo.endPosition = ccp(-rightFishSprite.contentSize.width/2, 768 - 1026/2);
    [rightFishSprite runAction:[CCActionSequence actions:[CCActionBezierTo actionWithDuration:12.f bezier:rightFishBezierMoveOne], [CCActionDelay actionWithDuration:0.1f], [CCActionMoveBy actionWithDuration:8.f position:ccp(-200, 0)], [CCActionDelay actionWithDuration:0.1f], [CCActionBezierTo actionWithDuration:12.f bezier:rightFishBezierMoveTwo], [CCActionCallBlock actionWithBlock:^{
        [rightFishSprite removeFromParent];
    }], nil]];
    
    [leftFishSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:fishAnimation]]];
    
    ccBezierConfig leftFishBezierMoveOne;
    leftFishBezierMoveOne.controlPoint_1 = ccp((leftFishSprite.position.x + 512 - 100)/2, 768 - 998/2 - 100);
    leftFishBezierMoveOne.controlPoint_2 = ccp((leftFishSprite.position.x + 512 - 100)/2, 768 - 998/2 + 100);
    leftFishBezierMoveOne.endPosition = ccp(512 - 100, leftFishSprite.position.y);
    
    ccBezierConfig leftFishBezierMoveTwo;
    leftFishBezierMoveTwo.controlPoint_1 = ccp((512 + 100 + 1024 + leftFishSprite.contentSize.width/2)/2, 768 - 998/2 + 100);
    leftFishBezierMoveTwo.controlPoint_2 = ccp((512 + 100 + 1024 + leftFishSprite.contentSize.width/2)/2, 768 - 998/2 - 100);
    leftFishBezierMoveTwo.endPosition = ccp(1024 + leftFishSprite.contentSize.width/2, 768 - 998/2);
    [leftFishSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:15.f], [CCActionBezierTo actionWithDuration:12.f bezier:leftFishBezierMoveOne], [CCActionDelay actionWithDuration:0.1f], [CCActionMoveBy actionWithDuration:8.f position:ccp(200, 0)], [CCActionDelay actionWithDuration:0.1f], [CCActionBezierTo actionWithDuration:12.f bezier:leftFishBezierMoveTwo], [CCActionCallBlock actionWithBlock:^{
        [leftFishSprite removeFromParent];
    }], nil]];
    
//    cloud
    CCSprite* rightCloudOneSprite = [CCSprite spriteWithImageNamed:@"right_cloud1_content.png"];
    rightCloudOneSprite.position = ccp(1024 + rightCloudOneSprite.contentSize.width/2, 768 - 111/2);
    [_backgroundNode addChild:rightCloudOneSprite z:11];
    
    CCSprite* rightCloudTwoSprite = [CCSprite spriteWithImageNamed:@"right_cloud2_content.png"];
    rightCloudTwoSprite.position = ccp(1024 + rightCloudTwoSprite.contentSize.width/2, 768 - 59/2 - 20);
    [_backgroundNode addChild:rightCloudTwoSprite z:10];
    
    CCSprite* leftCloudSprite = [CCSprite spriteWithImageNamed:@"left_cloud_content.png"];
    leftCloudSprite.position = ccp(-leftCloudSprite.contentSize.width/2, 768 - 59/2 - 20);
    [_backgroundNode addChild:leftCloudSprite z:10];
    
    [rightCloudOneSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:4.f], [CCActionMoveTo actionWithDuration:10.f position:ccp(1359/2, 768 - 111/2)], [CCActionCallBlock actionWithBlock:^{
        [rightCloudOneSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:4.f position:ccp(-50, 0)], [CCActionDelay actionWithDuration:0.2f], [CCActionMoveBy actionWithDuration:4.f position:ccp(50, 0)], [CCActionDelay actionWithDuration:0.2f], nil]]];
    }], nil]];
    
    [rightCloudTwoSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:5.f position:ccp(1822/2, 768 - 59/2 - 20)], [CCActionCallBlock actionWithBlock:^{
        [rightCloudTwoSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:4.f position:ccp(-50, 0)], [CCActionDelay actionWithDuration:0.2f], [CCActionMoveBy actionWithDuration:4.f position:ccp(50, 0)], [CCActionDelay actionWithDuration:0.2f], nil]]];
    }], nil]];
    
    [leftCloudSprite runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:5.f position:ccp(261/2, 768 - 59/2 - 20)], [CCActionCallBlock actionWithBlock:^{
        [leftCloudSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionMoveBy actionWithDuration:4.f position:ccp(50, 0)], [CCActionDelay actionWithDuration:0.2f], [CCActionMoveBy actionWithDuration:4.f position:ccp(-50, 0)], [CCActionDelay actionWithDuration:0.2f], nil]]];
    }], nil]];
    
//    title
    CCSprite* titleSprite = [CCSprite spriteWithImageNamed:@"title_content.png"];
    titleSprite.position = ccp(1005/2, -titleSprite.contentSize.height/2);
    titleSprite.opacity = 0;
    [_backgroundNode addChild:titleSprite z:TITLEORDER];
    
    [titleSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.5f], [CCActionSpawn actions:[CCActionMoveTo actionWithDuration:3.f position:ccp(1005/2, 768 - 1151/2)], [CCActionFadeTo actionWithDuration:3.f opacity:1], nil], nil]];
    
//    circles
    CGPoint circlePositions[] = {ccp(675/2.f, 768 - 641/2.f), ccp(1370/2.f, 768 - 641/2.f)};
    NSArray* imageNames = @[@"secret_content.png", @"world_content.png"];
    for (int i = 0; i < 2; i++) {
        CCSprite* bigCircle = [CCSprite spriteWithImageNamed:@"circle_content.png"];
        bigCircle.position = circlePositions[i];
        bigCircle.opacity = 0.f;
        [_backgroundNode addChild:bigCircle z:TITLEORDER];
        
        TouchSprite* circleSprite = [TouchSprite spriteWithImageNamed:imageNames[i]];
        circleSprite.name = [imageNames[i] componentsSeparatedByString:@"_"].firstObject;
        circleSprite.position = circlePositions[i];
        circleSprite.scale = 0.f;
        circleSprite.opacity = 0.f;
        circleSprite.userInteractionEnabled = NO;
        [_backgroundNode addChild:circleSprite z:TITLEORDER];
        
        __unsafe_unretained CCSprite* bigCircleTemp = bigCircle;
        [circleSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.5f], [CCActionSpawn actions:[CCActionScaleTo actionWithDuration:3.f scale:1.f], [CCActionFadeTo actionWithDuration:3.f opacity:1.f], nil], [CCActionCallBlock actionWithBlock:^{
            circleSprite.userInteractionEnabled = YES;
            bigCircleTemp.opacity = 1.f;
            bigCircleTemp.scale = 0.8f;
            [bigCircleTemp runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionSpawn actions:[CCActionFadeOut actionWithDuration:1.5f], [CCActionScaleTo actionWithDuration:1.5f scale:1.3f], nil], [CCActionDelay actionWithDuration:0.2f], [CCActionCallBlock actionWithBlock:^{
                bigCircleTemp.opacity = 1.f;
                bigCircleTemp.scale = 0.8f;
            }], nil]]];
        }], nil]];
        
        __unsafe_unretained TouchSprite* circleSpriteTemp = circleSprite;
        __unsafe_unretained ContentScene* weakSelf = self;
        circleSprite.touchBegan = ^(UITouch* touch){
            circleSpriteTemp.userInteractionEnabled = NO;
            [circleSpriteTemp runAction:[ActionProvider getPressBeginAction]];
        };
        
        circleSprite.touchEnded = ^(UITouch* touch){
            if (CGRectContainsPoint(circleSpriteTemp.boundingBox, [touch locationInWorld])) {
                if(weakSelf.isTouching){
                    return;
                }
                weakSelf.isTouching = YES;
                [circleSpriteTemp runAction:[ActionProvider getPressEndAction]];
                if ([circleSpriteTemp.name isEqualToString:@"secret"]) {
                    [[CCDirector sharedDirector] replaceScene:[PuzzleScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
                }
                else{
                    [[CCDirector sharedDirector] replaceScene:[FishLivingEnvironmentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
                }
            }
            else{
                circleSpriteTemp.userInteractionEnabled = YES;
                [circleSpriteTemp runAction:[ActionProvider getPressEndAction]];
            }
        };
        
        circleSprite.touchCanceled = ^(UITouch* touch){
            circleSpriteTemp.userInteractionEnabled = YES;
            weakSelf.isTouching = NO;
            [circleSpriteTemp runAction:[ActionProvider getPressEndAction]];
        };
    }
}

-(void)longPressHandle:(UILongPressGestureRecognizer* )longPress{
    NSLog(@"ok~~");
    GestureSprite* parent = (GestureSprite* )[_backgroundNode getChildByName:@"parent" recursively:NO];
    parent.userInteractionEnabled = NO;
    [parent removeGesture:longPress];
    [[CCDirector sharedDirector] replaceScene:[ParentControlScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
}


-(void)onExit{
    [_backgroundNode removeAllChildren];
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}









@end
