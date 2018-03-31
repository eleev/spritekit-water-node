//
//  CloudNode.swift
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 30/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import UIKit

class CloudNode: SKSpriteNode, Updatable {
    
    // MARK: - Conformance to Updatable protocol
    
    func update(_ dt: CFTimeInterval) {
        let width = size.width
        let half = width / 2
        if position.x + half > GameScene.viewportSize.width + width {
            position.x = -width
        }
    }
}
