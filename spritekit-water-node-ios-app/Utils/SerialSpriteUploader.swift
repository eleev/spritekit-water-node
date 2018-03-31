//
//  SerialSpriteUploader.swift
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 31/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import SpriteKit

/// Utility struct that is responsible for uploading sprites to SpriteKit compatable classes
struct SerialSpriteUploader<Node: SKNode> {
    
    // MARK :- Properties
    
    private var scene: SKScene
    
    // MARK: - Initializers
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    // MARK: - Methods
    
    /// Uploads a set of scene graph nodes with a specific pattern
    ///
    /// - Parameters:
    ///   - key: is a String instnace that describes name of child nodes that will be uploaded
    ///   - pattern: is a closure that accepts string and int (as key and index) and returns string that decribes naming pattern
    ///   - indices: is an instnace of ClosedRange<Int> type that specifies index boundaries of uploading nodes (for instnace you want to upload a set of nodes that describe sky and are called "cloud" - there are 3 clouds: "cloud-1", "cloud-2", "cloud-3" - the method helps to upload them using a singe function)
    /// - Returns: an array containing Node types (Node is any type derived from SKNode class)s
    func upload(for key: String, with pattern: (_ key: String, _ index: Int)->String, inRange indices: ClosedRange<Int>) -> [Node] {
        
        var foundNodes = [Node]()
        
        for index in indices.lowerBound...indices.upperBound {
            let childName = pattern(key, index)
            guard let node = scene.childNode(withName: childName) as? Node else {
                debugPrint(#function + " could not find child with the following name: ", childName)
                continue
            }
            foundNodes.append(node)
        }
        
        return foundNodes
    }
    
    /// Uploads an animation sequence from a texture atlas and returns an array of textures that can be futher used
    ///
    /// - Parameters:
    ///   - named: is a texture atlas name
    ///   - beginIndex: is a begin index that differentiates frames (for instnace the very first frame can named "player-0" or "player-1", the index helps in pattern matching)
    ///   - pattern: is a closure that accepts name of a frame and index (index is incremented internally) and returns a string instnace that is used as texture atlas naming pattern
    /// - Returns: an array of SKTexture instances, each containing a singe frame of key-frame animation
    /// - Throws: an instnace of NSError with exit code 1, no user-related info and domain-specific error explanation
    func upload(textureAtlas named: String, beginIndex: Int = 1, pattern: (_ name: String, _ index: Int) -> String) throws -> [SKTexture] {
        let atlas = SKTextureAtlas(named: named)
        var frames = [SKTexture]()
        
        let count = atlas.textureNames.count
        if beginIndex > count {
            throw NSError(domain: "Begin index is grather than the number of textures in a texture atlas named: \(named)", code: 1, userInfo: nil)
        }
        
        for index in beginIndex...count {
            let namePattern = pattern(named, index)
            let texture = atlas.textureNamed(namePattern)
            frames.append(texture)
        }
        
        return frames
    }
}
