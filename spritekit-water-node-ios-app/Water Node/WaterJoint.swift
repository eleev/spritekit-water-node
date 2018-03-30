//
//  WaterJoint.swift
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 24/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import SpriteKit

class WaterJoint: NSObject, Updatable {
    
    // MARK: - Properties
    
    var position: CGPoint = .zero
    var velocity: CGFloat = 0
    var damping: CGFloat = 0
    var tension: CGFloat = 0
    
    // MARK: - Methods
    
    func set(y position: CGFloat) {
        self.position = CGPoint(x: self.position.x, y: position)
    }
    
    // MARK: - Conformance to Updatable protocol
    
    func update(_ dt: CFTimeInterval) {
        let y = position.y
        let acceleration = (-tension * y) - (velocity * damping)
        
        let dtf = CGFloat(dt)
        
        position = CGPoint(x: position.x, y: position.y + (velocity * 60 * dtf))
        velocity += acceleration * dtf
    }
    
}
