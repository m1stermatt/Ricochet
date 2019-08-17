//
//  GameScene.swift
//  Ricochet
//
//  Created by Matthew Nam on 2017-12-08.
//  Copyright © 2017 WamDev. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Screen {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let statusBarHeight = UIApplication.shared.statusBarFrame.height * 0.8
}

enum State {
    case game, transition, header
}

protocol GameSceneDelegate : NSObjectProtocol {
    func promptForPurchase()
    func promptToSkip()
}

class GameScene: SKScene {
    
    /* Delegate */
    weak var gameDelegate : GameSceneDelegate?
    
    /* Screen Stuff */
    private let screenSize = CGSize(width: Screen.width, height: Screen.height)
    
    /* Level */
    private var currentLevel = 0
    private var previousLevel = 1
    private var levelNode : LevelNode!
    private var levels : [Any]?
    private var skipAmount : Int = 0 {
        didSet {
            topButtonsNode.setSkipAmount(skipAmount)
        }
    }
    
    /* State */
    private var state = State.transition
    
    /* Menu */
    private var scrollView : LevelDisplayScrollView!
    private var header : Header!
    private var headerHeight : CGFloat!
    private var topButtonsNode : TopButtonsNode!
    private var topButtonsVisible : Bool = false
    
    /* Gestures */
    let doubleTap = UITapGestureRecognizer()
    let singleTap = TouchGestureRecognizer()
    
    /* Settings */
    private var controlsInverted : Bool = false {
        didSet {
            if levelNode != nil {
                levelNode.invertControls(invert: controlsInverted)
            }
            header.invertButtonDidChange(inverted: controlsInverted)
            UserDefaults.standard.set(controlsInverted, forKey: "controls")
        }
    }
    private var soundToggle : Bool = true {
        didSet {
            header.soundToggleDidChange(isSound: soundToggle)
            UserDefaults.standard.set(soundToggle, forKey: "sound")
        }
    }
    private var musicToggle : Bool = true {
        didSet {
            header.musicToggleDidChange(isMusic: musicToggle)
            UserDefaults.standard.set(musicToggle, forKey: "music")
            if musicToggle {
                addChild(backgroundMusic)
            }
            else {
                backgroundMusic.removeFromParent()
            }
        }
    }
    private var usesRotateBeam : Bool = false {
        didSet {
            header.rotateControlSettingChange(uses: usesRotateBeam)
            UserDefaults.standard.set(usesRotateBeam, forKey: "rotateControls")
        }
    }
    private var doubleTapToRestart : Bool = true {
        didSet {
            header.doubleTapControlSettingChange(yes: doubleTapToRestart)
            UserDefaults.standard.set(doubleTapToRestart, forKey: "doubleTap")
            if !doubleTapToRestart {
                self.view!.removeGestureRecognizer(doubleTap)
            }
            else {
                self.view!.addGestureRecognizer(doubleTap)
            }
        }
    }
    
    /* Covers */
    private var tint : SKSpriteNode!
    private var curtain : Curtain!
    
    /* Tutorial Variables */
    private var message : Message!
    private var needsMessage : Bool = false
    private var messageMessage : String!
    private var fingerTouch : SKSpriteNode!
    private var needsRotateTutorial = false
    
