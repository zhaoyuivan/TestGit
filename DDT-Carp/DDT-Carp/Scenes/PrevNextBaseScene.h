//
//  PrevNextBaseScene.h
//  DDT-Carp
//
//  Created by Z on 15/1/20.
//  Copyright (c) 2015年 DDTown. All rights reserved.
//

#import "CCScene.h"
#import "cocos2d-ui.h"
#import "cocos2d.h"

@interface PrevNextBaseScene : CCScene
@property (nonatomic, strong) CCButton* prevButton;
@property (nonatomic, strong) CCButton* nextButton;
@property (nonatomic, strong) CCButton* homeButton;
@property (nonatomic) int step;
@property (nonatomic) BOOL showWords;
@property (nonatomic, copy) NSString* currentScene;
@property (nonatomic, copy) NSString* imageSuffix;
@property (nonatomic) CGPoint wordsOffset;
-(void)prevPress:(CCButton* )button;
-(void)nextPress:(CCButton* )button;
-(void)homePress:(CCButton* )button;
-(void)handleButtons:(BOOL)isEnabled;
-(void)createScene;
-(void)createWordsPrompt;
@end
