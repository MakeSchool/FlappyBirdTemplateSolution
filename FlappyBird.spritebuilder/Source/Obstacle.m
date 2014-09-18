//
//  Obstacle.m
//  FlappyBird
//
//  Created by Benjamin Encz on 10/02/14.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "Obstacle.h"
#import "Goal.h"

@implementation Obstacle {
  CCNode *_topPipe;
  CCNode *_bottomPipe;
}

#define ARC4RANDOM_MAX      0x100000000

// visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
static const CGFloat minimumYPosition = 200.f;
// visibility ends at 480 and we want some meat
static const CGFloat maximumYPosition = 380.f;

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.contentSize = CGSizeMake(80.0f, 825.0f);
        self.anchorPoint = ccp(0.5f, 0.47f);
        
        //  Create top and bottom pipes
        
        _topPipe = [CCSprite spriteWithImageNamed:@"FlappyBirdArtPack/pipe_top.png"];
        _bottomPipe = [CCSprite spriteWithImageNamed:@"FlappyBirdArtPack/pipe_bottom.png"];
        
        _topPipe.anchorPoint = ccp(0.5f, 1.0f);
        _bottomPipe.anchorPoint = ccp(0.5f, 0.0f);
        
        _topPipe.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
        _topPipe.position = ccp(40.0f, 0.0f);
        _bottomPipe.position = ccp(40.0f, 0.0f);
        
        _topPipe.scaleY = 1.38f;
        _bottomPipe.scaleY = 1.38f;
        
        // Add physics to top and bottom pipes
        
        CGRect pipePhysicsRect = CGRectMake(0.0f, 0.0f, 53.0f, 253.0f);
        CCPhysicsBody* topPipePhysicsBody = [CCPhysicsBody bodyWithRect:pipePhysicsRect cornerRadius:0.0f];
        CCPhysicsBody* bottomPipePhysicsBody = [CCPhysicsBody bodyWithRect:pipePhysicsRect cornerRadius:0.0f];
        
        topPipePhysicsBody.type = CCPhysicsBodyTypeStatic;
        bottomPipePhysicsBody.type = CCPhysicsBodyTypeStatic;
        
        topPipePhysicsBody.collisionType = @"level";
        topPipePhysicsBody.sensor = YES;
        
        bottomPipePhysicsBody.collisionType = @"level";
        bottomPipePhysicsBody.sensor = YES;
        
        _topPipe.physicsBody = topPipePhysicsBody;
        _bottomPipe.physicsBody = bottomPipePhysicsBody;
        
        [self addChild:_topPipe];
        [self addChild:_bottomPipe];
        
        // Create goal node
        CCNode* goalNode = [Goal node];
        goalNode.scaleX = 1.156f;
        goalNode.scaleY = 1.327f;
        goalNode.anchorPoint = ccp(0.0f, 0.0f);
        goalNode.position = ccp(22.0f, -1.0f);
        [self addChild:goalNode];
    }
    
    return self;
}

- (void)setupRandomPosition {
  // value between 0.f and 1.f
  CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
  CGFloat range = maximumYPosition - minimumYPosition;
  self.position = ccp(self.position.x, minimumYPosition + (random * range));
}

@end