    /* Sounds */
    private let hit1 : SKAction = SKAction.playSoundFileNamed("hit1.m4a", waitForCompletion: false)
    private let hit2 : SKAction = SKAction.playSoundFileNamed("hit2.m4a", waitForCompletion: false)
    private let win : SKAction = SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false)
    private let bad1 : SKAction = SKAction.playSoundFileNamed("bad1.mp3", waitForCompletion: false)
    private let bad2 : SKAction = SKAction.playSoundFileNamed("bad2.mp3", waitForCompletion: false)
    private let unlock : SKAction = SKAction.playSoundFileNamed("unlock.mp3", waitForCompletion: false)
    
    /* Background Music */
    private var backgroundMusic : SKAudioNode!
    
    // MARK: Did Move to View
    override func didMove(to view: SKView) {
        
        if let musicURL = Bundle.main.url(forResource: "song", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
        }
        
        self.view!.isMultipleTouchEnabled = false
        
        do {
            if let file = Bundle.main.url(forResource: "levels", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data) as? [Any]
                if let object = json {
                    levels = object
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        
        doubleTap.addTarget(self, action:#selector(doubleTapped(_:) ))
        doubleTap.numberOfTouchesRequired = 1
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesEnded = false
        
        singleTap.addTarget(self, action:#selector(singleTapped(_:) ))
        singleTap.cancelsTouchesInView = false
        singleTap.delaysTouchesEnded = false
        self.view!.addGestureRecognizer(singleTap)
        
        headerHeight = 60
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            headerHeight = 120
            Message.fontSize = 36
        }
        
        header = Header(size: CGSize(width: screenSize.width, height: headerHeight), levelCount: levels!.count, delegate: self)
        header.position = CGPoint(x: 0, y: screenSize.height)
        header.zPosition = 5
        header.isHidden = true
        addChild(header)
        
        let levelsSize = CGSize(width: header.levels.calculateAccumulatedFrame().size.width, height: header.getLevelDisplayShowHeight())
        scrollView = LevelDisplayScrollView(frame: CGRect(origin: CGPoint(x: 0, y: header.getHeaderHeight()), size: CGSize(width: screenSize.width, height: levelsSize.height)),
                                            scene: self,
                                            moveableNode: header.levels)
        scrollView.isHidden = true
        scrollView.contentSize = levelsSize
        view.addSubview(scrollView)
        
        topButtonsNode = TopButtonsNode(delegate: self, offset: headerHeight / 2)
        topButtonsNode.position = CGPoint(x: 0, y: Screen.height + headerHeight)
        topButtonsNode.zPosition = 9
        topButtonsNode.isHidden = true
        addChild(topButtonsNode)
        
        tint = SKSpriteNode(color: SKColor.black, size: screenSize)
        tint.position = CGPoint(x: tint.size.width/2, y: tint.size.height/2)
        tint.zPosition = 4
        tint.isHidden = true
        tint.alpha = 0
        addChild(tint)
        
        curtain = Curtain(delegate: self)
        curtain.isHidden = true
        curtain.position = CGPoint(x: 0, y: screenSize.height)
        curtain.zPosition = 20
        addChild(curtain)
        
        message = Message()
        message.position = CGPoint(x: screenSize.width/2, y: screenSize.height * 0.76)
        message.isHidden = true
        message.zPosition = 2
        addChild(message)
        
        let fingerTouchTexture = SKTexture(imageNamed: "touchReflected")
        fingerTouch = SKSpriteNode(texture: fingerTouchTexture, color: SKColor.clear, size: fingerTouchTexture.size())
        fingerTouch.anchorPoint = CGPoint(x: 0.21, y: 0.8)
        fingerTouch.zPosition = 3.8
        fingerTouch.alpha = 0
        fingerTouch.isHidden = true
        addChild(fingerTouch)
        
        userDefaults()
        
        let page = currentLevel / header.getLevelsPerPage() + 1
        scrollView.goToPage(number: page)
        
        loadLevel(shouldExpand: false)
    }
    
    func setDelegate(_ gameDelegate: GameSceneDelegate) {
        self.gameDelegate = gameDelegate
    }
    
    func unlockAllLevels() {
        header.unlockAllLevels()
        UserDefaults.standard.set(levels!.count - 1, forKey: "unlocked")
    }
    
    func addSkips() {
        skipAmount += 5
        UserDefaults.standard.set(skipAmount, forKey: "skips")
    }
    
    func skip() {
        skipAmount -= 1
        UserDefaults.standard.set(skipAmount, forKey: "skips")
        levelNode.win()
    }
    
    /// MARK: Touches
    func touchDown(atPoint pos : CGPoint) {
        switch state {
        case .game:
            levelNode.touchDown(atPoint: pos)
        default: break
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        switch state {
        case .game: levelNode.touchMoved(toPoint: pos)
        default: break
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        switch state {
        case .game:
            levelNode.touchUp(atPoint: pos)
        case .header:
            if !header.contains(pos) {
                hideHeader()
                levelNode.unpause()
                state = .game
            }
        default: break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    /// MARK: Update
    override func update(_ currentTime: TimeInterval) {
        switch state {
        case .game:
            levelNode.update()
            
            switch levelNode.getState() {
            case .done:
                state = .transition
                previousLevel = currentLevel
                if let object = levels {
                    if currentLevel < object.count - 1 {
                        currentLevel += 1
                    } else {
                        needsMessage = true
                        messageMessage = NSLocalizedString("congratulations!\nnow play it all again", comment: "")
                        curtain.setMessageText(text: messageMessage)
                    }
                }
                loadLevel(shouldExpand: true)
            default:
                break
            }
        default:
            break
        }
    }
}

// MARK: Objective-C Methods
extension GameScene {
    @objc func doubleTapped(_ sender: UITapGestureRecognizer) {
        switch state {
        case .game:
            if levelNode.isPlaying() {
                levelNode.lostGame(playSound: false)
            }
        default: break
        }
    }
    
    @objc func singleTapped(_ sender: UITapGestureRecognizer) {
        
        switch state {
        case .game:
            if !levelNode.isPlaying() {
                topButtonsVisible = !topButtonsVisible
                
                if topButtonsVisible {
                    showTopButtons()
                }
                else {
                    hideTopButtons()
                }
            }
        default: break
        }
    }
}

// MARK: TopButtonsNode Delegate
extension GameScene : TopButtonsNodeDelegate {
    func handleHeader() {
        if self.header.position.y != self.screenSize.height {
            hideHeader()
            levelNode.unpause()
            state = .game
        } else {
            showHeader()
        }
    }
    
    func restartGame() {
        switch state {
        case .header:
            levelNode.lostGame(playSound: false)
            hideHeader()
            levelNode.unpause()
            state = .game
        case .game:
            topButtonsVisible = true
            topButtonsNode.removeAllActions()
            if levelNode.isPlaying() {
                levelNode.lostGame(playSound: false)
            }
        default: break
        }
    }
    
    func skipLevel() {
        topButtonsVisible = true
        topButtonsNode.removeAllActions()
        if skipAmount == 0 {
            gameDelegate?.promptForPurchase()
        }
        else {
            gameDelegate?.promptToSkip()
        }
    }
}

// MARK: Header Delegate
extension GameScene : HeaderDelegate {
    
    func moveTopButtons(extra dis: CGFloat, to pos: CGFloat, flip: Bool) {
        topButtonsNode.removeAllActions()
        
        let move1 = SKAction.moveTo(y: topButtonsNode.getOriginalY() - dis, duration: 0.45)
        move1.timingMode = SKActionTimingMode.easeOut
        let move2 = SKAction.moveTo(y: topButtonsNode.getOriginalY() - pos, duration: 0.2)
        move2.timingMode = SKActionTimingMode.easeIn
        let move = SKAction.sequence([move1, move2])
        topButtonsNode.run(move)
        
        if flip {
            topButtonsNode.flip(to: -1)
        }
    }
    
    func closeTopButtons(to pos: CGFloat, flip: Bool) {
        topButtonsNode.removeAllActions()
        
        let hide = SKAction.moveTo(y: topButtonsNode.getOriginalY() - pos, duration: 0.4)
        hide.timingMode = SKActionTimingMode.easeOut
        topButtonsNode.run(hide)
        
        if flip {
            topButtonsNode.flip(to: 1)
        }
    }
    
    func changeLevel(to levelNumber: Int) {
        switch state {
        case .header:
            previousLevel = currentLevel
            currentLevel = levelNumber
            loadLevel(shouldExpand: true)
        default: break
        }
    }
    
    func invertControls() {
        controlsInverted = !controlsInverted
    }
    
    func toggleSound() {
        soundToggle = !soundToggle
    }
    
    func toggleMusic() {
        musicToggle = !musicToggle
    }
    
    func changeRotateControl() {
        switch state {
        case .header:
            usesRotateBeam = !usesRotateBeam
            if currentLevel > 6 && levelNode.hasDynamicBeam() {
                needsRotateTutorial = true
                if usesRotateBeam {
                    curtain.setMessageText(text: NSLocalizedString("after shooting, rotate green beams\nwith control beam at the bottom", comment: ""))
                }
                else {
                    curtain.setMessageText(text: NSLocalizedString("after shooting, rotate green\nbeams by dragging finger", comment: ""))
                }
                loadLevel(shouldExpand: true)
            }
        default: break
        }
    }
    
    func changeDoubleTapSetting() {
        doubleTapToRestart = !doubleTapToRestart
    }
    
    func showScrollView() {
        scrollView.isHidden = false
    }
    
    func hideScrollView() {
        scrollView.isHidden = true
    }
}

// MARK: Curtain Delegate
extension GameScene : CurtainDelegate {
    func remove() {
        levelNode.removeFromParent()
        if header.position.y != screenSize.height {
            hideHeader()
        }
    }
    
    func load() {
        message.removeAllActions()
        message.isHidden = true
        changeLevel()
        
        let unlockedLevel = UserDefaults.standard.integer(forKey: ("unlocked"))
        if currentLevel > unlockedLevel {
            topButtonsNode.enableSkipButton()
            header.unlockLevel(currentLevel)
            UserDefaults.standard.set(currentLevel, forKey: "unlocked")
        } else if currentLevel == unlockedLevel {
            topButtonsNode.enableSkipButton()
        } else {
            topButtonsNode.disableSkipButton()
        }
    }
    
    func finished() {
        state = .game
        curtain.isHidden = true
    }
}

// MARK: LevelNode Delegate
extension GameScene : LevelNodeDelegate {
    func playHit() {
        if !soundToggle {return}
        if arc4random_uniform(2) == 0 {
            run(hit1)
        } else {
            run(hit2)
        }
    }
    
    func playWin() {
        if !soundToggle {return}
        run(win)
    }
    
    func playBad() {
        if !soundToggle {return}
        if arc4random_uniform(2) == 0 {
            run(bad1)
        } else {
            run(bad2)
        }
    }
    
    func playUnlock() {
        if !soundToggle {return}
        run(unlock)
    }
    
    func canTap() {
        singleTap.isEnabled = true
    }
    
    func cannotTap() {
        singleTap.isEnabled = false
    }
}

// MARK: Private Methods
extension GameScene {
    
    private func userDefaults() {
        if (UserDefaults.standard.object(forKey: "level") != nil) {
            currentLevel = UserDefaults.standard.integer(forKey: ("level"))
        } else {
            UserDefaults.standard.set(0, forKey: "level")
        }
        
        if (UserDefaults.standard.object(forKey: "skips") != nil) {
            skipAmount = UserDefaults.standard.integer(forKey: ("skips"))
        } else {
            UserDefaults.standard.set(0, forKey: "skips")
            skipAmount = 0
        }
        
        if (UserDefaults.standard.object(forKey: "controls") != nil) {
            controlsInverted = UserDefaults.standard.bool(forKey: ("controls"))
        } else {
            UserDefaults.standard.set(false, forKey: "controls")
        }
        
        if (UserDefaults.standard.object(forKey: "rotateControls") != nil) {
            usesRotateBeam = UserDefaults.standard.bool(forKey: ("rotateControls"))
        } else {
            UserDefaults.standard.set(false, forKey: "rotateControls")
        }
        
        if (UserDefaults.standard.object(forKey: "sound") != nil) {
            soundToggle = UserDefaults.standard.bool(forKey: ("sound"))
        } else {
            UserDefaults.standard.set(true, forKey: "sound")
        }
        
        if (UserDefaults.standard.object(forKey: "music") != nil) {
            musicToggle = UserDefaults.standard.bool(forKey: ("music"))
        } else {
            UserDefaults.standard.set(true, forKey: "music")
            musicToggle = true
        }
        
        if (UserDefaults.standard.object(forKey: "doubleTap") != nil) {
            doubleTapToRestart = UserDefaults.standard.bool(forKey: ("doubleTap"))
        } else {
            UserDefaults.standard.set(true, forKey: "doubleTap")
            doubleTapToRestart = true
        }
        
        if (UserDefaults.standard.object(forKey: "unlocked") != nil) {
            header.unlockLevels(UserDefaults.standard.integer(forKey: ("unlocked")))
        } else {
            UserDefaults.standard.set(0, forKey: "unlocked")
            header.unlockLevel(0)
        }
    }
    
    private func showTopButtons() {
        topButtonsNode.isHidden = false
        moveTopButtons(extra: headerHeight/11, to: 0, flip: false)
    }
    
    private func hideTopButtons() {
        topButtonsNode.removeAllActions()
        
        let move = SKAction.moveTo(y: Screen.height + headerHeight, duration: 0.4)
        move.timingMode = SKActionTimingMode.easeOut
        let hide = SKAction.run {
            self.topButtonsNode.isHidden = true
        }
        let action = SKAction.sequence([move, hide])
        topButtonsNode.run(action)
    }
    
    private func startRotateTutorial(usesBeam: Bool) {
        let moveAction : SKAction
        let moveDuration : TimeInterval
        let startPosition : CGPoint
        
        if usesBeam {
            let arcCenter = levelNode.getControlBeamPos().add(p: levelNode.position)
            moveDuration = 4
            fingerTouch.position = CGPoint(x: screenSize.width * 0.72, y: arcCenter.y)
            startPosition = fingerTouch.position
            let radius = fingerTouch.position.calcDistanceTo(p: arcCenter)
            let startAngle = fingerTouch.position.calcAngleTo(p: arcCenter)
            let endAngle = CGFloat.pi * 2 + startAngle
            let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            moveAction = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, duration: moveDuration)
        } else {
            moveDuration = 2.5
            fingerTouch.position = CGPoint(x: screenSize.width * 0.8, y: screenSize.height * 0.6)
            startPosition = fingerTouch.position
            let rotateStartPosition = CGPoint(x: screenSize.width * 0.8, y: screenSize.height * 0.35)
            let arcCenter = CGPoint(x: screenSize.width * 0.5, y: screenSize.height * 0.35)
            let radius = rotateStartPosition.calcDistanceTo(p: arcCenter)
            let startAngle = rotateStartPosition.calcAngleTo(p: arcCenter)
            let endAngle = -CGFloat.pi * 0.5 + startAngle
            let path = UIBezierPath()
            path.move(to: fingerTouch.position)
            path.addLine(to: rotateStartPosition)
            path.addArc(withCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            moveAction = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, duration: moveDuration)
        }
        
        moveAction.timingMode = SKActionTimingMode.easeInEaseOut
        
        let pause = SKAction.wait(forDuration: 0.3)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.5)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
        let reset = SKAction.move(to: startPosition, duration: 0)
        
        let animation = SKAction.repeatForever(SKAction.sequence([
            pause,
            fadeIn,
            pause,
            moveAction,
            pause,
            fadeOut,
            reset
            ]))
        
        fingerTouch.isHidden = false
        fingerTouch.run(animation)
    }
    
    private func stopRotateTutorial() {
        if fingerTouch.hasActions() {
            fingerTouch.removeAllActions()
            fingerTouch.run(.sequence([
                .fadeAlpha(to: 0, duration: 0.5),
                .run {self.fingerTouch.isHidden = true}]))
        }
    }
    
    private func showHeader() {
        singleTap.isEnabled = false
        
        topButtonsVisible = true
        topButtonsNode.removeAllActions()
        
        tint.removeAllActions()
        tint.isHidden = false
        
        let fade = SKAction.fadeAlpha(to: 0.15, duration: 0.2)
        tint.run(fade)
        
        header.removeAllActions()
        header.isHidden = false
        
        let show1 = SKAction.moveTo(y: screenSize.height - header.getExpandSize().height, duration: 0.45)
        show1.timingMode = SKActionTimingMode.easeOut
        let show2 = SKAction.moveTo(y: screenSize.height - header.getShowSize().height, duration: 0.2)
        show2.timingMode = SKActionTimingMode.easeIn
        let sequence = SKAction.sequence([show1, show2])
        header.run(sequence)
        
        moveTopButtons(extra: header.getExpandSize().height,
                       to: header.getShowSize().height, flip: true)
        
        state = .header
        
        levelNode.pause()
    }
    
    private func hideHeader() {
        tint.removeAllActions()
        
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.2)
        tint.run(fade)
        
        header.removeAllActions()
        header.hiding()
        
        let hide = SKAction.moveTo(y: screenSize.height, duration: 0.4)
        hide.timingMode = SKActionTimingMode.easeOut
        let finish = SKAction.run{self.header.isHidden = true; self.tint.isHidden = true}
        let sequence = SKAction.sequence([hide, finish])
        header.run(sequence)
        
        singleTap.isEnabled = true
        
        closeTopButtons(to: 0, flip: true)
    }
    
    private func loadLevel(shouldExpand: Bool) {
        state = .transition
        UserDefaults.standard.set(currentLevel, forKey: "level")
        stopRotateTutorial()
        
        if let object = levels {
            if let level = object[currentLevel] as? [String: Any] {
                if let mess = level["message"] as? String {
                    needsMessage = true
                    
                    if mess == "rotate tut" {
                        if usesRotateBeam {
                            messageMessage = NSLocalizedString("after shooting, rotate green beams\nwith control beam at the bottom", comment: "")
                        }
                        else {
                            messageMessage = NSLocalizedString("after shooting, rotate green\nbeams by dragging finger", comment: "")
                        }
                        needsRotateTutorial = true
                    }
                    else {
                        messageMessage = mess
                        needsRotateTutorial = false
                    }
                    curtain.setMessageText(text: messageMessage)
                }
            }
        }
        
        curtain.isHidden = false
        curtain.setLevelText(levelNumber: currentLevel)
        curtain.animate(shouldExpand: shouldExpand)
    }
    
    private func changeLevel() {
        if let object = levels {
            if let level = object[currentLevel] as? [String: Any] {
                levelNode = LevelNode(level: level, delegate: self, needsControlBeam: usesRotateBeam)
                levelNode.zPosition = 1
                levelNode.position = CGPoint(x: round(screenSize.width/2 - levelNode.getWidth()/2),
                                             y: round(screenSize.height/2 - levelNode.getHeight()/2))
                levelNode.invertControls(invert: controlsInverted)
                addChild(levelNode)
                
                header.unselectLevelButton(level: previousLevel + 1)
                header.selectLevelButton(level: currentLevel + 1)
                
                if needsRotateTutorial {
                    startRotateTutorial(usesBeam: usesRotateBeam)
                }
                if needsMessage {
                    message.setText(text: messageMessage)
                    message.isHidden = false
                    animateLabel(node: message)
                }
                
                needsRotateTutorial = false
                needsMessage = false
            }
        }
    }
    
    private func animateLabel(node: Message) {
        node.removeAllActions()
        let move1 = SKAction.moveTo(y: screenSize.height * 0.77, duration: 2)
        let move2 = SKAction.moveTo(y: screenSize.height * 0.74, duration: 2)
        move1.timingMode = SKActionTimingMode.easeInEaseOut
        move2.timingMode = SKActionTimingMode.easeInEaseOut
        node.run(.repeatForever(.sequence([move1, move2])))
    }
    
}
