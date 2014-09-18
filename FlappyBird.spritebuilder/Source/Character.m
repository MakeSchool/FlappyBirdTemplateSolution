//
//  Character.m
//  FlappyBird
//
//  Created by Gerald on 2/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Character.h"
#import "MainScene.h"
#import "CCAnimation.h"

@implementation Character

+ (Character *)createFlappy
{
    return [[Character alloc] initWithImageNamed:@"FlappyBirdArtPack/fly1.png"];
}

- (instancetype)initWithImageNamed:(NSString *)imageName
{
    self = [super initWithImageNamed:imageName];
    
    if (self)
    {
        self.position = ccp(115, 250);
        self.zOrder = DrawingOrderHero;
        
        // Set up physics
        CGRect characterBodyShape = CGRectMake(0.0f, 0.0f, 23.0f, 33.0f);
        CCPhysicsBody* characterPhysicsBody = [CCPhysicsBody bodyWithRect:characterBodyShape cornerRadius:0.0f];
        self.physicsBody = characterPhysicsBody;
        self.physicsBody.collisionType = @"character";
        self.physicsBody.density = 1.0f;
        self.physicsBody.friction = 0.3f;
        self.physicsBody.elasticity = 0.3f;
        self.physicsBody.allowsRotation = YES;
        self.physicsBody.affectedByGravity = YES;
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [self createAndRunFlappyAnimation];
}

- (void)flap
{
    [self.physicsBody applyImpulse:ccp(0, 400.f)];
}

- (void)move
{
    self.physicsBody.velocity = ccp(80, self.physicsBody.velocity.y);
}

- (void)createAndRunFlappyAnimation
{
    CCSpriteFrame* fly1 = [CCSpriteFrame frameWithImageNamed:@"FlappyBirdArtPack/fly1.png"];
    CCSpriteFrame* fly2 = [CCSpriteFrame frameWithImageNamed:@"FlappyBirdArtPack/fly2.png"];
    CCAnimation* flappyAnimation = [CCAnimation animationWithSpriteFrames:@[fly1, fly2] delay:0.3333f];
    [self runAction:[CCActionAnimate actionWithAnimation:flappyAnimation]];
}

@end
