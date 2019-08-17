//
//  HelpDisplay.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-01-21.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class HelpDisplay : SKNode {
    
    private var platform : SKSpriteNode!
    private var fingerTouch : SKSpriteNode!
    
    private var height : CGFloat!
    
    private var dynamicInitialColor : SKColor!
    private var dynamicRotatingColor : SKColor!
    
    private var touchStartPos : CGPoint!
    private var startAngle : CGFloat!
    private var animation : SKAction!
    
    override init() {
        super.init()
        
        dynamicInitialColor = SKColor(red: 157.0/255, green: 223.0/255, blue: 160.0/255, alpha: 1)
        dynamicRotatingColor = SKColor(red: 216.0/255, green: 238.0/255, blue: 217.0/255, alpha: 1)
        
        height = 270
        var animationAreaStart : CGFloat = 60       // Start of animation area
        var animationAreaHeight : CGFloat = 130     // Height of animation area
        var displacement : CGFloat = 30             // For the angle calcualtion for the animation
        var fontSize : CGFloat = 18                 // Font size for text boxes
        var marginY : CGFloat = 30                  // To space out each text box
        var platformSize = CGSize(width: 48, height: 6)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            height = 540
            animationAreaStart = 120
            animationAreaHeight = 260
            displacement = 60
            fontSize = 36
            marginY = 60
            platformSize = CGSize(width: 96, height: 12)
        }
        
        let helpBackground = SKSpriteNode(texture: nil,
                                          color: SKColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1),
                                          size: CGSize(width: Screen.width,
                                                       height: height * 1.1))
        helpBackground.zPosition = 0
        helpBackground.position = CGPoint(x: helpBackground.size.width/2, y: helpBackground.size.height * 0.5 - helpBackground.size.height / 1.1)
        addChild(helpBackground)
        
        let middle : CGFloat = -animationAreaStart - animationAreaHeight * 0.5
        let width : CGFloat = calculateAccumulatedFrame().width
        
        let help1 = SKLabelNode(fontNamed: "Futura-Medium")
        help1.fontSize = fontSize
        help1.fontColor = SKColor(red: 96.0/255, green: 96.0/255, blue: 96.0/255, alpha: 1)
        help1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        help1.zPosition = 1
        help1.position = CGPoint(x: width * 0.5, y: -marginY)
        help1.text = NSLocalizedString("Drag to aim ball. After, rotate", comment: "")
        addChild(help1)
        
        let help2 = SKLabelNode(fontNamed: "Futura-Medium")
        help2.fontSize = fontSize
        help2.fontColor = SKColor(red: 96.0/255, green: 96.0/255, blue: 96.0/255, alpha: 1)
        help2.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        help2.zPosition = 1
        help2.position = CGPoint(x: width * 0.5, y: -marginY * 2)
        help2.text = NSLocalizedString("green beams by dragging finger:", comment: "")
        addChild(help2)
        
        let help3 = SKLabelNode(fontNamed: "Futura-Medium")
        help3.fontSize = fontSize
        help3.fontColor = SKColor(red: 96.0/255, green: 96.0/255, blue: 96.0/255, alpha: 1)
        help3.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        help3.zPosition = 1
        help3.position = CGPoint(x: width * 0.5, y: marginY * 2 - height)
        help3.text = NSLocalizedString("While rotating, green bars", comment: "")
        addChild(help3)
        
        let help4 = SKLabelNode(fontNamed: "Futura-Medium")
        help4.fontSize = fontSize
        help4.fontColor = SKColor(red: 96.0/255, green: 96.0/255, blue: 96.0/255, alpha: 1)
        help4.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        help4.zPosition = 1
        help4.position = CGPoint(x: width * 0.5, y: marginY - height)
        help4.text = NSLocalizedString("become invisible", comment: "")
        addChild(help4)
        
        platform = SKSpriteNode(color: dynamicInitialColor, size: platformSize)
        platform.position = CGPoint(x: width * 0.75, y: middle)
        platform.zPosition = 1
        platform.alpha = 0
        addChild(platform)
        
        touchStartPos = CGPoint(x: width * 0.3, y: displacement + middle)
        startAngle = touchStartPos.calcAngleTo(p: platform.position)
        let endAngle = CGPoint(x: touchStartPos.x, y: middle - displacement).calcAngleTo(p: platform.position)
        
        let fingerTouchTexture = SKTexture(imageNamed: "touch")
        fingerTouch = SKSpriteNode(texture: fingerTouchTexture, color: SKColor.clear, size: fingerTouchTexture.size())
        fingerTouch.anchorPoint = CGPoint(x: 0.79, y: 0.8)
        fingerTouch.position = touchStartPos
        fingerTouch.zPosition = 1
        fingerTouch.alpha = 0
        addChild(fingerTouch)
        
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.5)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
        let startAnimation = SKAction.run {
            self.platform.run(fadeIn)
        }
        let endAnimation = SKAction.sequence([
            .run {
                self.platform.run(fadeOut)
            },
            .wait(forDuration: fadeOut.duration),
            .run {
                self.platform.zRotation = 0
                self.fingerTouch.position = self.touchStartPos
            }
            ])
        
        let radius = platform.position.calcDistanceTo(p: touchStartPos)
        let path = UIBezierPath(arcCenter: platform.position, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let pause = SKAction.wait(forDuration: 1)
        let moveTouch = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, duration: 1.2)
        let rotatePlatform = SKAction.rotate(byAngle: endAngle - startAngle, duration: 1.2)
        moveTouch.timingMode = SKActionTimingMode.easeInEaseOut
        rotatePlatform.timingMode = SKActionTimingMode.easeInEaseOut
        
        animation = SKAction.repeatForever(SKAction.sequence([
            pause,
            startAnimation,
            .wait(forDuration: 1),
            .run {
                self.fingerTouch.run(.fadeAlpha(to: 1, duration: 0.5))
                self.platform.color = self.dynamicRotatingColor
            },
            .wait(forDuration: 1),
            .run {
                self.fingerTouch.run(moveTouch)
                self.platform.run(rotatePlatform)
            },
            .wait(forDuration: moveTouch.duration),
            .run{
                self.platform.color = self.dynamicInitialColor
                self.fingerTouch.run(fadeOut)
            },
            .wait(forDuration: 1),
            endAnimation
            ]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Public Methods
extension HelpDisplay {
    func animate() {
        platform.zRotation = 0
        platform.alpha = 0
        platform.color = dynamicInitialColor
        fingerTouch.alpha = 0
        fingerTouch.position = touchStartPos
        run(animation)
    }
    func reset() {
        removeAllActions()
        platform.removeAllActions()
        fingerTouch.removeAllActions()
    }
    func getHeight() -> CGFloat {
        return height
    }
}
