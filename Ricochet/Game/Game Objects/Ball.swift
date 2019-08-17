//
//  Ball.swift
//  Ricochet
//
//  Created by Matthew Nam on 2017-12-08.
//  Copyright © 2017 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class Ball : SKSpriteNode {
    
    private var scaler : CGFloat = 1.1
    private var vel : CGPoint!
    private var radius : CGFloat!
    private var spd : CGFloat = 0
    private var mass : CGFloat = 12
    
    private var startPosition : CGPoint = CGPoint.zero
    
    private var minSpeed : CGFloat = 5
    private var maxSpeed : CGFloat = 8.4
    
    init(texture: SKTexture?, sizeFactor: CGFloat, shadowOffset: CGFloat)  {
        super.init(texture: texture, color: SKColor.clear, size: CGSize(width: texture!.size().width/sizeFactor/scaler, height: texture!.size().height/sizeFactor/scaler))
        
        vel = CGPoint.zero
        radius = size.width/2
        
        let shadowTexture = SKTexture(imageNamed: "ballShadow")
        let shadow = SKSpriteNode(texture: shadowTexture, color: SKColor.clear, size: CGSize(width: shadowTexture.size().width/sizeFactor/scaler,
                                                                                             height: shadowTexture.size().height/sizeFactor/scaler))
        shadow.alpha = 0.3
        shadow.position = CGPoint(x: shadowOffset * 0.8, y: shadowOffset * 0.8)
        shadow.zPosition = -1
        addChild(shadow)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            minSpeed = minSpeed * 2
            maxSpeed = maxSpeed * 2
            mass = mass * 2
        }
        
        maxSpeed /= sizeFactor
        mass /= sizeFactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public Methods
extension Ball {
    
    func setSpeed(s: CGFloat) {
        if s > maxSpeed {
            self.spd = maxSpeed
        } else {
            self.spd = s
        }
    }
    
    func setVel(vel: CGPoint) {
        self.vel = vel
    }
    
    func setStartPosition(p: CGPoint) {
        startPosition = p
    }
    
    func update() {
        position.x += vel.x
        position.y += vel.y
    }
    
    func getRadius() -> CGFloat {
        return radius;
    }
    
    func getSpeed() -> CGFloat {
        return spd
    }
    
    func getMass() -> CGFloat {
        return mass
    }
    
    func getVel() -> CGPoint {
        return vel
    }
    
    func getStartPosition() -> CGPoint {
        return startPosition
    }
    
    func getMinSpeed() -> CGFloat {
        return minSpeed
    }
    
}
