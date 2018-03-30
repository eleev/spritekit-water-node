//
//  Splashable.swift
//  spritekit-water-node-ios-app
//
//  Created by Astemir Eleev on 24/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import simd

protocol Splashable: Updatable, Renderable {
    
    // MARK: - Properties
    
    var surfaceHeight: Float { get set }
    var tension: Float { get set }
    var damping: Float { get set }
    var spread: Float { get set }
    var dropletsForce: Float { get set }
    var dropletsDensity: Float { get set }
    var dropletSize: Float { get set }
    
    // MARK: - Initializers
    
    init(with width: Float, numJoints: Int, surfaceHeight: Float, fillColor: UIColor)
    
    // MARK: - Methods
    
    // MARK: - Color
    
    func set(color: UIColor)
    
    // MARK: - Splash
    
    func splash(at x: CGFloat, force: CGFloat)
    func splash(at x: CGFloat, force: CGFloat, width: Float)
    
    // MARK: - Reset
    
    func reset()
}


extension UIColor {
    
    func toVector4() -> vector_float4 {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return vector_float4([Float(r), Float(g), Float(b), Float(a)])
    }
    
    func toVector() -> GLKVector4 {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return GLKVector4Make(Float(r), Float(g), Float(b), Float(a))
    }
}
