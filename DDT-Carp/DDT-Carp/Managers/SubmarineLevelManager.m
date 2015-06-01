//
//  SubmarineLevelManager.m
//  DDT-Carp
//
//  Created by Z on 14/12/9.
//  Copyright (c) 2014年 DDTown. All rights reserved.
//

#import "SubmarineLevelManager.h"

@implementation SubmarineLevelManager
static SubmarineLevelManager* submarineManager = nil;
+(SubmarineLevelManager *)sharedSubmarineManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!submarineManager) {
            submarineManager = [[self alloc] init];
        }
    });
    return submarineManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.levelInfo = nil;
    }
    return self;
}

-(void)loadLevelInfo{
    if (self.levelInfo) {
        self.levelInfo = nil;
    }
    NSString* path = [[NSBundle mainBundle] pathForResource:@"submarineLevels.plist" ofType:nil];
    self.levelInfo = [NSDictionary dictionaryWithContentsOfFile:path];
//    NSLog(@"%@", self.levelInfo);
}

-(void)purgeSubmarineLevelManager{
    submarineManager = nil;
}
@end
