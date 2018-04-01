//
//  FlockingManger.swift
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 01/04/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class FlockingManager {

    // MARK: - Properties

    // A component system to manage per-frame updates for all agents.
    var agentSystem: GKComponentSystem<GKComponent>
    // This agent has no display representation, but can be used to make other agents follow the mouse/touch.
    var trackingAgent: GKAgent2D
    var seeking: Bool = false {
        didSet {
            for flock in flocks {
                if seeking {
                    flock.agent?.behavior?.setWeight(1, for: self.seekGoal)
                } else {
                    flock.agent?.behavior?.setWeight(0, for: self.seekGoal)
                }
            }
        }
    }
    var stopGoal: GKGoal = GKGoal(toReachTargetSpeed: 0)
    
    // MARK: - Private properties
    
    private var flocks: [AgentNode] = []
    private var seekGoal: GKGoal
    
    private var lastUpdateTime: TimeInterval = 0
    weak private var targetScene: SKScene?
    
    // MARK: - Initializers
    
    init(with count: Int, with scene: SKScene) {
        self.targetScene = scene
        
        agentSystem = GKComponentSystem(componentClass: GKAgent2D.self)
        trackingAgent = GKAgent2D()
        
        // Creating flocking agents
        flocks = [AgentNode]()
        let agentsPerRow = 4
        let fishes = [(radius: 25, type: "🐠"), (radius: 50, type: "🐟"), (radius: 35, type: "🐡")] 
        
        for i in 0..<count {
            let size = CGSize(width: scene.frame.width, height: GameScene.surfaceHeight / 4)
            let rect = CGRect(origin: scene.frame.origin, size: size)
            
            let x = rect.midX + CGFloat(i % agentsPerRow * 100)
            let y = rect.midY + CGFloat(i / agentsPerRow * 20)
            let position = CGPoint(x: x, y: y)
            
            let index = Int.random(min: 0, max: 2)
            let randomFish = fishes[index]
            let character = Character(randomFish.type)
            
            let agentNode = AgentNode(with: scene, character: character, radius: Float(randomFish.radius), position: position)
            agentNode.drawsTail = false
            
            guard let agent = agentNode.agent else {
                continue
            }
            self.agentSystem.addComponent(agent)
            flocks.append(agentNode)
        }
        
        var agents = [GKAgent2D]()
        
        for flock in flocks {
            guard let agent = flock.agent else {
                debugPrint(#function + " could not unwrap GKAgent2D since it is nil, the iteration will be skipped")
                continue
            }
            agents.append(agent)
        }
        
        // Adding behaviours
        
        let separationRadius: Float = 0.553 * 50
        let separationAngle: Float = 3 * Float.pi / 4.0
        let separationWeight: NSNumber = 80.0
        
        let alignmentRadius: Float = 0.8333 * 50.0
        let alignmentAngle: Float = Float.pi / 4.0
        let alignmentWeight: NSNumber = 10.0
        
        let cohesionRadius: Float = 1.0 * 100.0
        let cohesionAngle: Float = Float.pi / 2.0
        let cohesionWeight: NSNumber = 10.0
        
        let separateGoal = GKGoal(toSeparateFrom: agents, maxDistance: separationRadius, maxAngle: separationAngle)
        let alignmentGoal = GKGoal(toAlignWith: agents, maxDistance: alignmentRadius, maxAngle: alignmentAngle)
        let cohesionGoal = GKGoal(toCohereWith: agents, maxDistance: cohesionRadius, maxAngle: cohesionAngle)
        
        let goals = [separateGoal : separationWeight,
                     alignmentGoal : alignmentWeight,
                     cohesionGoal : cohesionWeight]
        let boidsBehaviour = GKBehavior(weightedGoals: goals)
        
        for agent in agents {
            agent.behavior = boidsBehaviour
        }

        // Create the seek goal, but add it to the behavior only in -setSeeking:.
        seekGoal = GKGoal(toSeekAgent: trackingAgent)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods

    func update(_ currentTime: TimeInterval) {
        // Calculate delta since last update and pass along to the agent system.
        if lastUpdateTime == 0 {
           lastUpdateTime = currentTime
        }
        
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        agentSystem.update(deltaTime: delta)
    }
    
    func chaoticActions() -> SKAction {
        let movement = SKAction.customAction(withDuration: 0.5) { (node, time) in
//            let size = CGSize(width: (self.targetScene?.frame.width)!, height: GameScene.surfaceHeight)
            let x = CGFloat.random(min: 200, max: 800)
            let y = CGFloat.random(min: 50, max: 100)
            
            self.move(to: CGPoint(x: x, y: y))
        }
        
        let wait = SKAction.wait(forDuration: 5.0)
        let sequnce = SKAction.sequence([movement, wait])
        let forever = SKAction.repeatForever(sequnce)
        return forever
    }
    
    // MARK: - Gestures
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        seeking = true
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        seeking = false
    }
    
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = targetScene else {
            debugPrint(#function + " could not continue the execution of the method because SKScene reference is nil. Plaese make sure that the reference is not nil and make sure that there is no memory leak that strongly holds the refernece to the parent scene.")
            return
        }
        
        let touch = touches.first
        guard let position = touch?.location(in: scene).convert() else {
            debugPrint(#function + " could not unwrap the last touch position, the method will be aborted")
            return
        }
        debugPrint(#function + " seeking positio in scene : " , position)
        self.trackingAgent.position = position
    }
    
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        seeking = false
    }
    
    // MARK: - Movement
    
    func move(to point: CGPoint) {
        seeking = true
        self.trackingAgent.position = point.convert()
    }
    
}
