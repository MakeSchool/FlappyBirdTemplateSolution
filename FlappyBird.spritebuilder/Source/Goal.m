//
//  Goal.m
//  FlappyBird
//
//  Created by Benjamin Encz on 10/02/14.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "Goal.h"

@implementation Goal

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.contentSize = CGSizeMake(30.0f, 600.0f);
        
        CGRect goalPhysicsRect = CGRectMake(0.0f, 0.0f, 30.0f, 600.0f);
        CCPhysicsBody* goalPhysicsBody = [CCPhysicsBody bodyWithRect:goalPhysicsRect cornerRadius:0.0f];
        self.physicsBody = goalPhysicsBody;
        self.physicsBody.type = CCPhysicsBodyTypeStatic;
        self.physicsBody.collisionType = @"goal";
        self.physicsBody.sensor = YES;
    }
    
    return self;
}

@end
