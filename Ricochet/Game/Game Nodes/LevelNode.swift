//
//  LevelNode.swift
//  Ricochet
//
//  Created by Matthew Nam on 2017-12-08.
//  Copyright © 2017 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

enum GameState {
    case start, play, lost, restarting, win, done
}

protocol LevelNodeDelegate : NSObjectProtocol {
    func playHit()
    func playWin()
    func playBad()
    func playUnlock()
    func cannotTap()
    func canTap()
}

class LevelNode : SKNode {
    
    /* Game Objects */
    private var ball : Ball!
    private var particleNode : SKNode!
    
    private var end : End!
    private var key : Key?
    private var holes : [Hole] = []
    private var falseEnds : [FalseEnd] = []
    
    private var beams : [Beam] = []
    private var dynamicBeams : [DynamicBeam] = []
    private var dynamicBeamShadows : [SKSpriteNode] = []
    
    /* Dynamic Beam Stuff */
    private var hasDynamic : Bool = false
    
    /* Aiming */
    private var aimNode : AimNode!
    
    /* Ball Speed Adjustments */
    private var gravityFactor : CGFloat = 0.02
    
    /* Control Stuff */
    private var controlBeam : SKSpriteNode?
    private var controlBeamShadow : SKSpriteNode?
    private var rotateIcon : SKSpriteNode?
    private var usesControlBeam : Bool = false
    private var middleOfScreen : CGPoint!
    private var previousTouch : CGPoint?
    
    /* State */
    private var state = GameState.start
    
    /* Sizing and Positioning Values */
    private var sizeFactor : CGFloat!
    private var width : CGFloat!
    private var height : CGFloat!
    
    /* Shortcut for pi */
    private var pi = CGFloat.pi
    
    /* Restart */
    private var restartDuration : TimeInterval!
    
    /* Delegate */
    weak var delegate : LevelNodeDelegate?
    
    override init() {
        super.init()
    }
    
    convenience init(level : [String: Any], delegate: LevelNodeDelegate?, needsControlBeam: Bool) {
        self.init()
        
        middleOfScreen = CGPoint(x: Screen.width/2, y: Screen.height/2)
        
        restartDuration = 0.2
        
        self.delegate = delegate
        
        var sizeWidth, sizeHeight : CGFloat
        
        if let dimensions = level["dimensions"] as? [CGFloat] {
            sizeFactor = dimensions[0]
            sizeWidth = dimensions[0]
            sizeHeight = dimensions[1]
            if UIDevice.current.userInterfaceIdiom == .pad {
                if sizeFactor == 3 {sizeFactor = 4}
                if sizeFactor == 4 && sizeHeight == 5 {sizeFactor = 5}
            }
            if sizeFactor == 1 {sizeFactor = dimensions[1]}
            if sizeFactor == 2 && sizeHeight > 2 {sizeFactor = 3}
        } else {
            sizeFactor = 1
            sizeWidth = 1
            sizeHeight = 1
        }
        
        var boxSize = 250 / sizeFactor
        var beamWidth = 210 / sizeFactor
        var beamHeight = 27 / sizeFactor
        var offsetX = beamHeight / 2
        var shadowOffset = 3 / sizeFactor
        var aimNodeGap : CGFloat = 50
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            boxSize *= 2
            beamWidth *= 2
            beamHeight *= 2
            offsetX *= 2
            shadowOffset *= 2
            aimNodeGap *= 2
            gravityFactor *= 2
        }
        
        gravityFactor /= sizeFactor
        
        width = boxSize * sizeWidth + beamHeight
        height = boxSize * sizeHeight
        
        if let hor = level["hor"] as? [[CGFloat]] {
            for plat in hor {
                switch plat[2] {
                case 0:
                    let beam = ObstacleBeam(texture: nil, size: CGSize(width: beamWidth, height: beamHeight))
                    beam.position = CGPoint(x: offsetX + boxSize/2 + boxSize * plat[0], y: boxSize * plat[1])
                    initBeam(beam: beam)
                default:
                    let beam = WallBeam(texture: nil, size: CGSize(width: beamWidth, height: beamHeight))
                    beam.position = CGPoint(x: offsetX + boxSize/2 + boxSize * plat[0], y: boxSize * plat[1])
                    initBeam(beam: beam)
                }
            }
        }
        
