//
//  Coordinate.swift
//  ARRubiksNC2
//
//  Created by Bayu Alif Farisqi on 24/05/23.
//

import Foundation
import SceneKit

public enum Coordinate {
    
    case yRow(SCNNode, Float)
    case xCol(SCNNode, Float)
    case zCol(SCNNode, Float)
    
    func container() -> SCNNode {
        let container: SCNNode
        let filter: (SCNNode) -> Bool
        
        switch self {
        case .yRow(let parent, let y):
            container = parent
            filter = { $0.position.y.isClose(to: y) }
        case .xCol(let parent, let x):
            container = parent
            filter = { $0.position.x.isClose(to: x) }
        case .zCol(let parent, let z):
            container = parent
            filter = { $0.position.z.isClose(to: z) }
        }
        
        let parentContainer = SCNNode()
        for node in container.childNodes {
            if let geo = node.geometry, geo is SCNBox && filter(node) {
                parentContainer.addChildNode(node)
            }
        }
        
        return parentContainer
    }
}
