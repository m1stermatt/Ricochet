//
//  Beam.swift
//  Ricochet
//
//  Created by Matthew Nam on 2017-12-08.
//  Copyright © 2017 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class Beam : SKSpriteNode {
    
    private var hypo : CGFloat!
    private var hAngle : CGFloat!
    
    public var canCollide : Bool = false
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        hypo = sqrt(pow(size.width/2, 2) + pow(size.height/2, 2))
        hAngle = atan((size.height/2)/(size.width/2))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Public methods
extension Beam {
    func getDiagonal() -> CGFloat {
        return hypo
    }
    
    func getHAngle() -> CGFloat {
        return hAngle
    }
}

