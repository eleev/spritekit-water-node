//
//  DynamicWaterNode.h
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 24/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DynamicWaterNode : SKNode

/** Height of the water's surface */
@property float surfaceHeight;
/** Tension the water, shoud probably be less than damping */
@property (nonatomic) float tension;
/** Tension the water, shoud probably be greater than damping */
@property (nonatomic) float damping;
/** Controls how fast/far waves propogate across water surface */
@property float spread;
/** The amount of force applied to splash droplets */
@property float dropletsForce;
/** Higher values will result splahes producing more water droplets */
@property float dropletsDensity;
/** Size of water droplets */
@property float dropletSize;

#pragma mark - Init
/** 
 Designated Initialiser.
 @param width The width of the water
 @param numJoints The number of joints used to simulate the waves. More joints will result in a smoother wave curve, fewer joints will look more jagged, but may may improve performance.
 @param surfaceHeight the height of the water's surface
 @param fillColour The colour of the water
 */
-(instancetype)initWithWidth:(float)width numJoints:(NSInteger)numJoints surfaceHeight:(float)surfaceHeight fillColour:(UIColor*)fillColour;

#pragma mark - Set Defaults
/** Reset simulation variables to defaults */
-(void)setDefaultValues;

#pragma mark - Colour
/** Set the water colour */
-(void)setColour:(UIColor*)colour;

#pragma mark - Update

/**
 Step the time of the simulation
 */
-(void)update:(CFTimeInterval)dt;


#pragma mark - Splash
/**
 Make a splash
 */
-(void)splashAtX:(float)xLocation force:(CGFloat)force;
/**
 Make a splash
 */
-(void)splashAtX:(float)xLocation force:(CGFloat)force width:(float)width;

#pragma mark - Render
/**
 Render the water. Only call this once per frame. You can still call update to update the simulation multiple times per frame (eg. fixed time-step).
 */
-(void)render;

@end
