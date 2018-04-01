//
//  Agent.swift
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 01/04/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

enum BoidOrientation: CGFloat {
    case north = 0
    case east = 270
    case south = 180
    case west = 90
}

class AgentNode: SKSpriteNode, GKAgentDelegate {

    // MARK: - Properties
    
    var agent: GKAgent2D?
    var drawsTail: Bool = true {
        didSet {
            if drawsTail {
                particles?.particleBirthRate = defaultParticleRate
            } else {
                particles?.particleBirthRate = 0.0
            }
        }
    }
    
    // MARK: - Private properties
    
    private var orientation: BoidOrientation = .west
    private var particles: SKEmitterNode?
    private var defaultParticleRate: CGFloat = 10
    
    // MARK: - Initrializers
    
    init(with scene: SKScene, character: Character, radius: Float, position: CGPoint) {
        super.init(texture: nil, color: .clear, size: CGSize())
        
        self.position = position
        self.zPosition = 10
        scene.addChild(self)
        
        // Agent that manages the movement of this node
        agent = GKAgent2D()
        agent?.radius = radius
        agent?.position = position.convert()
        agent?.delegate = self
        agent?.maxSpeed = 150
        agent?.maxAcceleration = 50
        
        // Create the label and set the character and size
        let boidlabel = SKLabelNode(text: String(character))
        boidlabel.fontSize = CGFloat(radius)
        addChild(boidlabel)
        
        
        // Particle effect to leave a trail behind the agent as it moves through the scene
        if let particles = SKEmitterNode(fileNamed: "Trail.sks") {

            defaultParticleRate = particles.particleBirthRate
            particles.position = CGPoint(x: -CGFloat(radius + 5.0), y: 0.0)
            particles.zPosition = 9
            particles.targetNode = scene
            self.addChild(particles)
            
            self.particles = particles
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func rotate() {
        guard let agent = agent else {
            return
        }
        
        zRotation = CGFloat(-atan2(Double(agent.velocity.x), Double(agent.velocity.y))) - orientation.rawValue.degreesToRadians
        
        
    }
    
    // MARK: - CGAgentDelegate conformance
    
    func agentWillUpdate(_ agent: GKAgent) {
        // All changes to agents in this app are driven by the agent system, so there is no other changes to pass into agent system in this method.
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        // Agent and sprtie use the same coordiate system (in this app), so just convert vector_float2 to CGPoint
        guard let agent2D = agent as? GKAgent2D else {
            debugPrint(#function + " GKAgent could not be up casted into GKAgent2D")
            return
        }
        position = agent2D.position.convert()
        rotate()
    }
    
}

extension vector_float2 {
    func convert() -> CGPoint {
        return CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))
    }
}

extension CGPoint {
    func convert() -> vector_float2 {
        return vector_float2(Float(self.x), Float(self.y))
    }
}