        if let vert = level["vert"] as? [[CGFloat]] {
            for plat in vert {
                switch plat[2] {
                case 0:
                    let beam = ObstacleBeam(texture: nil, size: CGSize(width: beamWidth, height: beamHeight))
                    beam.zRotation = pi / 2
                    beam.position = CGPoint(x: offsetX + boxSize * plat[0], y: boxSize/2 + boxSize * plat[1])
                    initBeam(beam: beam)
                default:
                    let beam = WallBeam(texture: nil, size: CGSize(width: beamWidth, height: beamHeight))
                    beam.zRotation = pi / 2
                    beam.position = CGPoint(x: offsetX + boxSize * plat[0], y: boxSize/2 + boxSize * plat[1])
                    initBeam(beam: beam)
                }
            }
        }
        
        if let dynamic = level["dynamic"] as? [[CGFloat]] {
            for plat in dynamic {
                let beam = DynamicBeam(texture: nil, size: CGSize(width: beamWidth * 0.95, height: beamHeight * 0.9), shadowOffset: shadowOffset)
                beam.position = CGPoint(x: offsetX + boxSize/2 + boxSize * plat[0], y: boxSize/2 + boxSize * plat[1])
                beam.rotate(withAngle: pi/4 * plat[2])
                beam.setInitialAngle(angle: pi/4 * plat[2])
                beam.zPosition = 2
                beams.append(beam)
                dynamicBeams.append(beam)
                addChild(beam)
                if !hasDynamic {hasDynamic = true}
            }
        }
        
        for beam in beams {
            let shadowTexture = SKTexture(imageNamed: "beamShadow")
            let shadow = SKSpriteNode(texture: shadowTexture, color: SKColor.clear,
                                      size: CGSize(width: shadowTexture.size().width * 0.9 / sizeFactor, height: shadowTexture.size().height * 0.8 / sizeFactor))
            shadow.position = CGPoint(x: beam.position.x + shadowOffset, y: beam.position.y + shadowOffset)
            shadow.alpha = 0.2
            shadow.zPosition = 1
            shadow.zRotation = beam.zRotation
            addChild(shadow)
            
            if beam is DynamicBeam {
                dynamicBeamShadows.append(shadow)
            }
        }
        
        var ballPos : CGPoint = CGPoint.zero
        if let pos = level["ball"] as? [CGFloat] {
            ballPos = CGPoint(x: pos[0], y: pos[1])
        }
        
        ball = Ball(texture: SKTexture(imageNamed: "ball"), sizeFactor: sizeFactor, shadowOffset: shadowOffset)
        ball.position = CGPoint(x: offsetX + boxSize/2 + boxSize * ballPos.x, y: boxSize/2 + boxSize * ballPos.y)
        ball.zPosition = 3
        ball.setStartPosition(p: ball.position)
        addChild(ball)
        
        particleNode = SKNode()
        particleNode.zPosition = 1
        addChild(particleNode)
        
        aimNode = AimNode(size: CGSize(width: ball.size.width * 0.5, height: ball.size.height * 0.5), gap: aimNodeGap / sizeFactor)
        aimNode.position = ball.position
        aimNode.zPosition = 3
        addChild(aimNode)
        
        var endPos : CGPoint = CGPoint.zero
        if let pos = level["end"] as? [CGFloat] {
            endPos = CGPoint(x: pos[0], y: pos[1])
        }
        
        let endTexture = SKTexture(imageNamed: "end")
        end = End(texture: endTexture,
                  sizeFactor: sizeFactor,
                  shadowOffset: shadowOffset)
        end.position = CGPoint(x: offsetX + boxSize/2 + boxSize * endPos.x, y: boxSize/2 + boxSize * endPos.y)
        end.zPosition = 0
        addChild(end)
        
