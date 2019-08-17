//
//  WallBeam.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-04-04.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class WallBeam : Beam {
    
    init(texture: SKTexture?, size: CGSize) {
        super.init(texture: texture, color: SKColor(red: 197.0/255, green: 196.0/255, blue: 193.0/255, alpha: 1), size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
