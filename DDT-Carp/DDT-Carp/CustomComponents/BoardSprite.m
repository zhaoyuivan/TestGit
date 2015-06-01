//
//  BoardSprite.m
//  DDT-Carp
//
//  Created by Z on 14/10/28.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "BoardSprite.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"
#import "CCAnimation+Helper.h"
#import "TouchSprite.h"

@implementation BoardSprite
+(BoardSprite *)spriteWithTitleImageString:(NSString *)titleImage andGoNextImageString:(NSString *)goNextImage{
    BoardSprite* boardSprite = [BoardSprite spriteWithImageNamed:@"board_board_puzzle.png"];
    boardSprite.position = ccp(1028.5/2, 768 - 849/2);
    boardSprite.name = @"board";
    [boardSprite showBoardWithBoardSprite:boardSprite andTitleImage:titleImage andGoNextImage:goNextImage];
    return boardSprite;
}

-(void)showBoardWithBoardSprite:(BoardSprite* )boardSprite andTitleImage:(NSString* )titleImage andGoNextImage:(NSString *)goNextImage{
//    little carp
    CCSprite* littleCarpSprite = [CCSprite spriteWithImageNamed:@"little_carp_puzzle.png"];
    littleCarpSprite.anchorPoint = ccp((1224/2 - (1425.5/2 - littleCarpSprite.contentSize.width/2))/littleCarpSprite.contentSize.width, (768 - 727/2 - (768 - 662.5/2 - littleCarpSprite.contentSize.height/2))/littleCarpSprite.contentSize.height);
    littleCarpSprite.position = [boardSprite convertToNodeSpace:ccp(1224/2, 768 - 727/2)];
    [boardSprite addChild:littleCarpSprite z:1];
    
//    go in / out
    CCSprite* goOutSprite = [CCSprite spriteWithImageNamed:@"go_out1_puzzle.png"];
    goOutSprite.position = [boardSprite convertToNodeSpace:ccp(1412/2, 768 - 610/2)];
    goOutSprite.opacity = 0;
    [boardSprite addChild:goOutSprite z:1];
    CCAnimation* goOutAnimation = [CCAnimation animationWithFile:@"go_out" withSuffix:@"_puzzle" frameCount:2 delay:0.1f];
    
    CCSprite* goInSprite = [CCSprite spriteWithImageNamed:@"go_in1_puzzle.png"];
    goInSprite.position = [boardSprite convertToNodeSpace:ccp(1070.5/2, 768 - 577.5/2)];
    goInSprite.opacity = 0;
    [boardSprite addChild:goInSprite z:1];
    CCAnimation* goInAnimation = [CCAnimation animationWithFile:@"go_in" withSuffix:@"_puzzle" frameCount:3 delay:0.1f];
    
//    water
    CCSprite* waterSprite = [CCSprite spriteWithImageNamed:@"water_puzzle.png"];
    waterSprite.position = [boardSprite convertToNodeSpace:ccp(1030.5/2, 768 - 912/2)];
    [boardSprite addChild:waterSprite z:2];
    
//    title
    CCSprite* titleSprite = [CCSprite spriteWithImageNamed:titleImage];
    titleSprite.position = [boardSprite convertToNodeSpace:ccp(1039.5/2, 768 - 820.5/2)];
    [boardSprite addChild:titleSprite z:3];
    
//    coral
    CCSprite* coralSprite = [CCSprite spriteWithImageNamed:@"coral_puzzle.png"];
    coralSprite.position = [boardSprite convertToNodeSpace:ccp(1035/2, 768 - 696.5/2)];
    coralSprite.scale = 0.5;
    [boardSprite addChild:coralSprite z:-1];
    
//    plant
    CCSprite* plantsSprite = [CCSprite spriteWithImageNamed:@"plants_puzzle.png"];
    plantsSprite.position = [boardSprite convertToNodeSpace:ccp(1018.5/2, 768 - 731/2)];
    plantsSprite.scale = 0.5;
    [boardSprite addChild:plantsSprite z:-2];
    
    CCSprite* plantOneSprite = [CCSprite spriteWithImageNamed:@"plant1_puzzle.png"];
    plantOneSprite.position = [boardSprite convertToNodeSpace:boardSprite.position];
    [boardSprite addChild:plantOneSprite z:-3];
    
    CCSprite* plantTwoSprite = [CCSprite spriteWithImageNamed:@"plant2_puzzle.png"];
    plantTwoSprite.position = [boardSprite convertToNodeSpace:boardSprite.position];
    [boardSprite addChild:plantTwoSprite z:-3];
    //    [CCActionMoveTo actionWithDuration:0.5f position:ccp(1028.5/2, 768 - 849/2 + 100)], [CCActionDelay actionWithDuration:0.f], [CCActionMoveBy actionWithDuration:0.1f position:ccp(0, -100)],
    boardSprite.position = ccp(1028.5/2, -boardSprite.contentSize.height/2);
    [boardSprite runAction:[CCActionSequence actions:[CCActionJumpTo actionWithDuration:0.8f position:ccp(1028.5/2, 768 - 849/2) height:768 - 849/2 + 20 jumps:1], [CCActionCallBlock actionWithBlock:^{
        [coralSprite runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:0.8f scale:1.1], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.2f scale:1], [CCActionCallBlock actionWithBlock:^{
            
        }], nil]];
        [plantsSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.4f],[CCActionScaleTo actionWithDuration:0.8f scale:1.1], [CCActionDelay actionWithDuration:0.f], [CCActionScaleTo actionWithDuration:0.2f scale:1], nil]];
        [plantOneSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.6f], [CCActionMoveTo actionWithDuration:0.8f position:[boardSprite convertToNodeSpace:ccp(1695/2, 768 - 368/2)]], nil]];
        [plantTwoSprite runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.6f], [CCActionMoveTo actionWithDuration:0.8f position:[boardSprite convertToNodeSpace:ccp(287.5/2, 768 - 578.5/2)]], [CCActionCallBlock actionWithBlock:^{
            [littleCarpSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:5.f angle:-360]]];
            [goOutSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.3f], [CCActionFadeTo actionWithDuration:0.f opacity:1], [CCActionAnimate actionWithAnimation:goOutAnimation], [CCActionFadeTo actionWithDuration:0.f opacity:0], [CCActionDelay actionWithDuration:4.5f], nil]]];
            [goInSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:1.65f], [CCActionFadeTo actionWithDuration:0.f opacity:1], [CCActionAnimate actionWithAnimation:goInAnimation], [CCActionFadeTo actionWithDuration:0.f opacity:0], [CCActionDelay actionWithDuration:3.05f], nil]]];
            [boardSprite setQuestionBoardWithBoardSprite:boardSprite andGoNextImage:goNextImage];
        }], nil]];
    }], nil]];
}

