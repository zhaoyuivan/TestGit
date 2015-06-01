//
//  FishSwimSprite.h
//  DDT-Carp
//
//  Created by Z on 14/12/31.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "TouchSprite.h"

typedef enum faceToDirection{
    left,
    right
}FaceTo;

typedef enum species{
    catfish,
    blackCarp,
    carp
}FishSpecies;

@interface FishSwimSprite : TouchSprite
@property (nonatomic) int bezierMoveCount;
@property (nonatomic) BOOL isFlipX;
@property (nonatomic) CGRect swimRange;
@property (nonatomic) FaceTo direction;
@property (nonatomic) BOOL isLockBezierMoveCount;
@property (nonatomic) CGPoint touchBeganPosition;
@property (nonatomic) FishSpecies species;
@property (nonatomic) BOOL isCrashing;
@property (nonatomic) BOOL showAnimation;
@property (nonatomic) int animationCount;
@property (nonatomic) CGFloat animationDelayTime;
@property (nonatomic, copy) NSString* animationFileName;
@property (nonatomic, copy) NSString* animationFileSuffix;
@property (nonatomic) BOOL isNeedConvertPosition;
-(id)initWithImageNamed:(NSString *)imageName andSwimRect:(CGRect)swimRange;
-(id)initWithImageNamed:(NSString *)imageName andSwimRect:(CGRect)swimRange andFaceTo:(FaceTo)direction;
-(id)initWithImageNamed:(NSString *)imageName andSwimRect:(CGRect)swimRange andFaceTo:(FaceTo)direction andSpecies:(FishSpecies)species;
@end
