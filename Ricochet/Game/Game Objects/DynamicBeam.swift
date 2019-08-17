//
//  DynamicBeam.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-04-04.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class DynamicBeam : Beam {
    
    private var initialAngle : CGFloat!
    
    private static var initialColor = SKColor(red: 157.0/255, green: 223.0/255, blue: 160.0/255, alpha: 1)
    private static var rotatingColor = SKColor(red: 216.0/255, green: 238.0/255, blue: 217.0/255, alpha: 1)
    
    init(texture: SKTexture?, size: CGSize, shadowOffset: CGFloat) {
        super.init(texture: texture, color: DynamicBeam.initialColor, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Public Methods
extension DynamicBeam {
    
    func setInitialAngle(angle: CGFloat) {
        initialAngle = angle
    }
    
    func getInitialAngle() -> CGFloat {
        return initialAngle
    }
    
    func reset(withDuration duration: TimeInterval) {
        let rotate = SKAction.rotate(toAngle: initialAngle, duration: duration)
        run(rotate)
    }
    
    func rotate(withAngle theta: CGFloat) {
        zRotation += theta
        zRotation -= CGFloat(Int(zRotation / (CGFloat.pi * 2))) * CGFloat.pi * 2
    }
    
    func beganRotating() {
        if !canCollide {
            canCollide = true
            self.color = DynamicBeam.rotatingColor
        }
    }
    
    func stoppedRotating() {
        self.color = DynamicBeam.initialColor
        canCollide = false
    }
    
}
