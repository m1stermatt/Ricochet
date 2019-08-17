//
//  Hole.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-01-09.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class Hole : SKSpriteNode {
    
    private var radius : CGFloat!
    private var mass : CGFloat!
    private var particles : [SKSpriteNode] = []
    private var particleSize : CGSize!
    
    init(texture: SKTexture?, sizeFactor: CGFloat, shadowOffset: CGFloat) {
        super.init(texture: texture, color: SKColor.clear, size: CGSize(width: texture!.size().width/sizeFactor, height: texture!.size().height/sizeFactor))
        
        let shadowTexture = SKTexture(imageNamed: "holeShadow")
        let shadow = SKSpriteNode(texture: shadowTexture, color: SKColor.clear, size: CGSize(width: shadowTexture.size().width/sizeFactor, height: shadowTexture.size().height/sizeFactor))
        shadow.alpha = 0.3
        shadow.position = CGPoint(x: shadowOffset, y: shadowOffset)
        shadow.zPosition = -1
        addChild(shadow)
        
        radius = size.width * 2
        
        mass = 12000/sizeFactor
        
        particleSize = CGSize(width: 18 / sizeFactor, height: 18 / sizeFactor)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            mass = mass * 2
            particleSize = CGSize(width: 36 / sizeFactor, height: 36 / sizeFactor)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Public Methods
extension Hole {
    
    func update() {
        if randomNumber(to: 15) == 0 {
            createParticle()
        }
    }
    
    func getRadius() ->CGFloat {
        return radius
    }
    
    func getMass() -> CGFloat {
        return mass
    }
    
}

// MARK: Private Methods
extension Hole {
    
    private func createParticle() {
        let particle = SKSpriteNode(color: SKColor(red: 229.0/255, green: 150.0/255, blue: 156.0/255, alpha: 1), size: particleSize)
        
        let randomRadius = randomNumber(to: UInt32(radius/2 + 1)) + radius/2
        let randomX = randomNumber(to: UInt32(radius + 1)) - radius/2
        var randomY = sqrt(randomRadius * randomRadius - randomX * randomX)
        if randomNumber(to: 2) == 0 {
            randomY *= -1
        }
        
        particle.position = CGPoint(x: randomX, y: randomY)
        particle.zPosition = 0
        particle.alpha = 0
        addChild(particle)
        
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: TimeInterval(Double.random(min: 0.2, max: 0.4)))
        let move = SKAction.move(to: CGPoint.zero, duration: TimeInterval(Double.random(min: 1.3, max: 1.6)))
        let rotate = SKAction.rotate(byAngle: CGFloat(Double.random(min: Double.pi * 0.5, max: Double.pi * 1.5)), duration: move.duration)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: TimeInterval(Double.random(min: 0.4, max: 0.8)))
        
        let group1 = SKAction.sequence([.wait(forDuration: move.duration - fadeOut.duration), fadeOut])
        let group2 = SKAction.group([fadeIn, move, rotate, group1])
        
        let finish = SKAction.run {
            particle.removeFromParent()
        }
        
        particle.run(.sequence([group2, finish]))
        
    }
    
    private func randomNumber(to num: UInt32) -> CGFloat {
        return CGFloat(arc4random_uniform(num))
    }
    
}
