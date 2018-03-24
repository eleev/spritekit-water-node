//
//  WaterNode.swift
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 24/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import SpriteKit

class WaterNode: SKNode, Splashable {
    
    // MARK: - Prperties
    
    var surfaceHeight: Float = 0
    var tension: Float = 0
    var damping: Float = 0
    var spread: Float = 0
    var dropletsForce: Float = 0
    var dropletsDensity: Float = 0
    var dropletSize: Float = 0
    
    // MARK: - Private properties
    
    private(set) var joints: Array<WaterJoint>
    private(set) var droplets: Array<Droplet>
    private var dropletsCache: Array<Droplet>
    
    private(set) var width: Float
    private(set) var path: CGPath
    
    private(set) var shapeNode: SKShapeNode
    private(set) var effectNode: SKEffectNode
    
    // MARK: - Constants
    
    static let DROPLET_FRAGMENT_SHADER_NAME = "Droplets.fsh"
    
    // MARK: - Initializers
    
    required init(with width: Float, numJoints: Int, surfaceHeight: Float, fillColor: UIColor) {
        
        // Properties
        self.surfaceHeight = surfaceHeight
        self.width = width
        self.droplets = Array()
        self.dropletsCache = Array()
        
        // Effect node
        self.effectNode = SKEffectNode()
        self.effectNode.position = .zero
        self.effectNode.zPosition = 1.0
        self.effectNode.shouldRasterize = false
        self.effectNode.shouldEnableEffects = true
        self.effectNode.shader = SKShader(fileNamed: WaterNode.DROPLET_FRAGMENT_SHADER_NAME)
        self.effectNode.shader?.uniforms = [SKUniform.init(name: "u_color", vectorFloat4: fillColor.toVector4()) ]
        
        
        // Shape node
        self.shapeNode = SKShapeNode()
        self.shapeNode.fillColor = .black
        self.shapeNode.strokeColor = .green
        self.shapeNode.glowWidth = 2.0
        self.shapeNode.zPosition = 2.0
        self.effectNode.addChild(self.shapeNode)
        
        // Create joints
        
        var joints = Array<WaterJoint>()
        
        for i in 0..<numJoints {
            let joint = WaterJoint()
            
            let widthD = CGFloat(-(width / 2))
            let widthT = CGFloat((width / Float(numJoints - 1)) * Float(i))
            let x = widthD + widthT
            let y: CGFloat = 0
            
            let position = CGPoint(x: x, y: y)
            joint.position = position
            
            joints.append(joint)
        }
        self.joints = Array<WaterJoint>(joints)
        
        self.path = CGMutablePath()
        
        super.init()
        
        self.path = path(from: self.joints)
        
        self.addChild(self.effectNode)
        // Reset simulation
        reset()
        // Initial render
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    // MARK: - Conformance to Splashable protocol
    
    func set(color: UIColor) {
        fatalError(#function + " has not been implemented yet")
    }
    
    func splash(at x: Float, force: CGFloat) {
        fatalError(#function + " has not been implemented yet")
    }
    
    func splash(at x: Float, force: CGFloat, width: Float) {
        fatalError(#function + " has not been implemented yet")
    }
   
    func reset() {
        fatalError(#function + " has not been implemented yet")
    }
    
    // MARK: - Conformance to Renderable protocol
    
    func render() {
        path = path(from: joints)
        shapeNode.path = path
    }
    
    private func path(from joints: Array<WaterJoint>) -> CGPath {
        let path = CGMutablePath()
        var index = 0
        let cgsurfaceHeight = CGFloat(self.surfaceHeight)
        
        for joint in joints {
            let point = CGPoint(x: joint.position.x, y: joint.position.y + cgsurfaceHeight)
            
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            index += 1
        }
        
        let halfWidth = CGFloat(self.width / 2)
        // Bottom right
        path.addLine(to: CGPoint(x: halfWidth, y: 0))
        // Bottom left
        path.addLine(to: CGPoint(x: -halfWidth, y: 0))
        path.closeSubpath()
        
        return path
    }
    
    // MARK: - Conformance to Updatable protocol
    
    func update(_ dt: CFTimeInterval) {
        updateJoints(dt: dt)
        updateDroplets(dt: dt)
    }
    
    private func updateDroplets(dt: CFTimeInterval) {
        fatalError(#function + " has not been implemented yet")
    }
    
    private func updateJoints(dt: CFTimeInterval) {
        fatalError(#function + " has not been implemented yet")
    }

}
