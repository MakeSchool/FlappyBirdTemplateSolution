//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Benjamin Encz on 10/10/13.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "MainScene.h"
#import "Obstacle.h"

@implementation MainScene {
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
    NSTimeInterval _sinceTouch;
    
    NSMutableArray *_obstacles;
    NSMutableArray *powerups;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_nameLabel;
}

-(void) addToScene:(CCNode *)node
{
    [physicsNode addChild:node];
}

-(void) showScore
{
    _scoreLabel.visible = YES;
}

-(void) updateScore
{
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
}

- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    
    _grounds = @[_ground1, _ground2];
    
    for (CCNode *ground in _grounds) {
        // set collision txpe
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    
    // set this class as delegate
    physicsNode.collisionDelegate = self;
    
    _obstacles = [NSMutableArray array];
    powerups = [NSMutableArray array];
    points = 0;
    
    trail = (CCParticleSystem *)[CCBReader load:@"Trail"];
    trail.particlePositionType = CCParticleSystemPositionTypeRelative;
    trail.emitterMode = CCParticleSystemPositionTypeRelative;
    [physicsNode addChild:trail];
    trail.visible = false;
    
    [super initialize];
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
        [character.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
        
        @try
        {
            [super touchBegan:touch withEvent:event];
        }
        @catch(NSException* ex)
        {
            
        }
    }
}

#pragma mark - Game Actions

- (void)gameOver {
    if (!_gameOver) {
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        
        character.physicsBody.velocity = ccp(0.0f, character.physicsBody.velocity.y);
        character.rotation = 90.f;
        character.physicsBody.allowsRotation = FALSE;
        [character stopAllActions];
        
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        
        [self runAction:bounce];
    }
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

#pragma mark - Obstacle Spawning

- (void)addObstacle {
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    CGPoint screenPosition = [self convertToWorldSpace:ccp(380, 0)];
    CGPoint worldPosition = [physicsNode convertToNodeSpace:screenPosition];
    obstacle.position = worldPosition;
    [obstacle setupRandomPosition];
    obstacle.zOrder = DrawingOrderPipes;
    [physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

- (void) addPowerup {
    @try
    {
        CCSprite* powerup = (CCSprite*)[CCBReader load:@"Powerup"];
        
        Obstacle* first = (Obstacle*)[_obstacles objectAtIndex: 0];
        Obstacle* second = (Obstacle*)[_obstacles objectAtIndex: 1];
        Obstacle* last = (Obstacle*)[_obstacles lastObject];
        
        powerup.position = ccp(last.position.x + (second.position.x - first.position.x) / 4.0f + character.contentSize.width, arc4random() % 488 + 200);
        powerup.physicsBody.collisionType = @"powerup";
        powerup.physicsBody.sensor = TRUE;
        
        powerup.zOrder = DrawingOrderPipes;
        [physicsNode addChild:powerup];
        [powerups addObject: powerup];
    }
    @catch(NSException* ex)
    {
        
    }
}

#pragma mark - Update

- (void)update:(CCTime)delta
{
    _sinceTouch += delta;
    
    character.rotation = clampf(character.rotation, -30.f, 90.f);
    
    trail.position = character.position;
    trail.startColor = [CCColor colorWithCcColor3b:ccc3(arc4random() % 255, arc4random() % 255, arc4random() % 255)];
    
    if (character.physicsBody.allowsRotation) {
        float angularVelocity = clampf(character.physicsBody.angularVelocity, -2.f, 1.f);
        character.physicsBody.angularVelocity = angularVelocity;
    }
    
    if ((_sinceTouch > 0.5f) && character.physicsNode) {
        [character.physicsBody applyAngularImpulse:-40000.f*delta];
    }
    
    physicsNode.position = ccp(physicsNode.position.x - (character.physicsBody.velocity.x * delta), physicsNode.position.y);
    
    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    
    NSMutableArray *offScreenObstacles = nil;
    
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    if (!_gameOver)
    {
        @try
        {
            character.physicsBody.velocity = ccp(character.physicsBody.velocity.x, clampf(character.physicsBody.velocity.y, -MAXFLOAT, 200.f));
            
            [super update:delta];
        }
        @catch(NSException* ex)
        {
            
        }
    }
}

@end
