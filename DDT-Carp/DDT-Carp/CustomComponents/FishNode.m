//
//  FishNode.m
//  DDT-Carp
//
//  Created by Z on 14/12/9.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "FishNode.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface FishNode ()

@end

@implementation FishNode
- (instancetype)init
{
    return [self initWithFishInfo:nil isUsePhysics:YES];
}

-(id)initWithFishInfo:(NSDictionary *)fishInfo{
    return [self initWithFishInfo:fishInfo isUsePhysics:YES];
}

-(id)initWithFishInfo:(NSDictionary *)fishInfo isUsePhysics:(BOOL)isPhysics{
    if (self = [super init]) {
        self.fishInfo = fishInfo;
        self.allFlipX = NO;
        self.isUsePhysics = isPhysics;
        [self createFishSchool];
    }
    return self;
}

-(void)setAllFlipX:(BOOL)allFlipX{
    if (_allFlipX == allFlipX) {
        return;
    }
    _allFlipX = allFlipX;
    for (CCSprite* fish in self.children) {
        [fish runAction:[CCActionFlipX actionWithFlipX:_allFlipX]];
    }
}

//-(void)setOpacity:(CGFloat)opacity{
//    self.opacity = opacity;
//    for (CCSprite* fish in self.children) {
//        fish.opacity = opacity;
//    }
//}

-(void)createFishSchool{
    if (!self.fishInfo) {
        return;
    }
    NSMutableArray* shapes = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.fishInfo[@"count"] intValue]; i++) {
        CCSprite* fishSprite = [CCSprite spriteWithImageNamed:self.fishInfo[@"image"]];
        NSArray* position = [self.fishInfo[@"position"] componentsSeparatedByString:@","];
        NSArray* fishPositions = self.fishInfo[@"fishPositions"];
        CGPoint fishPoint = ccp([[fishPositions[i] componentsSeparatedByString:@","][0] doubleValue], [[fishPositions[i] componentsSeparatedByString:@","][1] doubleValue]);
        self.position = ccp([position[0] doubleValue], [position[1] doubleValue]);
        fishSprite.position = fishPoint;
        NSArray* fishScales = self.fishInfo[@"fishScales"];
        fishSprite.scale = [fishScales[i] doubleValue];
        [self addChild:fishSprite];
        
        if (self.isUsePhysics) {
            NSDictionary* fishPhysices = self.fishInfo[@"physics"];
            NSString* shape = fishPhysices[@"shape"];
            CCPhysicsShape* fishShape = nil;
            if ([shape isEqualToString:@"rect"]) {
                fishShape = [CCPhysicsShape rectShape:fishSprite.boundingBox cornerRadius:0];
            }
            else if([shape isEqualToString:@"circle"]){
                fishShape = [CCPhysicsShape circleShapeWithRadius:[fishPhysices[@"radius"] doubleValue] center:fishSprite.position];
            }
            [shapes addObject:fishShape];
        }
    }
    if (self.isUsePhysics) {
        self.physicsBody = [CCPhysicsBody bodyWithShapes:shapes];
        self.physicsBody.type = CCPhysicsBodyTypeKinematic;
        self.physicsBody.collisionType = @"fishNode";
        self.physicsBody.friction = 0.f;
        self.physicsBody.elasticity = 0.f;
    }
    [shapes removeAllObjects];
}

-(void)onExit{
    
    [super onExit];
}
@end
