//
//  DunamicWaternode.m
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 24/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

#import "DynamicWaterNode.h"

@interface UIColor (SBDynamicWaterNodeExtensions)
-(GLKVector4)vector4Value;
@end

@implementation UIColor (SBDynamicWaterNodeExtensions)

-(GLKVector4)vector4Value{
    
    CGFloat r, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return GLKVector4Make(r, g, b, a);
}

@end

//**********************************************
#pragma mark - ***** Droplet *****
//**********************************************

@interface Droplet : SKSpriteNode
@property CGPoint velocity;
@end

@implementation Droplet

+(instancetype)droplet{
    Droplet *droplet = [[Droplet alloc]initWithImageNamed:@"Droplet"];
    droplet.velocity = CGPointZero;
    return droplet;
}

@end

//**********************************************
#pragma mark - ***** WaterJoint *****
//**********************************************

@interface WaterJoint : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat velocity;
@property (nonatomic) CGFloat damping;
@property (nonatomic) CGFloat tension;
@end

@implementation WaterJoint

-(instancetype)init{
    
    if (self = [super init]) {
        self.position = CGPointZero;
        self.velocity = 0;
        self.damping = 0;
        self.tension = 0;
    }
        return self;
}

-(void)setYPosition:(float)yPos{
    self.position = CGPointMake(self.position.x, yPos);
}

- (void)update:(NSTimeInterval)dt {
    
    CGFloat y = self.position.y;
    CGFloat acceleration = (-self.tension * y) - (self.velocity * self.damping);

    self.position = CGPointMake(self.position.x, self.position.y + (self.velocity * 60 * dt));
    self.velocity += acceleration * dt;
}

@end

//**********************************************
#pragma mark - ***** DynamicWaterNode *****
//**********************************************

@interface DynamicWaterNode ()
@property (nonatomic, strong) NSArray<WaterJoint*> *joints;
@property (nonatomic, strong) SKShapeNode *shapeNode;
@property float width;

@property CGPathRef path;

@property (nonatomic, strong) NSMutableArray *droplets;
@property (nonatomic, strong) NSMutableArray *dropletsCache;

@property (nonatomic, strong) SKEffectNode *effectNode;

@end


@implementation DynamicWaterNode

#pragma mark - LifeCycle

-(instancetype)initWithWidth:(float)width numJoints:(NSInteger)numJoints surfaceHeight:(float)surfaceHeight fillColour:(UIColor*)fillColour{
    
    self = [super init];
    if (!self) { return nil; }
    
    // Init Properties
    self.surfaceHeight = surfaceHeight;
    self.width = width;
    self.droplets = [[NSMutableArray alloc]init];
    self.dropletsCache = [[NSMutableArray alloc]init];
    
    // Effect Node
    self.effectNode = [[SKEffectNode alloc]init];
    self.effectNode.position = CGPointZero;
    self.effectNode.zPosition = 1;
    self.effectNode.shouldRasterize = NO;
    self.effectNode.shouldEnableEffects = YES;
    self.effectNode.shader = [SKShader shaderWithFileNamed:@"Droplets.fsh"];
    self.effectNode.shader.uniforms = @[[SKUniform uniformWithName:@"u_colour" floatVector4:[fillColour vector4Value]]];
    [self addChild:self.effectNode];
    
    // Shape Node
    self.shapeNode = [[SKShapeNode alloc]init];
    self.shapeNode.fillColor = [UIColor blackColor];
    self.shapeNode.strokeColor = [UIColor greenColor];
    self.shapeNode.glowWidth = 2;
    self.shapeNode.zPosition = 2;
    [self.effectNode addChild:self.shapeNode];

    // Create joints
    NSMutableArray *mutableJoints = [[NSMutableArray alloc]initWithCapacity:numJoints];
    for (NSInteger i = 0; i < numJoints; i++) {
        WaterJoint *joint = [[WaterJoint alloc]init];
        CGPoint position;
        position.x = -(width/2) + ((width/(numJoints-1)) * i);
        position.y = 0;
        joint.position = position;
        [mutableJoints addObject:joint];
    }
    self.joints = [NSArray arrayWithArray:mutableJoints];
    
    // Set default simulation variables
    [self setDefaultValues];
    
    // Initial render
    [self render];
   
    return self;
}

-(void)dealloc{
    CGPathRelease(self.path);
}

#pragma mark - Simulation Variables

-(void)setDefaultValues{
    self.tension = 1.8;
    self.damping = 2.4;
    self.spread = 9;
    self.dropletsForce = 1;
    self.dropletsDensity = 1;
    self.dropletSize = 3;
}

-(void)setTension:(float)tension{
    _tension = tension;
    for (WaterJoint *joint in self.joints) {
        joint.tension = tension;
    }
}

-(void)setDamping:(float)damping{
    _damping = damping;
    for (WaterJoint *joint in self.joints) {
        joint.damping = damping;
    }
}

-(void)setColour:(UIColor*)colour{
    [self.effectNode.shader uniformNamed:@"u_colour"].floatVector4Value = [colour vector4Value];
}

#pragma mark - Splash

-(void)splashAtX:(float)xLocation force:(CGFloat)force{
    [self splashAtX:xLocation force:force width:0];
}

