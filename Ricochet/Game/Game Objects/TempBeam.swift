//
//  TempBeam.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-04-04.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class TempBeam : Beam {
    
    private var invisible = false
    
    private static var visibleColor = SKColor(red: 177.0/255, green: 220.0/255, blue: 234.0/255, alpha: 1)
    
    //private var fadeIn : SKAction = 
    
    init(texture: SKTexture?, size: CGSize) {
        super.init(texture: texture, color: TempBeam.visibleColor, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Public Methods
extension TempBeam {
    
    func hit() {
        if !invisible {
            invisible = true
        }
    }
    
    func reset() {
        
    }
    
}
