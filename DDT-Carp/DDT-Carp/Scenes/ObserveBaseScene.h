//
//  ObserveBaseScene.h
//  DDT-Carp
//
//  Created by Z on 15/2/3.
//  Copyright (c) 2015年 ZY. All rights reserved.
//

#import "PrevNextBaseScene.h"
#import "TouchSprite.h"

@interface ObserveBaseScene : PrevNextBaseScene
@property (nonatomic, strong) CCNode* backgroundNode;
@property (nonatomic, strong) TouchSprite* observerSprite;
@property (nonatomic, copy) NSString* observedName;
@property (nonatomic) int observedCount;
@property (nonatomic, strong) NSArray* observedPositions;
@property (nonatomic, strong) NSMutableArray* observedSpriteArray;
-(void)createObservedSprite;
@end