        if let keyData = level["key"] as? [CGFloat] {
            let keyPos = CGPoint(x: keyData[0], y: keyData[1])
            let keyTexture = SKTexture(imageNamed: "key")
            key = Key(texture: keyTexture,
                      sizeFactor: sizeFactor,
                      shadowOffset: shadowOffset)
            key!.position = CGPoint(x: offsetX + boxSize/2 + boxSize * keyPos.x, y: boxSize/2 + boxSize * keyPos.y)
            key!.zPosition = 1
            key!.float()
            key!.setStartPos(key!.position)
            addChild(key!)
            
            if keyData.count == 4 {
                let duration = TimeInterval(CGPoint(x: keyData[3], y: keyData[2]).calcDistanceTo(p: CGPoint.zero) * 1.5)
                key!.move(from: key!.position, to: CGPoint(x: key!.position.x + boxSize*keyData[2], y: key!.position.y + boxSize*keyData[3]), withDuration: duration)
            }
            
            key!.animate()
            
            end.lock()
        }
        
        if let hole = level["holes"] as? [[CGFloat]] {
            
            for data in hole {
                let holeTexture = SKTexture(imageNamed: "hole")
                let hole = Hole(texture: holeTexture, sizeFactor: sizeFactor, shadowOffset: shadowOffset)
                hole.position = CGPoint(x: offsetX + boxSize/2 + boxSize * data[0], y: boxSize/2 + boxSize * data[1])
                hole.zPosition = 2
                holes.append(hole)
                addChild(hole)
            }
        }
        
        if let falseEnd = level["falseEnd"] as? [[CGFloat]] {
            for data in falseEnd {
                let texture = SKTexture(imageNamed: "falseEnd")
                let falseEnd = FalseEnd(texture: texture, sizeFactor: sizeFactor, shadowOffset: shadowOffset)
                falseEnd.position = CGPoint(x: offsetX + boxSize/2 + boxSize * data[0], y: boxSize/2 + boxSize * data[1])
                falseEnd.zPosition = 2
                falseEnds.append(falseEnd)
                addChild(falseEnd)
            }
        }
        
