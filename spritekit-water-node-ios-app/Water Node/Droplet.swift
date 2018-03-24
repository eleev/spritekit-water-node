//
//  Droplet.swift
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 24/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import SpriteKit

class Droplet: SKSpriteNode {
    
    // MARK: - Properties
    
    var velocity: CGPoint
    
    // MARK: - Initializers
    
    convenience init(with imageNamed: String = "Droplet") {
        let droplet = Droplet()
        droplet.texture = SKTexture(imageNamed: imageNamed)
        droplet.velocity = .zero
        self.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
