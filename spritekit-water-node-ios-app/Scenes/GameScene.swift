//
//  GameScene.swift
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 24/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene {

    // MARK: - Static properties
    
    static var viewportSize: CGSize = .zero
    static let surfaceHeight: CGFloat = 235
    
    // MARK: - Properties

    var splashWidth: CGFloat = 20.0
    var splashForceMultiplier: CGFloat = 0.125
    
    let fixedTimeStep: TimeInterval = 1.0 / 500
    
//    var waterNode: WaterNode!
    var waterNode: DynamicWaterNode!
    
    let waterColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
    
    private var clouds: [SKSpriteNode] = []
    private var boxes: [DropNode] = []
    
    private var deltaTime: CFTimeInterval = 0.0
    private var hasReferenceFrameTime: Bool = false
    
    private var updatables: [Updatable] = []
    fileprivate var spriteLoader: SerialSpriteUploader<CloudNode>?

    
    // MARK: - Methods
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        GameScene.viewportSize = view.bounds.size
        spriteLoader = SerialSpriteUploader(scene: self)
        loadClouds()
        
        prepareFlyingBird()
        
        let joints = 100
        
//        waterNode = WaterNode(with: Float(self.size.width), numJoints: joints, surfaceHeight: Float(surfaceHeight), fillColor: waterColor)
        waterNode = DynamicWaterNode(width: Float(self.size.width), numJoints: joints, surfaceHeight: Float(GameScene.surfaceHeight), fillColour: waterColor)
        waterNode.position = CGPoint(x: self.size.width / 2, y: 0)
        waterNode.zPosition = 20
        
        self.addChild(waterNode)
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let box = DropNode(imageNamed: "Box")
            box.position = location
            box.zPosition = 15
            self.addChild(box)
            boxes.append(box)
        }
    }
    
    // MARK: - Update
    
    override func update(_ currentTime: TimeInterval) {
        if !hasReferenceFrameTime {
            deltaTime = currentTime
            hasReferenceFrameTime = true
            return
        }
        
        let dt = currentTime - deltaTime
        
        var accumuilator: TimeInterval = 0
        accumuilator += dt
        
        while accumuilator >=  fixedTimeStep {
            fixedUpdate(for: fixedTimeStep)
            accumuilator -= fixedTimeStep
        }
        fixedUpdate(for: accumuilator)
        
        lastUpdate(for: dt)
        deltaTime = currentTime
        
        // Iterate the updatables
        updatables.forEach{ $0.update(accumuilator) }
    }
    
    func fixedUpdate(for dt: CFTimeInterval) {
        waterNode.update(dt)
        
        var boxesToRemove = [DropNode]()
        let gravity: Double = -1200
        
        for box in boxes {
            box.velocity = CGPoint(x: box.velocity.x, y: box.velocity.y + CGFloat(gravity * dt))
            box.position = CGPoint(x: box.position.x + box.velocity.x * CGFloat(dt), y: box.position.y + box.velocity.y * CGFloat(dt))
            
            if box.isAboveWater && box.position.y <= CGFloat(waterNode.surfaceHeight) {
                box.isAboveWater = false
//                waterNode.splash(at: box.position.x, force: -box.velocity.y * splashForceMultiplier, width: Float(splashWidth))
                waterNode.splashAt(x: Float(box.position.x), force: -box.velocity.y * splashForceMultiplier, width: Float(splashWidth))
            }
            
            if box.position.y < -box.size.height / 2 {
                boxesToRemove.append(box)
            }
        }
        
        for box in boxesToRemove {
            guard let index = boxes.index(of: box) else {
                continue
            }
            debugPrint(#function + " remove box that is ourside of the viewport : ", boxes[index])
            let box = boxes[index]
            box.removeAllChildren()
            box.removeFromParent()
            boxes.remove(at: index)
        }
    }
    
    func lastUpdate(for dt: CFTimeInterval) {
        waterNode.render()
    }
    
}

extension GameScene {
    
    func loadClouds() {
        guard let cloudsSprites = spriteLoader?.upload(for: "cloud", with: { key, index -> String in
            return key + "-\(index)"
        }, inRange: 1...3) else {
            return
        }
        
        updatables.append(contentsOf: cloudsSprites)
    }
 
    func prepareFlyingBird() {
        var textures: [SKTexture]?
        
        // 1.  upload the texture atlas
        do {
            textures = try spriteLoader?.upload(textureAtlas: "Bird Left", beginIndex: 1, pattern: { (name, index) -> String in
                return "player\(index)"
            })
        } catch {
            debugPrint(#function + " thrown the errro while uploading texture atlas : ", error)
        }
        
        // 2. unwrap the texture array
        guard let unwrappedTextures = textures else {
            debugPrint(#function + " could not unwrap the textures since it is nil")
            return
        }
        
        // 3. fetch the FlyingBird instance from the scene graph
        guard let bird = self.childNode(withName: "Bird") as? FlyingBird else {
            debugPrint(#function + " could not upload Bird node - the animated Bird will not be drawn and animated (!)")
            return
        }

        // 4. animated the flying bird
        bird.flyTextures = unwrappedTextures
        bird.animate(with: 0.1)
        
        updatables.append(bird)
    }
    
    fileprivate func debugWaterNodePrint() {
        DispatchQueue.once(token: "debug-print") {
            debugPrint(#function + " joints : ")
            
            waterNode.joints.forEach({ joint in
                debugPrint(joint.position)
            })
        }
    }
}

struct SerialSpriteUploader<Node: SKNode> {
    
    // MARK :- Properties
    
    private var scene: SKScene
    
    // MARK: - Initializers
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    // MARK: - Methods
    
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