        if needsControlBeam && hasDynamic && level["exception"] as? String == nil {
            
            let shadowTexture = SKTexture(imageNamed: "beamShadow")
            let shadowTextureSize = CGSize(width: shadowTexture.size().width / 2, height: shadowTexture.size().height / 2)
            var controlBeamPosition : CGFloat = 110
            var controlBeamSize = CGSize(width: 92, height: 12)
            
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 2436:
                    controlBeamPosition = 160
                default:
                    break
                }
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                controlBeamPosition = 220
                controlBeamSize = CGSize(width: 184, height: 24)
            }
            
            controlBeam = SKSpriteNode(texture: nil,
                                       color: SKColor(red: 97.0/255, green: 97.0/255, blue: 97.0/255, alpha: 1),
                                       size: controlBeamSize)
            controlBeam!.position = CGPoint(x: width/2, y: controlBeamPosition - (Screen.height - height) / 2)
            controlBeam!.zPosition = 2
            addChild(controlBeam!)
            
            controlBeamShadow = SKSpriteNode(texture: shadowTexture, color: SKColor.clear,
                                             size: shadowTextureSize)
            controlBeamShadow!.position = controlBeam!.position
            controlBeamShadow!.alpha = 0.2
            controlBeamShadow!.zPosition = 1
            addChild(controlBeamShadow!)
            
            rotateIcon = SKSpriteNode(imageNamed: "rotateIcon")
            rotateIcon!.position = controlBeam!.position
            rotateIcon!.zPosition = 0
            rotateIcon!.isHidden = true
            rotateIcon!.alpha = 0
            addChild(rotateIcon!)
            
            usesControlBeam = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initBeam(beam: Beam) {
        beam.zPosition = 2
        beams.append(beam)
        addChild(beam)
    }
    
    private func handleCollision() {
        
        if checkBox(node: end) {
            if !end.getDoesLookLocked() {
                if spiral(node: end, mass: end.getMass()) {
                    win()
                    ball.position = end.position
                }
            }
        }
        if let key = self.key {
            if checkBox(node: key) && end.getDoesLookLocked() {
                key.isHidden = true
                key.stopFloating()
                end.unlock()
                delegate?.playUnlock()
                
                particle(node: key, file: "KeyParticle", state: nil)
            }
        }
        for hole in holes {
            if checkCircle(radius: hole.getRadius(), pos: hole.position) {
                if spiral(node: hole, mass: hole.getMass()) {
                    ball.position = hole.position
                    lostGame(playSound: true)
                }
            }
        }
        for falseEnd in falseEnds {
            if checkBox(node: falseEnd) {
                if spiral(node: falseEnd, mass: falseEnd.getMass()) {
                    ball.position = falseEnd.position
                    lostGame(playSound: true)
                }
            }
        }
        
        for beam in beams {
            if !beam.canCollide {
                let collisionEngine = CollisionEngine(ball: ball, beam: beam)
                
                if collisionEngine.didCollide() {
                    if beam is ObstacleBeam {
                        lostGame(playSound: true)
                    }
                    else {
                        delegate?.playHit()
                        ball.position = collisionEngine.getNewPos()!
                        ball.setVel(vel: collisionEngine.getNewVel()!)
                    }
                }
            }
        }
    }
    
    private func checkBox(node: SKSpriteNode) -> Bool {
        return CollisionEngine.checkBox(node: node, radius: ball.getRadius(), position: ball.position)
    }
    
    private func checkCircle(radius: CGFloat, pos: CGPoint) -> Bool {
        
        let r = ball.getRadius()
        
        let dis = CGPoint.zero.calcDistanceTo(p: ball.position.subtract(p: pos))
        
        if dis >= r + radius {
            return false
        }
        
        return true
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
        let touch = pos
        
        switch state {
        case .start, .restarting, .lost: previousTouch = touch
        case .play:
            previousTouch = touch
            
            for beam in dynamicBeams {
                beam.beganRotating()
            }
        default: break
        }
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        let touch = pos
        
        switch state {
        case .start, .restarting, .lost:
            if let preTouch = previousTouch {
                if touch.x != preTouch.x || touch.y != preTouch.y {
                    
                    aimNode.setX(touch.x - preTouch.x)
                    aimNode.setY(touch.y - preTouch.y)
                    aimNode.setC()
                    
                    let aimMargin = aimNode.getAngleSnap()
                    
                    let angle = touch.calcAngleTo(p: preTouch)
                    
                    if isBetween(num: angle, min: -aimMargin, max: aimMargin) || isBetween(num: angle, min: 2 * pi - aimMargin, max: 2 * pi + aimMargin) {
                        aimNode.setX(aimNode.getC())
                        aimNode.setY(0)
                    }
                    else if isBetween(num: angle, min: 0.5 * pi - aimMargin, max: 0.5 * pi + aimMargin) {
                        aimNode.setX(0)
                        aimNode.setY(aimNode.getC())
                    }
                    else if isBetween(num: angle, min: pi - aimMargin, max: pi + aimMargin) {
                        aimNode.setX(-aimNode.getC())
                        aimNode.setY(0)
                    }
                    else if isBetween(num: angle, min: 1.5 * pi - aimMargin, max: 1.5 * pi + aimMargin) {
                        aimNode.setX(0)
                        aimNode.setY(-aimNode.getC())
                    }
                    
                    aimNode.update()
                    
                }
            }
        case .play:
            if hasDynamic {
                if let preTouch = previousTouch {
                    
                    var theta : CGFloat = 0
                    
                    if let controlBeam = controlBeam {
                        let controlBeamPosition = controlBeam.position.add(p: position)
                        let previousTheta = CGFloat(atan((preTouch.y - controlBeamPosition.y)/(preTouch.x - controlBeamPosition.x)))
                        theta = (CGFloat(atan((touch.y - controlBeamPosition.y)/(touch.x - controlBeamPosition.x))) - previousTheta)
                        controlBeam.zRotation = controlBeam.zRotation + theta
                        controlBeam.zRotation -= CGFloat(Int(controlBeam.zRotation / (pi * 2))) * pi * 2
                        controlBeamShadow!.zRotation = controlBeam.zRotation
                    } else {
                        let previousTheta = CGFloat(atan((preTouch.y - middleOfScreen.y)/(preTouch.x - middleOfScreen.x)))
                        theta = (CGFloat(atan((touch.y - middleOfScreen.y)/(touch.x - middleOfScreen.x))) - previousTheta)
                        let moreTheta = touch.calcDistanceTo(p: preTouch) * 0.003
                        theta += theta > 0 ? moreTheta : -moreTheta
                    }
                    
                    for i in 0..<dynamicBeams.count {
                        dynamicBeams[i].rotate(withAngle: CGFloat(theta))
                        dynamicBeamShadows[i].zRotation = dynamicBeamShadows[i].zRotation + theta
                        dynamicBeamShadows[i].zRotation -= CGFloat(Int(dynamicBeamShadows[i].zRotation / (pi * 2))) * pi * 2
                    }
                    previousTouch = touch
                    
                }
            }
        default: break
        }
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
        let touch = pos
        
        switch state {
        case .start:
            if let preTouch = previousTouch {
                if touch.x != preTouch.x || touch.y != preTouch.y {
                    
                    ball.setSpeed(s: (ball.getMinSpeed() + aimNode.getFactor()) / sizeFactor)
                    aimNode.remove()
                    
                    let vel = CGPoint(x: ball.getSpeed() * (aimNode.getX()*aimNode.invert()/aimNode.getC()), y: ball.getSpeed() * (aimNode.getY()*aimNode.invert()/aimNode.getC()))
                    ball.setVel(vel: vel)
                    
                    state = .play
                    delegate?.cannotTap()
                    showRotateIcon()
                    
                    let particleEmitter = SKEmitterNode(fileNamed: "BallTrail")!
                    particleEmitter.particleSize = ball.size
                    particleEmitter.zPosition = 1
                    particleEmitter.name = "trail"
                    particleEmitter.targetNode = particleNode
                    ball.addChild(particleEmitter)
                }
            }
        case .restarting, .lost:
            if let preTouch = previousTouch {
                if touch.x != preTouch.x || touch.y != preTouch.y {
                    aimNode.remove()
                }
            }
        case .play:
            for beam in dynamicBeams {
                beam.stoppedRotating()
            }
        default: break
        }
        
    }
    
    func update() {
        for hole in holes {
            hole.update()
        }
        
        switch state {
        case .lost:
            ball.alpha = ball.alpha - 0.05
            
            if ball.alpha <= 0 {
                restart()
            }
        case .play:
            ball.update()
            handleCollision()
            
            let margin = 0.3 * ball.getSpeed() * 60 // 60 fps
            if  ball.position.x <= -position.x - margin ||
                ball.position.x >= Screen.width - position.x + margin ||
                ball.position.y <= -position.y - margin ||
                ball.position.y >= Screen.height - position.y + margin {
                lostGame(playSound: false)
            }
        default: break
        }
    }
}

