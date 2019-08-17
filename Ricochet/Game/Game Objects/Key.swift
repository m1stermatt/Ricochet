//
//  Key.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-01-09.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class Key : SKSpriteNode {
    
    private var startPos : CGPoint?
    private var endPos : CGPoint?
    private var duration : TimeInterval?
    
    init(texture: SKTexture?, sizeFactor: CGFloat, shadowOffset: CGFloat) {
        super.init(texture: texture, color: SKColor.clear, size: CGSize(width: texture!.size().width/sizeFactor, height: texture!.size().height/sizeFactor))
        
        let shadowTexture = SKTexture(imageNamed: "keyShadow")
        let shadow = SKSpriteNode(texture: shadowTexture, color: SKColor.clear, size: CGSize(width: shadowTexture.size().width/sizeFactor, height: shadowTexture.size().height/sizeFactor))
        shadow.position = CGPoint(x: shadowOffset, y: shadowOffset)
        shadow.zPosition = -1
        addChild(shadow)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public Methods
extension Key {
    
    func setStartPos(_ pos: CGPoint) {
        startPos = pos
    }
    
    func float() {
        let floatDif = size.height/4
        self.startPos = CGPoint(x: position.x, y: position.y - floatDif)
        self.endPos = CGPoint(x: position.x, y: position.y + floatDif)
        self.duration = 0.8
    }
    
    func move(from startPos: CGPoint, to endPos: CGPoint, withDuration duration: TimeInterval) {
        self.startPos = startPos
        self.endPos = endPos
        self.duration = duration
    }
    
    func animate() {
        removeAllActions()
        let move1, move2 : SKAction
        move1 = SKAction.move(to: endPos!, duration: duration!)
        move2 = SKAction.move(to: startPos!, duration: duration!)
        move1.timingMode = SKActionTimingMode.easeInEaseOut
        move2.timingMode = SKActionTimingMode.easeInEaseOut
        let action = SKAction.repeatForever(SKAction.sequence([move1, move2]))
        run(action)
    }
    
    func pauseMovement() {
        isPaused = true
    }
    
    func unpauseMovement() {
        isPaused = false
    }
    
    func stopFloating() {
        removeAllActions()
    }
    
    func reset() {
        position = startPos!
    }
    
}
