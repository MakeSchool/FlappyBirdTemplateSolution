//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Benjamin Encz on 10/10/13.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "MainScene.h"
#import "Obstacle.h"
#import "Character.h"

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
    
    Character*        character;
    CCPhysicsNode*    physicsNode;
    CCParticleSystem* trail;
    int               points;
    
    // add your custom instance variables here!
    //---------------------------------------------------------
    float timeSinceObstacle;
    //---------------------------------------------------------
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        CGSize viewSize = [CCDirector sharedDirector].viewSize;
        
        // Create Background
        CCSprite* background = [CCSprite spriteWithImageNamed:@"FlappyBirdArtPack/background.png"];
        background.anchorPoint = ccp(0.0f, 0.0f);
        background.position = ccp(0.0f, 0.0f);
        background.scale = 1.17f;
        [self addChild:background];
        
        // Create Cloud
        CCSprite* cloud = [CCSprite spriteWithImageNamed:@"FlappyBirdArtPack/clouds.png"];
        cloud.anchorPoint = ccp(0.0f, 0.5f);
        cloud.position = ccp(0.0f, 434.0f);
        [self addChild:cloud];
        
        // Create Bush
        CCSprite* bush = [CCSprite spriteWithImageNamed:@"FlappyBirdArtPack/bush.png"];
        bush.anchorPoint = ccp(0.0f, 0.5f);
        bush.position = ccp(0.0f, 106.0f);
        [self addChild:bush];
        
        // Create Physics Node
        physicsNode = [CCPhysicsNode node];
        physicsNode.contentSize = CGSizeMake(viewSize.width, viewSize.height);
        physicsNode.position = ccp(0.0f, 9.0f);
        physicsNode.gravity = ccp(0.0f, -700.0f);
        physicsNode.sleepTimeThreshold = 0.5f;
        physicsNode.collisionDelegate = self;
        [self addChild:physicsNode];
        
        // Create Grounds
        // -- Ground Sprites
        _ground1 = [CCSprite spriteWithImageNamed:@"FlappyBirdArtPack/ground.png"];
        _ground2 = [CCSprite spriteWithImageNamed:@"FlappyBirdArtPack/ground.png"];
        
        _ground1.anchorPoint = ccp(0.0f, 0.5f);
        _ground2.anchorPoint = ccp(0.0f, 0.5f);
        
        _ground1.position = ccp(0.0f, 25.0f);
        _ground2.position = ccp(462.0f, 25.0f);
        
        // -- Ground Physics
        CGRect groundBodyShape = CGRectMake(0.0f, 0.0f, 462.0f, 112.0f);
        CCPhysicsBody* ground1PhysicsBody = [CCPhysicsBody bodyWithRect:groundBodyShape cornerRadius:0.0f];
        CCPhysicsBody* ground2PhysicsBody = [CCPhysicsBody bodyWithRect:groundBodyShape cornerRadius:0.0f];
        
        ground1PhysicsBody.density = 1.0f;
        ground2PhysicsBody.density = 1.0f;
        ground1PhysicsBody.friction = 0.0f;
        ground2PhysicsBody.friction = 0.0f;
        ground1PhysicsBody.elasticity = 0.0f;
        ground2PhysicsBody.elasticity = 0.0f;

        ground1PhysicsBody.type = CCPhysicsBodyTypeStatic;
        ground2PhysicsBody.type = CCPhysicsBodyTypeStatic;
        
        _ground1.physicsBody = ground1PhysicsBody;
        _ground2.physicsBody = ground2PhysicsBody;
        
        [physicsNode addChild:_ground1];
        [physicsNode addChild:_ground2];
        
        // Create Restart Button
        CCSpriteFrame* buttonBGSpriteFrame = [CCSpriteFrame frameWithImageNamed:@"ccbButtonNormal.png"];
        _restartButton = [CCButton buttonWithTitle:@"Restart" spriteFrame:buttonBGSpriteFrame];
        [_restartButton setTarget:self selector:@selector(restart)];
        _restartButton.preferredSize = CGSizeMake(60.0f, 40.0f);
        _restartButton.anchorPoint = ccp(0.5f, 0.5f);
        _restartButton.position = ccp(viewSize.width / 2.0f, viewSize.height / 2.0f);
        _restartButton.visible = NO;
        [self addChild:_restartButton];
        
        // Create Score Label
        _scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Courier" fontSize:60.0f];
        _scoreLabel.anchorPoint = ccp(0.5f, 0.5f);
        _scoreLabel.position = ccp(viewSize.width / 2.0f, viewSize.height - 60.0f);
        _scoreLabel.color = [CCColor whiteColor];
        _scoreLabel.visible = NO;
        [self addChild:_scoreLabel];
        
        self.userInteractionEnabled = TRUE;
        
        _grounds = @[_ground1, _ground2];
        
        for (CCNode *ground in _grounds) {
            // set collision txpe
            ground.physicsBody.collisionType = @"level";
            ground.zOrder = DrawingOrderGround;
        }
        
        _obstacles = [NSMutableArray array];
        powerups = [NSMutableArray array];
        points = 0;
        
        [self createTrail];
        
        [self initialize];
    }
    
    return self;
}

