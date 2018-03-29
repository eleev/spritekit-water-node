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
        effectNode.shader?.uniformNamed("u_color")?.vectorFloat4Value = color.toVector4()
    }
    
    func splash(at x: Float, force: CGFloat) {
        splash(at: x, force: force, width: 0)
    }
    
    func splash(at x: Float, force: CGFloat, width: Float) {
        var xLocation = CGFloat(x)
        xLocation -= CGFloat(self.width / 2)
        
        let cgwidth = CGFloat(width)
        
        var shortestDistance = CGFloat.greatestFiniteMagnitude
        var closestoJoint: WaterJoint!
        
        for joint in joints {
            let distance = fabs(joint.position.x - xLocation)
            
            if distance < shortestDistance {
                shortestDistance = distance
                closestoJoint = joint
            }
        }
        
        closestoJoint.velocity = -force
        
        for joint in joints {
            let distance = fabs(joint.position.x - closestoJoint.position.x)
            
            if distance < cgwidth {
                joint.velocity = distance / cgwidth * -force
            }
        }
        
        let dropletsNum = Int(20 * force / 100 * CGFloat(dropletsDensity))
        let cgdropletForce = CGFloat(dropletsForce)
        
        for _ in 0..<dropletsNum {
            let maxVelY = 500 * force / 100 * cgdropletForce
            let minVelY = 200 * force / 100 * cgdropletForce
            let maxVelX = -350 * force / 100 * cgdropletForce
            let minVelX = 350 * force / 100 * cgdropletForce
            
            let velY = minVelY + (maxVelY - minVelY) * CGFloat.random(min: 0, max: 1)
            let velX = minVelX + (maxVelX - minVelX) * CGFloat.random(min: 0, max: 1)
            
            let position = CGPoint(x: xLocation, y: CGFloat(surfaceHeight))
            let velocity = CGPoint(x: velX, y: velY)
            
            // Add droplet here
            addDroplet(at: position, velocity: velocity)
        }
        
    }
   
    func reset() {
        tension = 1.8
        damping = 2.4
        spread = 9.0
        dropletsForce = 1.0
        dropletsDensity = 1.0
        dropletSize = 3.0
    }
    
    // MARK: - Variables
    
    func set(tension: CGFloat) {
        self.tension = Float(tension)
        
        for joint in joints {
            joint.tension = tension
        }
    }
    
    func set(damping: CGFloat) {
        self.damping = Float(damping)
        
        for joint in joints {
            joint.damping = damping
        }
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
        let gravity: CGFloat = -1200
        let fdt = CGFloat(dt)
        let fsurfaceHeight = CGFloat(surfaceHeight)
        
        var dropletsToRemove = [Droplet]()
        
        for droplet in droplets {
            droplet.velocity = CGPoint(x: droplet.velocity.x, y: droplet.velocity.y + gravity * fdt)
            droplet.position = CGPoint(x: droplet.position.x + droplet.velocity.x * fdt, y: droplet.position.y + droplet.velocity.y * fdt)
            
            if droplet.position.y + (droplet.texture?.size().height)! / 2 + 30 < fsurfaceHeight {
                dropletsToRemove.append(droplet)
            }
        }
        
        for droplet in dropletsToRemove {
            self.remove(droplet: droplet)
        }
    }
    
    private func updateJoints(dt: CFTimeInterval) {
        let fdt = CGFloat(dt)
        let fspread = CGFloat(spread)
        
        for joint in joints {
            joint.update(dt)
        }
        
        let fsurfaceHeight = CGFloat(surfaceHeight)
        
        var leftDeltas = [CGFloat](repeating: fsurfaceHeight, count: joints.count)
        var rightDeltas = [CGFloat](repeating: fsurfaceHeight, count: joints.count)
        
        // Number of passes
        for _ in 0..<1 {
            for i in 0..<joints.count {
                let currentJoint = joints[i]
                
                if i > 0 {
                    let previousJoint = joints[i - 1]
                    leftDeltas[i] = fspread * (currentJoint.position.y - previousJoint.position.y)
                    previousJoint.velocity += leftDeltas[i] * fdt
                }
                if i < joints.count - 1 {
                    let nextJoint = joints[i + 1]
                    rightDeltas[i] = fspread * (currentJoint.position.y - nextJoint.position.y)
                    nextJoint.velocity += rightDeltas[i] * fdt
                }
            }
            
            for i in 0..<joints.count {
                if i > 0 {
                    let previois = joints[i - 1]
                    previois.set(y: previois.position.y + leftDeltas[i] * fdt)
                }
                if i < joints.count - 1 {
                    let next = joints[i + 1]
                    next.set(y: next.position.y + rightDeltas[i] * fdt)
                }
            }
        }
    }
    
    // MARK: - Droplets
    
    func addDroplet(at position: CGPoint, velocity: CGPoint) {
        var droplet: Droplet!
        
        if dropletsCache.count > 0 {
            droplet = dropletsCache.last
            dropletsCache.removeLast()
        } else {
            droplet = Droplet(imageNamed: "Droplet")
        }
        
        droplet.velocity = velocity
        droplet.position = position
        droplet.zPosition = 1.0
        droplet.blendMode = .alpha
        droplet.color = .blue
        droplet.zPosition = 11 // Most higher value
        
        let cgdropletSize = CGFloat(dropletSize)
        droplet.xScale = cgdropletSize
        droplet.yScale = cgdropletSize
        
        effectNode.addChild(droplet)
        droplets.append(droplet)
    }
    
    
    func remove(droplet: Droplet) {
        droplet.removeFromParent()
        
        if let index = droplets.index(of: droplet) {
            droplets.remove(at: index)
        }
        dropletsCache.append(droplet)
    }
    
}
