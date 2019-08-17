//
//  AimNode.swift
//  Ricochet
//
//  Created by Matthew Nam on 2017-12-27.
//  Copyright © 2017 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class AimNode : SKNode {
    
    private var dots : [SKSpriteNode] = []
    private var size : CGSize!
    private var gap : CGFloat!
    
    private var x : CGFloat = 0
    private var y : CGFloat = 0
    private var c : CGFloat = 0
    private var angleSnap : CGFloat = CGFloat.pi/36
    private var inverted : CGFloat = -1
    
    init(size: CGSize, gap: CGFloat) {
        super.init()
        
        name = "AimNode"
        self.size = size
        self.gap = gap
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public Methods
extension AimNode {
    
    func update() {
        var currentLength = c
        if currentLength == 0 {currentLength = 1}
        
        if Int(currentLength / gap) > dots.count {
            for i in dots.count + 1..<Int(currentLength / gap) + 1 {
                let dot = SKSpriteNode(imageNamed: "ball")
                dot.alpha = 1 - 0.08 * CGFloat(i)
                dot.zPosition = 2
                dot.size = CGSize(width: size.width, height: size.height)
                addChild(dot)
                dots.append(dot)
            }
        } else {
            let length = dots.count
            for _ in Int(currentLength / gap)..<length {
                dots[dots.count-1].removeFromParent()
                dots.removeLast()
            }
        }
        
        for i in 0..<Int(currentLength / gap) {
            dots[i].position = CGPoint(x: inverted * CGFloat(i + 1) * (x * gap / currentLength), y: inverted * CGFloat(i + 1) * (y * gap / currentLength))
        }
    }
    
    func remove() {
        self.removeAllChildren()
        dots = []
    }
}

// MARK: Getters and Setters
extension AimNode {
    func getX() -> CGFloat {
        return x
    }
    func getY() -> CGFloat {
        return y
    }
    func getC() -> CGFloat {
        return c
    }
    func getAngleSnap() -> CGFloat {
        return angleSnap
    }
    func invert() -> CGFloat {
        return inverted
    }
    func getFactor() -> CGFloat {
        return CGFloat(dots.count) / CGFloat(4.2)
    }
    
    func setX(_ x: CGFloat) {
        self.x = x
    }
    func setY(_ y: CGFloat) {
        self.y = y
    }
    func setC() {
        c = sqrt(x * x + y * y)
    }
    func invert(_ should: Bool) {
        if !should {inverted = -1}
        if should {inverted = 1}
    }
}
