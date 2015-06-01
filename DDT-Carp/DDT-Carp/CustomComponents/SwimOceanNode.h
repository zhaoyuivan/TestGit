//
//  SwimOceanNode.h
//  WaterRoute
//
//  Created by Joe on 14-9-2.
//  Copyright 2014年 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCShader.h"
#import "CCNode_Private.h"

@interface SwimOceanNode : CCSprite
@property (nonatomic) BOOL isStartShake;
-(instancetype)initWithImageNamed:(NSString *)imageName andTexture:(CCTexture *)texture;

@end