// MARK: Public Methods
extension LevelNode {
    
    func pause() {
        if let key = self.key {
            key.pauseMovement()
        }
    }
    
    func unpause() {
        if let key = self.key {
            key.unpauseMovement()
        }
    }
    
    func isPlaying() -> Bool {
        switch state {
        case .play:
            return true
        default:
            return false
        }
    }
    
    func win() {
        delegate?.playWin()
        state = .win
        particle(node: ball, file: "WinParticle", state: .done)
    }
    
    func hasDynamicBeam() -> Bool {
        return hasDynamic
    }
    
    func getState() -> GameState {
        return state
    }
    
    func getWidth() -> CGFloat {
        return width
    }
    
    func getHeight() -> CGFloat {
        return height
    }
    
    func getControlBeamPos() -> CGPoint {
        return controlBeam!.position
    }
    
    func doesUseControlBeam() -> Bool {
        return usesControlBeam
    }
    
    func lostGame(playSound: Bool) {
        if playSound {
            delegate?.playBad()
        }
        state = .lost
        previousTouch = nil
        ball.childNode(withName: "trail")?.removeFromParent()
    }
    
    func invertControls(invert: Bool) {
        aimNode.invert(invert)
    }
    
}

// MARK: Private Methods
extension LevelNode {
    
