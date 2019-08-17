//
//  ObstacleBeam.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-04-04.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class ObstacleBeam : Beam {
    init(texture: SKTexture?, size: CGSize) {
        super.init(texture: texture, color: SKColor(red: 229.0/255, green: 150.0/255, blue: 156.0/255, alpha: 1), size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