-(void)splashAtX:(float)xLocation force:(CGFloat)force width:(float)width{

    xLocation -= self.width/2;
    
    CGFloat shortestDistance = CGFLOAT_MAX;
    WaterJoint *closestJoint;
    
    for (WaterJoint *joint in self.joints) {
    
        CGFloat distance = fabs(joint.position.x - xLocation);
        if (distance < shortestDistance) {
            shortestDistance = distance;
            closestJoint = joint;
        }
    }
    
    closestJoint.velocity = -force;
    
    for (WaterJoint *joint in self.joints) {
        CGFloat distance = fabs(joint.position.x - closestJoint.position.x);
        if (distance < width) {
            joint.velocity = distance / width * -force;
        }
    }
    
    
    // Add droplets
    NSInteger numDroplets = 20 * force/100 * self.dropletsDensity;
    //NSLog(@"Num Droplets: %li", (long)numDroplets);
    for (NSInteger i = 0; i < numDroplets; i++) {
        const float maxVelY = 500 * force/100*self.dropletsForce;
        const float minVelY = 200 * force/100*self.dropletsForce;
        const float maxVelX = -350 * force/100*self.dropletsForce;
        const float minVelX = 350 * force/100*self.dropletsForce;
        
        float velY = minVelY + (maxVelY - minVelY) * [self randomFloatBetween0and1];
        float velX = minVelX + (maxVelX - minVelX) * [self randomFloatBetween0and1];
        
        [self addDropletAt:CGPointMake(xLocation, self.surfaceHeight)
                  velocity:CGPointMake(velX, velY)];
    }
    
}

-(float)randomFloatBetween0and1{
    return (float)rand() / RAND_MAX;
}

#pragma mark - Droplets

-(void)addDropletAt:(CGPoint)position velocity:(CGPoint)velocity{
    
    Droplet *droplet;
    
    if (self.dropletsCache.count) {
        droplet = [self.dropletsCache lastObject];
        [self.dropletsCache removeLastObject];
    }
    else{
        droplet = [Droplet droplet];
    }
    
    droplet.velocity = velocity;
    droplet.position = position;
    droplet.zPosition = 1;
    droplet.blendMode = SKBlendModeAlpha;
    droplet.color = [UIColor blueColor];
    droplet.colorBlendFactor = 1;
    droplet.xScale = droplet.yScale = self.dropletSize;
    [self.effectNode addChild:droplet];
    [self.droplets addObject:droplet];
}

-(void)removeDroplet:(Droplet*)droplet{
    
    [droplet removeFromParent];
    [self.droplets removeObject:droplet];
    [self.dropletsCache addObject:droplet];
}


#pragma mark - Update

-(void)update:(CFTimeInterval)dt{
    [self updateJoints:dt];
    [self updateDroplets:dt];
}

-(void)updateJoints:(CFTimeInterval)dt{
    
    
    for (WaterJoint *joint in self.joints) {
        [joint update:dt];
    }
    
    float leftDeltas[self.joints.count];
    float rightDeltas[self.joints.count];
    
    for (NSInteger pass = 0; pass < 1; pass++) {
        
        for (NSInteger i = 0; i < self.joints.count; i++) {
            
            WaterJoint *currentJoint = self.joints[i];
            
            if (i > 0) {
                WaterJoint *previousJoint = self.joints[i-1];
                leftDeltas[i] = self.spread * (currentJoint.position.y - previousJoint.position.y);
                previousJoint.velocity += leftDeltas[i] * dt;
            }
            if (i < self.joints.count-1) {
                WaterJoint *nextJoint = self.joints[i+1];
                rightDeltas[i] = self.spread * (currentJoint.position.y - nextJoint.position.y);
                nextJoint.velocity += rightDeltas[i] * dt;
            }
        }
        
        for (NSInteger i = 0; i < self.joints.count; i++) {
            
            if (i > 0) {
                WaterJoint *previousJoint = self.joints[i-1];
                [previousJoint setYPosition:previousJoint.position.y + leftDeltas[i] * dt];
            }
            if (i < self.joints.count - 1) {
                WaterJoint *nextJoint = self.joints[i+1];
                [nextJoint setYPosition:nextJoint.position.y + rightDeltas[i] * dt];
            }
            
        }
        
    }
}

-(void)updateDroplets:(CFTimeInterval)dt{
    
    const float gravity = -1200;
    
    NSMutableArray *dropletsToRemove = [[NSMutableArray alloc]init];
    
    for (Droplet *droplet in self.droplets) {
        
        // Apply Gravity
        droplet.velocity = CGPointMake(droplet.velocity.x,
                                       droplet.velocity.y + gravity * dt);
        
        droplet.position = CGPointMake(droplet.position.x + droplet.velocity.x * dt,
                                       droplet.position.y + droplet.velocity.y * dt);
        
        // Remove if below surface
        if (droplet.position.y + droplet.texture.size.height/2 + 30 < self.surfaceHeight) {
            [dropletsToRemove addObject:droplet];
        }
    }
    
    for (Droplet *droplet in dropletsToRemove) {
        [self removeDroplet:droplet];
    }
    
}

#pragma mark - Render

-(void)render{
    
    CGPathRelease(self.path);
    self.path = [self pathFromJoints:self.joints];
    
    [self.shapeNode setPath:self.path];
}

- (CGPathRef)pathFromJoints:(NSArray*)joints {
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    NSInteger index = 0;
    for (WaterJoint *joint in self.joints) {
        
        if (index == 0) {
            CGPathMoveToPoint(path,
                              nil,
                              joint.position.x,
                              joint.position.y + self.surfaceHeight);
        }
        else{
            CGPathAddLineToPoint(path,
                                 nil,
                                 joint.position.x,
                                 joint.position.y + self.surfaceHeight);
        }
        
        index++;
    }
    
    // Bottom Right
    CGPathAddLineToPoint(path,
                         nil,
                         self.width/2,
                         0);
    
    // Bottom Left
    CGPathAddLineToPoint(path,
                         nil,
                         -self.width/2,
                         0);
    
    CGPathCloseSubpath(path);

    
    return path;
}


@end
