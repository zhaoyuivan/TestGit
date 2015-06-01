//
//  PrevNextBaseScene.m
//  DDT-Carp
//
//  Created by Z on 15/1/20.
//  Copyright (c) 2015年 DDTown. All rights reserved.
//

#import "PrevNextBaseScene.h"
#import "ContentScene.h"

#define MAXLENGTH 600.0
#define DEFAULTLENGTH 361.0

@interface PrevNextBaseScene ()
{
    
}
@end

@implementation PrevNextBaseScene
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createButtons];
        self.step = 1;
//        words
        self.wordsOffset = CGPointZero;
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    [self createWordsPrompt];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    if (self.showWords) {
        self.showWords = NO;
        self.userInteractionEnabled = NO;
        CCNode* wordsNode = [self getChildByName:@"wordsNode" recursively:NO];
        if (!wordsNode) {
            return;
        }
//        [wordsNode runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scale:0.f], [CCActionCallBlock actionWithBlock:^{
//            [wordsNode removeAllChildren];
//            [wordsNode removeFromParent];
//            self.homeButton.visible = YES;
//            self.nextButton.visible = YES;
//            self.prevButton.visible = YES;
//            [self createScene];
//        }], nil]];
        for (int i = 0; i < wordsNode.children.count; i++) {
            CCNode* tip = wordsNode.children[i];
            [tip runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:0.f], [CCActionCallBlock actionWithBlock:^{
                if (i == 1) {
                    self.homeButton.visible = YES;
                    self.nextButton.visible = YES;
                    self.prevButton.visible = YES;
                    [self createScene];
                }
                [tip removeFromParent];
            }], nil]];
        }
    }
}

-(void)createScene{
    NSLog(@"createScene");
}

-(void)createWordsPrompt{
    if ([_currentScene isEqualToString:@""] || _currentScene == nil) {
        return;
    }
//    words
    CCNode* wordsNode = [CCNode node];
    wordsNode.name = @"wordsNode";
    wordsNode.contentSize = [CCDirector sharedDirector].viewSize;
    wordsNode.anchorPoint = ccp(0.5f, 0.5f);
    wordsNode.position = ccp(512, 384);
    [self addChild:wordsNode z:10000];
    
    NSString* lineOne = [NSString stringWithFormat:@"%@_line1", _currentScene];
    lineOne = NSLocalizedString(lineOne, nil);
    NSString* lineTwo = [NSString stringWithFormat:@"%@_line2", _currentScene];
    lineTwo = NSLocalizedString(lineTwo, nil);
    NSString* fontSizeStr = [NSString stringWithFormat:@"%@_font_size", _currentScene];
    CGFloat fontSize = [NSLocalizedString(fontSizeStr, nil) doubleValue];
    NSString* letterWidthStr = [NSString stringWithFormat:@"%@_letter_width", _currentScene];
    CGFloat letterWidth = [NSLocalizedString(letterWidthStr, nil) doubleValue];
    CGFloat commonLength = DEFAULTLENGTH;
    //634
    if (lineOne.length * letterWidth + 20 > MAXLENGTH || lineTwo.length * letterWidth + 20 > MAXLENGTH) {
        commonLength = MAXLENGTH;
        CGFloat ratio = fontSize/letterWidth;
        letterWidth = (commonLength - 20)/MAX(lineTwo.length, lineOne.length);
        fontSize = letterWidth*ratio;
    }
    else if(lineOne.length * letterWidth + 20 > commonLength || lineTwo.length * letterWidth + 20 > commonLength){
        commonLength = MAX(lineTwo.length, lineOne.length) * letterWidth + 20;
    }
    NSLog(@"fontSize - %f, letterWidth - %f", fontSize, letterWidth);
    
    CCLabelTTF* promptLineOne = [CCLabelTTF labelWithString:lineOne fontName:@"STYuanti-SC-Regular" fontSize:fontSize dimensions:CGSizeZero];
    CCLabelTTF* promptLineTwo = [CCLabelTTF labelWithString:lineTwo fontName:@"STYuanti-SC-Regular" fontSize:fontSize dimensions:CGSizeZero];
    promptLineOne.color = [CCColor whiteColor];
    promptLineTwo.color = [CCColor whiteColor];
    promptLineOne.position = ccp(512, 489);
    promptLineTwo.position = ccp(512, 405.5f);
    [wordsNode addChild:promptLineOne z:2];
    [wordsNode addChild:promptLineTwo z:2];
    
    CGFloat y[] = {489.f, 405.5f};
    for(int i = 0; i < 2; i++){
        CCSprite* banner = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"words_banner_%@.png", _imageSuffix]];
        banner.position = ccp(512, y[i]);
        banner.scaleX = (commonLength + (i == 0 ? 19 : 0))/2.f;
        [wordsNode addChild:banner z:1];
        NSLog(@"%f", banner.boundingBox.size.width);  //380 361
    }
    
    CGPoint positions[] = {ccp(481/2.f, 768 - 531/2.f), ccp(318.5f, 768 - 558/2.f), ccp(468/2.f, 768 - 752/2.f), ccp(1039.5/2.f, 768 - 913.5/2.f)};
    NSArray* images = @[@"fish", @"border", @"banner1", @"banner2"];
    for (int i = 0; i < 2 * images.count - 1; i++) {
        CCSprite* wordBg = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"words_%@_%@.png", images[i/2], _imageSuffix]];
        wordBg.flipX = i%2 ? YES : NO;
        [wordsNode addChild:wordBg z:1];
        wordBg.position = i%2 ? ccp(1024 - positions[i/2].x, positions[i/2].y) : positions[i/2];
        if (i != 2 * images.count - 1 - 1) {
            CGFloat offset = commonLength - 361;
            wordBg.position = ccp(wordBg.position.x + offset/2.f * (i%2 ? 1 : -1) , wordBg.position.y);
        }
    }
    
