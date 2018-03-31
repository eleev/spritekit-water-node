//
//  FlyingBird.swift
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 31/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import SpriteKit

class FlyingBird: SKSpriteNode, Updatable {
    
    // MARK: - Properties
    
    var flyTextures: [SKTexture]? = nil
    
    // MARK: - Methods
    
    func animate(with timing: TimeInterval) {
        guard let walkTextures = flyTextures else {
            return
        }
        
        let animateAction = SKAction.animate(with: walkTextures, timePerFrame: timing, resize: false, restore: true)
        let foreverAction = SKAction.repeatForever(animateAction)
        self.run(foreverAction)
    }
    
    // MARK: - Conformance to Updatable protocol
    
    func update(_ dt: CFTimeInterval) {
        let width = size.width
        let half = width / 2
        
        if position.x - half < -width {
            position.x = GameScene.viewportSize.width - width
        }
    }
    
}