- (void)createTrail
{
    // Create trail particle system
    
    trail = [CCParticleSystem particleWithTotalParticles:300];
    trail.anchorPoint = ccp(0.0f, 0.0f);
    trail.emitterMode = CCParticleSystemModeGravity;
    trail.posVar = ccp(5.0f, 5.0f);
    trail.emissionRate = 150.0f;
    trail.duration = CCParticleSystemDurationInfinity;
    trail.life = 0.5f;
    trail.lifeVar = 1.4f;
    trail.startSize = 1.0f;
    trail.startSizeVar = 50.0f;
    trail.endSize = 30.0f;
    trail.angleVar = 360.0f;
    trail.startColor = [CCColor colorWithCcColor4b:ccc4(146, 146, 146, 179)];
    trail.startColorVar = [CCColor colorWithCcColor4b:ccc4(238, 241, 211, 219)];
    trail.endColor = [CCColor colorWithCcColor4b:ccc4(212, 228, 7, 156)];
    trail.endColorVar = [CCColor colorWithCcColor4b:ccc4(53, 253, 255, 255)];
    trail.gravity = ccp(0.0f, 0.0f);
    trail.speed = 0.0f;
    trail.speedVar = 200.0f;
    trail.tangentialAccel = -90.0f;
    trail.tangentialAccelVar = 70.0f;
    trail.radialAccel = -650.0f;
    trail.radialAccelVar = 70.0f;
    trail.texture = [CCTexture textureWithFile:@"FlappyBirdArtPack/fly1.png"];
    
    trail.particlePositionType = CCParticleSystemPositionTypeRelative;
    trail.emitterMode = CCParticleSystemPositionTypeRelative;
    [physicsNode addChild:trail];
    trail.visible = false;
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
    CCScene *scene = [MainScene node];
    [[CCDirector sharedDirector] replaceScene:scene];
}

#pragma mark - Obstacle Spawning

- (void)addObstacle {
    Obstacle *obstacle = [Obstacle new];
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
        CCSprite* powerup = [CCSprite spriteWithImageNamed:@"FlappyBirdArtPack/powerup_red.png"];
        powerup.anchorPoint = ccp(0.5f, 0.5f);
        
        Obstacle* first = (Obstacle*)[_obstacles objectAtIndex: 0];
        Obstacle* second = (Obstacle*)[_obstacles objectAtIndex: 1];
        Obstacle* last = (Obstacle*)[_obstacles lastObject];
        
        powerup.position = ccp(last.position.x + (second.position.x - first.position.x) / 4.0f + character.contentSize.width, arc4random() % 488 + 200);
        
        CGRect physicsBodyShape = CGRectMake(0.0f, 0.0f, 37.0f, 28.0f);
        CCPhysicsBody* physicsBody = [CCPhysicsBody bodyWithRect:physicsBodyShape cornerRadius:0.0f];
        physicsBody.type = CCPhysicsBodyTypeStatic;
        powerup.physicsBody = physicsBody;
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

#pragma mark - Score

-(void) showScore {
    _scoreLabel.visible = YES;
}

-(void) updateScore {
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
}

#pragma mark - Modify These Methods!

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
        
        [character.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
        
        @try
        {
            // add your additional touchBegan code here!
            //---------------------------------------------------------
            float impulse = 200 - 2 * character.physicsBody.velocity.y;
            [character.physicsBody applyImpulse:ccp(0, impulse)];
            //---------------------------------------------------------
        }
        @catch (NSException *exception) {
            
        }
    }
}

- (void)update:(CCTime)delta {
    
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
            
            // add your extra update method code here!
            //---------------------------------------------------------
            timeSinceObstacle += delta;
            
            if (timeSinceObstacle > 2)
            {
                // Add a new obstacle
                [self addObstacle];
                [self addPowerup];
                // Then reset the timer.
                timeSinceObstacle = 0;
            }
            
            if (character.physicsBody.velocity.y < -800)
            {
                character.physicsBody.velocity = ccp(80, -800);
            }
            else if (character.physicsBody.velocity.y > 200)
            {
                character.physicsBody.velocity = ccp(80, 200);
            }
            else
            {
                character.physicsBody.velocity = ccp(80, character.physicsBody.velocity.y);
            }
            //---------------------------------------------------------
        }
        @catch(NSException* ex)
        {
            
        }
    }
}

#pragma mark - Implement Your Methods Here!

//---------------------------------------------------------
- (void)initialize
{
    character = [Character createFlappy];
    [physicsNode addChild:character];
    
    [self addObstacle];
    
    timeSinceObstacle = 0;
    
   [self showScore];
}


- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)character level:(CCNode *)level
{
    [self gameOver];
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)character goal:(CCNode *)goal
{
    [goal removeFromParent];
    points++;
    [self updateScore];
    return YES;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCSprite *)character powerup:(CCSprite *)powerup
{
    trail.visible = TRUE;
    return TRUE;
}
//---------------------------------------------------------

@end