    private func showRotateIcon() {
        if let rotateIcon = rotateIcon {
            rotateIcon.isHidden = false
            rotateIcon.run(.group([.fadeAlpha(to: 1, duration: 1)]))
        }
    }
    
    private func hideRotateIcon() {
        if let rotateIcon = rotateIcon {
            rotateIcon.run(.sequence([.fadeAlpha(to: 0, duration: 0.3),
                                      .run {
                                        rotateIcon.isHidden = true
                                        rotateIcon.zRotation = 0
                                        rotateIcon.removeAllActions()
                                        }]))
        }
    }
    
    private func restart() {
        state = .restarting
        delegate?.canTap()
        
        ball.position = ball.getStartPosition()
        ball.run(SKAction.fadeAlpha(to: 1, duration: restartDuration))
        
        if let key = self.key {
            if key.isHidden {
                key.alpha = 0
                key.isHidden = false
                key.reset()
                particle(node: key, file: "KeyParticle", state: nil)
                key.animate()
                key.run(SKAction.fadeAlpha(to: 1, duration: restartDuration))
                
                end.lock()
            }
        }
        for i in 0..<dynamicBeams.count {
            dynamicBeams[i].reset(withDuration: restartDuration)
            dynamicBeams[i].stoppedRotating()
            dynamicBeamShadows[i].run(SKAction.rotate(toAngle: dynamicBeams[i].getInitialAngle(), duration: restartDuration))
        }
        if let controlBeam = controlBeam {
            controlBeam.run(SKAction.rotate(toAngle: 0, duration: restartDuration))
            controlBeamShadow!.run(SKAction.rotate(toAngle: 0, duration: restartDuration))
        }
        let wait = SKAction.wait(forDuration: restartDuration)
        let setState = SKAction.run {self.state = .start; self.hideRotateIcon()}
        let sequence = SKAction.sequence([wait, setState])
        run(sequence)
    }
    
    private func particle(node: SKSpriteNode, file: String, state: GameState?) {
        let emitter = SKEmitterNode(fileNamed: file)!
        emitter.particleSpeed = emitter.particleSpeed / sizeFactor
        emitter.particleSpeed *= UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
        emitter.particleSize = node.size
        emitter.position = node.position
        emitter.zPosition = 1
        addChild(emitter)
        
        let emitterDuration = emitter.particleLifetime
        let wait = SKAction.wait(forDuration: TimeInterval(emitterDuration))
        let finish = SKAction.run({
            emitter.removeFromParent()
            if state != nil {
                self.state = state!
                self.delegate?.canTap()
            }
        })
        let sequence = SKAction.sequence([wait, finish])
        run(sequence)
    }
    
    private func spiral(node: SKSpriteNode, mass: CGFloat) -> Bool {
        
        let setSpeed = ball.getSpeed()
        
        if ball.position.calcDistanceTo(p: node.position) < setSpeed * 0.7 {
            return true
        }
        
        let radius = ball.position.calcDistanceTo(p: node.position)
        let mass1 : CGFloat = ball.getMass()
        let mass2 : CGFloat = mass
        let gravityMagnitude = mass1 * mass2 / pow(radius, 2)
        let displacement = node.position.subtract(p: ball.position)
        let g = CGPoint(x: gravityMagnitude * displacement.x / radius * gravityFactor, y: gravityMagnitude * displacement.y / radius * gravityFactor)
        let vel = ball.getVel()
        
        ball.setVel(vel: CGPoint(x: vel.x + g.x, y: vel.y + g.y))
        
        let speed = ball.getVel().calcDistanceTo(p: CGPoint.zero)
        ball.setVel(vel: CGPoint(x: setSpeed * ball.getVel().x / speed, y: setSpeed * ball.getVel().y / speed))
        
        return false
    }
    
    private func isBetween(num: CGFloat, min: CGFloat, max: CGFloat) -> Bool {
        if num >= min && num <= max {
            return true
        }
        return false
    }
    
    private func getAngle(dx: CGFloat, dy: CGFloat) -> CGFloat {
        var theta = atan(dy/dx)
        if dx == 0 && dy > 0 {theta = 0}
        return theta
    }
}