//    wordsNode.scaleX = 0.f;
    wordsNode.position = ccpSub(wordsNode.position, self.wordsOffset);
//    [wordsNode runAction:[CCActionSequence actions:[CCActionScaleTo actionWithDuration:1.f scaleX:1.f scaleY:1.f], [CCActionCallBlock actionWithBlock:^{
//        self.showWords = YES;
//        self.userInteractionEnabled = YES;
//    }], nil]];
    for (CCNode* tip in wordsNode.children) {
        tip.opacity = 0.f;
        [tip runAction:[CCActionSequence actions:[CCActionFadeTo actionWithDuration:1.f opacity:1.f], [CCActionCallBlock actionWithBlock:^{
            self.showWords = YES;
            self.userInteractionEnabled = YES;
        }], nil]];
    }
}

-(void)createButtons{
    _prevButton = [CCButton buttonWithTitle:nil spriteFrame:[CCSpriteFrame frameWithImageNamed:@"prev.png"]];
    _prevButton.position = ccp(107/2.f, 768 - 1416/2.f);
    [_prevButton setTarget:self selector:@selector(prevPress:)];
    [self addChild:_prevButton z:10000];
    
    _nextButton = [CCButton buttonWithTitle:nil spriteFrame:[CCSpriteFrame frameWithImageNamed:@"next.png"]];
    _nextButton.position = ccp(1936/2.f, 768 - 1416/2.f);
    [_nextButton setTarget:self selector:@selector(nextPress:)];
    [self addChild:_nextButton z:10000];
    
    _homeButton = [CCButton buttonWithTitle:nil spriteFrame:[CCSpriteFrame frameWithImageNamed:@"home.png"]];
    _homeButton.position = ccp(161/2, 768 - 142/2);
    [_homeButton setTarget:self selector:@selector(homePress:)];
    [self addChild:_homeButton z:10000];
}

-(void)prevPress:(CCButton* )button{
    NSLog(@"prev");
}

-(void)nextPress:(CCButton* )button{
    NSLog(@"next");
}

-(void)homePress:(CCButton *)button{
    button.enabled = NO;
    [[CCDirector sharedDirector] replaceScene:[ContentScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.f]];
}

-(void)handleButtons:(BOOL)isEnabled{
    self.prevButton.visible = isEnabled;
    self.prevButton.enabled = isEnabled;
//    [self.prevButton runAction:[CCActionFadeTo actionWithDuration:1.f opacity:0.f]];
    self.nextButton.visible = isEnabled;
    self.nextButton.enabled = isEnabled;
//    [self.nextButton runAction:[CCActionFadeTo actionWithDuration:1.f opacity:0.f]];
}

-(void)onExit{
   
    [super onExit];
}

-(void)dealloc{
    [self removeAllChildren];
    self.prevButton = nil;
    self.nextButton = nil;
    self.homeButton = nil;
}

@end