-(void)setQuestionBoardWithBoardSprite:(BoardSprite* )boardSprite andGoNextImage:(NSString* )goNextImage{
    if (boardSprite.beforeGoDownBlock) {
        boardSprite.beforeGoDownBlock();
    }
//    go
//    TouchSprite* goSprite = [TouchSprite spriteWithImageNamed:goNextImage];
//    goSprite.position = ccp(1879/2, 768 - 1379/2);
//    goSprite.userInteractionEnabled = YES;
//    goSprite.opacity = 0;
//    [boardSprite.parent addChild:goSprite z:1000];
//    
//    [goSprite runAction:[CCActionFadeTo actionWithDuration:2.f opacity:1]];
//    
//    __unsafe_unretained TouchSprite* goSpriteTemp = goSprite;
//    __unsafe_unretained BoardSprite* boardSpriteTemp = boardSprite;
//    goSprite.touchBegan = ^(UITouch* touch){
//        goSpriteTemp.userInteractionEnabled = NO;
//        [goSpriteTemp stopAllActions];
//        [goSpriteTemp runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0], [CCActionCallBlock actionWithBlock:^{
//            [goSpriteTemp removeFromParent];
//        }], nil]];
//        [boardSpriteTemp runAction:[CCActionSequence actions:[CCActionJumpTo actionWithDuration:1.f position:ccp(1028.5/2, -2 * boardSpriteTemp.contentSize.height/2) height:768 - 849/2 + 20 jumps:1], [CCActionCallBlock actionWithBlock:^{
//            if (boardSpriteTemp.afterGoDownBlock) {
//                boardSpriteTemp.afterGoDownBlock();
//            }
//            [boardSpriteTemp removeAllChildren];
//            [boardSpriteTemp removeFromParent];
//        }], nil]];
//    };
//    [boardSprite performSelector:@selector(goSpritePrompt:) withObject:goSprite afterDelay:6.f];
}

-(void)getGoNextHandle:(BoardSprite* )boardSprite{
//    goSprite.userInteractionEnabled = NO;
//    [goSprite stopAllActions];
//    [goSprite runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0], [CCActionCallBlock actionWithBlock:^{
//        [goSprite removeFromParent];
//    }], nil]];
    [boardSprite runAction:[CCActionSequence actions:[CCActionJumpTo actionWithDuration:1.f position:ccp(1028.5/2, -2 * boardSprite.contentSize.height/2) height:768 - 849/2 + 20 jumps:1], [CCActionCallBlock actionWithBlock:^{
        if (boardSprite.afterGoDownBlock) {
            boardSprite.afterGoDownBlock();
        }
        [boardSprite removeAllChildren];
        [boardSprite removeFromParent];
    }], nil]];
}

-(void)goSpritePrompt:(TouchSprite *)goSprite{
    if (goSprite.userInteractionEnabled) {
        [goSprite runAction:[ActionProvider getRepeatScalePrompt]];
    }
}
@end
