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
        self.anchorPoint = ccp(0.5f, 0.5f);
        self.position = ccp(115, 250);
        self.zOrder = DrawingOrderHero;
        
        // Set up physics
        CCPhysicsBody* characterPhysicsBody = [CCPhysicsBody bodyWithCircleOfRadius:15.0f andCenter:ccp(17.0f, 12.0f)];
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

- (void)onExit
{
    [self stopAllActions];
    
    [super onExit];
}

- (void)createAndRunFlappyAnimation
{
    CCSpriteFrame* fly1 = [CCSpriteFrame frameWithImageNamed:@"FlappyBirdArtPack/fly1.png"];
    CCSpriteFrame* fly2 = [CCSpriteFrame frameWithImageNamed:@"FlappyBirdArtPack/fly2.png"];
    CCAnimation* flappyAnimation = [CCAnimation animationWithSpriteFrames:@[fly1, fly2] delay:0.16666f];
    CCActionInterval* animationAction = [CCActionAnimate actionWithAnimation:flappyAnimation];
    CCActionInterval* loopAnimation = [CCActionRepeatForever actionWithAction:animationAction];
    [self runAction:loopAnimation];
}

@end
