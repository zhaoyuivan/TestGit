//
//  ParentControlScene.m
//  DDT-XPY
//
//  Created by Z on 14/11/17.
//  Copyright (c) 2014年 DodoTown. All rights reserved.
//

#import "ParentControlScene.h"
#import "cocos2d.h"
#import "TouchSprite.h"
#import "CCTextureCache.h"
#import <StoreKit/StoreKit.h>
#import "FishSwimSprite.h"

#import "ContentScene.h"

@interface ParentControlScene ()<SKStoreProductViewControllerDelegate>
{
    
}
@end

@implementation ParentControlScene
+(ParentControlScene *)scene{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createBackground];
}

-(void)createBackground{
    CCSprite* bgSprite = [CCSprite spriteWithImageNamed:@"bg_parent.png"];
    bgSprite.anchorPoint = ccp(0, 0);
    bgSprite.position = ccp(0, 0);
    [self addChild:bgSprite z:1];
    
    CCSprite* wordSprite = [CCSprite spriteWithImageNamed:@"word_parent.png"];
    wordSprite.anchorPoint = ccp(0, 0);
    wordSprite.position = ccp(0, 0);
    [self addChild:wordSprite z:1];
    
    CCSprite* waterSprite = [CCSprite spriteWithImageNamed:@"water_parent.png"];
    waterSprite.anchorPoint = ccp(0, 0);
    waterSprite.position = ccp(0, 0);
    [self addChild:waterSprite z:1];
    
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
    
//    score
    TouchSprite* scoreSprite = [TouchSprite spriteWithImageNamed:@"score_parent.png"];
    scoreSprite.anchorPoint = ccp(0.5f, 0.5f);
    scoreSprite.position = ccp(702/2.f, 768 - 1090/2.f);
    [self addChild:scoreSprite z:10];
    scoreSprite.userInteractionEnabled = YES;
    __unsafe_unretained ParentControlScene* weakSelf = self;
    __unsafe_unretained TouchSprite* scoreSpriteTemp = scoreSprite;
    scoreSprite.touchBegan = ^(UITouch* touch){
        [scoreSpriteTemp runAction:[ActionProvider getPressBeginAction]];
        scoreSpriteTemp.userInteractionEnabled = NO;
    };
    
    scoreSprite.touchEnded = ^(UITouch* touch){
        [scoreSpriteTemp runAction:[ActionProvider getPressEndAction]];
        [weakSelf goToScore];
        scoreSpriteTemp.userInteractionEnabled = YES;
    };
    
//    url
    TouchSprite* urlSprite = [TouchSprite spriteWithImageNamed:@"url_parent.png"];
    urlSprite.anchorPoint = ccp(0.5f, 0.5f);
    urlSprite.position = ccp(988/2.f, 768 - 1388/2.f);
    [self addChild:urlSprite z:10];
    urlSprite.userInteractionEnabled = YES;
    __unsafe_unretained TouchSprite* urlSpriteTemp = urlSprite;
    urlSprite.touchBegan = ^(UITouch* touch){
        [urlSpriteTemp runAction:[ActionProvider getPressBeginAction]];
        urlSpriteTemp.userInteractionEnabled = NO;
    };
    
    urlSprite.touchEnded = ^(UITouch* touch){
        [urlSpriteTemp runAction:[ActionProvider getPressEndAction]];
        [weakSelf goToURL];
        urlSpriteTemp.userInteractionEnabled = YES;
    };
    
//    email
    TouchSprite* emailSprite = [TouchSprite spriteWithImageNamed:@"email_parent.png"];
    emailSprite.anchorPoint = ccp(0.5f, 0.5f);
    emailSprite.position = ccp(1029/2.f, 768 - 1310/2.f);
    [self addChild:emailSprite z:10];
    emailSprite.userInteractionEnabled = YES;
    __unsafe_unretained TouchSprite* emailSpriteTemp = emailSprite;
    emailSprite.touchBegan = ^(UITouch* touch){
        [emailSpriteTemp runAction:[ActionProvider getPressBeginAction]];
        emailSpriteTemp.userInteractionEnabled = NO;
    };
    
    emailSprite.touchEnded = ^(UITouch* touch){
        [emailSpriteTemp runAction:[ActionProvider getPressEndAction]];
        [weakSelf sendEmail];
        emailSpriteTemp.userInteractionEnabled = YES;
    };
    
}

-(void)goToScore{
//    NSString *evaluateString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",
////                                @"587767923"];
//                                @"346703830"];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
    SKStoreProductViewController* storeProductViewController = [[SKStoreProductViewController alloc] init];
    storeProductViewController.delegate = self;
    [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : @"346703830"} completionBlock:^(BOOL result, NSError *error) {
        if (error) {
            NSLog(@"error - %@ with userInfo : %@", error, [error userInfo]);
        }
        else{
            [[CCDirector sharedDirector].navigationController presentViewController:storeProductViewController animated:YES completion:^{
                
            }];
        }
    }];
}

-(void)goToURL{
    NSURL* url = [[NSURL alloc] initWithString:@"http://www.dudutang.com"];
    [[ UIApplication sharedApplication]openURL:url];
}

-(void)sendEmail{
    NSString* str = @"mailto:contact@dudutang.com?cc=contact@dudutang.com&subject=&body=";
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString: str];
    [[UIApplication sharedApplication] openURL: url];
}

//取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}



-(void)onExit{
    [self removeAllChildren];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [super onExit];
}
@end
