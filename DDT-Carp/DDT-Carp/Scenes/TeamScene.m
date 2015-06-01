//
//  TeamScene.m
//  DDT-Carp
//
//  Created by Z on 15/1/13.
//  Copyright (c) 2015年 DDTown. All rights reserved.
//

#import "TeamScene.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "TouchSprite.h"
#import "CCTextureCache.h"
#import "FishSwimSprite.h"

#import "ContentScene.h"

@implementation TeamScene
+(TeamScene* )scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createBackground];
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    
}

-(void)createBackground{
    CCSprite* bg = [CCSprite spriteWithImageNamed:@"bg_team.png"];
    bg.anchorPoint = ccp(0, 0);
    bg.position = ccp(0, 0);
    [self addChild:bg z:1];
    
    CCSprite* water = [CCSprite spriteWithImageNamed:@"water_team.png"];
    water.anchorPoint = ccp(0, 0);
    water.position = ccp(0, 0);
    [self addChild:water z:1];
    
    FishSwimSprite* fish = [[FishSwimSprite alloc] initWithImageNamed:@"fish1_animation.png" andSwimRect:(CGRect){0, 0, 1024, 136} andFaceTo:left];
    fish.position = ccp(1024 + fish.contentSize.width/2.f, 120);
    fish.showAnimation = YES;
    fish.animationCount = 3;
    fish.animationDelayTime = 1/6.f;
    fish.animationFileName = @"fish";
    fish.animationFileSuffix = @"_animation";
    fish.userInteractionEnabled = YES;
    [self addChild:fish z:1];
    
//    home
    TouchSprite* homeSprite = [TouchSprite spriteWithImageNamed:@"home.png"];
    homeSprite.anchorPoint = ccp(0, 1);
    homeSprite.position = ccp(15.5, 768 - 18.5);
    homeSprite.userInteractionEnabled = YES;
    __unsafe_unretained TouchSprite* homeSpriteTemp = homeSprite;
    homeSprite.touchBegan = ^(UITouch* touch){
        homeSpriteTemp.userInteractionEnabled = NO;
        [[CCDirector sharedDirector] replaceScene:[ContentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
    };
    [self addChild:homeSprite z:1000];
    
//    team
    CGPoint teamPositions[] = {ccp(522/2.f, 768 - 543/2.f), ccp(995/2.f, 768 - 545/2.f), ccp(1468/2.f, 768 - 519/2.f), ccp(755/2.f, 768 - 984/2.f), ccp(1227/2.f, 768 - 983/2.f)};
    NSArray* imageNames = @[@"chu", @"33", @"ji", @"dai", @"roshan"];
    CGPoint posPositions[] = {ccp(532/2.f, 768 - 786/2.f), ccp(991/2.f, 768 - 786/2.f), ccp(1471/2.f, 768 - 786/2.f), ccp(765/2.f, 768 - 1245/2.f), ccp(1239/2.f, 768 - 1247/2.f)};
    NSArray* positionNames = @[@"author", @"product", @"author", @"art", @"code"];
    for (int i = 0; i < imageNames.count; i++) {
        CCSprite* positionSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@_team.png", positionNames[i]]];
        positionSprite.position = ccpAdd(posPositions[i], ccp(0, 120));
        [self addChild:positionSprite z:9];
        
        TouchSprite* team = [TouchSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@_team.png", imageNames[i]]];
        team.position = teamPositions[i];
        team.userInteractionEnabled = YES;
        [self addChild:team z:10];
        __block CGPoint endPoint = posPositions[i];
        __unsafe_unretained TouchSprite* teamTemp = team;
        __unsafe_unretained CCSprite* posSpriteTemp = positionSprite;
        team.touchBegan = ^(UITouch* touch){
            teamTemp.userInteractionEnabled = NO;
            [posSpriteTemp runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.3f position:ccpAdd(ccp(0, (posSpriteTemp.position.y > endPoint.y ? 0 : 120 )), endPoint)], [CCActionCallBlock actionWithBlock:^{
                teamTemp.userInteractionEnabled = YES;
            }], nil]];
        };

    }
}






-(void)onExit{
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}

-(void)dealloc{
    
}

@end
