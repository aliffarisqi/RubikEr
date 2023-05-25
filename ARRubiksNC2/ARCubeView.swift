//
//  ARCubeView.swift
//  ARRubiksNC2
//
//  Created by Bayu Alif Farisqi on 24/05/23.
//

import ARKit
import RealityKit
import Foundation

class ARCubeView: ARSCNView, UIGestureRecognizerDelegate {
    
    var cube: ARCubeNode!
    var selectedContainer: SCNNode?
    var selectedSide: Side?
    
    var beginPoint:SCNVector3?
    var firstHitNode:SCNNode?
    var currentMoveDirection:MoveDirection?
    var oldMoveDirection:MoveDirection?
    var isSetupOpen: Bool = false
    
    var button: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //        setup()
        setupButton()
    }
    
    public override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        
        setup()
    }
    
    
    func setup() {
        func setupCube() {
            cube = ARCubeNode()
            cube.scale = SCNVector3(0.05, 0.05, 0.05)
            //            cube.position = SCNVector3(0,0,-0.5)
            
            scene.rootNode.addChildNode(cube)
        }
        func setupGestures() {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(swipe(_:)))
            pan.delegate = self
            addGestureRecognizer(pan)
        }
        
        setupCube()
        setupGestures()
    }
    
    func side(from: SCNHitTestResult?) -> Side? {
        guard let from = from else {
            return nil
        }
        
        let pos = from.worldCoordinates
        let top = SCNVector3(0, 5, 0).distance(to: pos)
        let bottom = SCNVector3(0, -5, 0).distance(to: pos)
        let left = SCNVector3(-5, 0, 0).distance(to: pos)
        let right = SCNVector3(5, 0, 0).distance(to: pos)
        let back = SCNVector3(0, 0, -5).distance(to: pos)
        let front = SCNVector3(0, 0, 5).distance(to: pos)
        
        let all = [top, bottom, left, right, back, front]
        
        if top.isSmallest(from: all) {
            return .top
        } else if bottom.isSmallest(from: all) {
            return .bottom
        } else if left.isSmallest(from: all) {
            return .left
        } else if right.isSmallest(from: all) {
            return .right
        } else if back.isSmallest(from: all) {
            return .back
        } else if front.isSmallest(from: all) {
            return .front
        }
        
        return nil
    }
    
    @objc func swipe(_ gestureRecognize: UIPanGestureRecognizer) {
        if cube.animating {
            return
        }
        
        let point = gestureRecognize.location(in: self)
        let hitResults = hitTest(point, options: [SCNHitTestOption.boundingBoxOnly:true])
        
        if gestureRecognize.state == .began {
            beginPoint = hitResults.first?.worldCoordinates
            firstHitNode = hitResults.first?.node
        } else if gestureRecognize.state == .changed || gestureRecognize.state == .ended {
            if let changedPoint = hitResults.first?.worldCoordinates {
                if let directionAndDistance = beginPoint?.direction(to: changedPoint){
                    currentMoveDirection = directionAndDistance.direction
                    cube.offset = CGFloat(directionAndDistance.distance)
                }
            }
        }
        if selectedSide == nil {
            selectedSide = side(from: hitResults.first)
            print("selected side:%@", selectedSide as Any)
            if selectedSide == nil {
                return
            }
        }
        //After determining the direction and contact surface, if the selectedContainer is empty, addChildNode is added only once
        if gestureRecognize.state == .changed && selectedContainer == nil && currentMoveDirection != nil && selectedSide != nil && firstHitNode != nil {
            oldMoveDirection = currentMoveDirection
            selectedContainer = self.getContainerWith(parentNode:cube,hitNode:firstHitNode!,direction:currentMoveDirection!,selectedSide:selectedSide!)
            cube.addChildNode(selectedContainer!)
        }
        //When the detected movement direction changes, the selectedContainer needs to be reset
        if let oldDirection = oldMoveDirection {
            if oldDirection != currentMoveDirection{
                selectedContainer?.rotation = SCNVector4()//Restore rotation direction
                for node in self.selectedContainer?.childNodes ?? [SCNNode]() {
                    self.cube.addChildNode(node)
                }
                self.selectedContainer?.removeFromParentNode()
                if currentMoveDirection != nil && selectedSide != nil && firstHitNode != nil {
                    oldMoveDirection = currentMoveDirection
                    selectedContainer = self.getContainerWith(parentNode: cube, hitNode: firstHitNode!, direction: currentMoveDirection!, selectedSide: selectedSide!)
                    cube.addChildNode(selectedContainer!)
                }
            }
        }
        //When the selectedContainer is not empty, modify the rotation angle in real time
        if (gestureRecognize.state == .changed || gestureRecognize.state == .ended) && selectedContainer != nil {
            let rotation: SCNVector4? = SCNVector4.init(direction: currentMoveDirection!, selectedSide: selectedSide!, degrees: Float(cube.offset).offsetSwitchToDegrees())
            selectedContainer?.rotation = rotation!
        }
        
        if gestureRecognize.state == .ended {
            print("cube node nubmer:",cube.childNodes.count)
            if let container = selectedContainer {
                cube.doRotation(container: container, direction: currentMoveDirection!, selectedSide: selectedSide!,finished: {
                    for node in self.selectedContainer?.childNodes ?? [SCNNode]() {
                        node.transform = self.selectedContainer!.convertTransform(node.transform, to: self.cube)
                        self.cube.addChildNode(node)
                    }
                    self.selectedContainer?.removeFromParentNode()
                    print("after rotation ,cube node number:",self.cube.childNodes.count)
                    self.selectedContainer = nil
                    self.currentMoveDirection = nil;
                    self.oldMoveDirection = nil
                    self.selectedSide = nil
                    self.cube.offset = 0;
                    self.cube.animating = false
                })
            }
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getContainerWith(parentNode:SCNNode,hitNode:SCNNode,direction:MoveDirection,selectedSide:Side) -> SCNNode? {
        var selectedContainer:SCNNode?
        if direction == .xAxis {
            if selectedSide == .top || selectedSide == .bottom {//Rotate around the z axis
                selectedContainer = Coordinate.zCol(parentNode, hitNode.position.z).container()
            } else {//Rotate around the y-axis
                selectedContainer = Coordinate.yRow(parentNode, hitNode.position.y).container()
            }
        } else if direction == .yAxis {
            if selectedSide == .front || selectedSide == .back { //rotate around the x-axis
                selectedContainer = Coordinate.xCol(parentNode, hitNode.position.x).container()
            } else {//Rotate around the z axis
                selectedContainer = Coordinate.zCol(parentNode, hitNode.position.z).container()
            }
        } else if direction == .zAxis {
            if selectedSide == .top || selectedSide == .bottom {//rotate around the x-axis
                selectedContainer = Coordinate.xCol(parentNode, hitNode.position.x).container()
            } else {//Rotate around the y-axis
                selectedContainer = Coordinate.yRow(parentNode, hitNode.position.y).container()
            }
        }
        return selectedContainer
    }
    func setupButton() {
        let imageRubikButton = UIImage(named: "rubikButton")
        
        button = UIButton(type: .custom)
        button.setBackgroundImage(imageRubikButton, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        
        
        
        addSubview(button)
        print(button.frame.size)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        let height = button.heightAnchor.constraint(equalToConstant: 75)
        let width = button.widthAnchor.constraint(equalToConstant: 75)
        NSLayoutConstraint.activate([
            height, width
        ])
    }
    @objc private func buttonTapped() {
        if isSetupOpen {
            // Close the setup
            isSetupOpen = false
            button.setBackgroundImage(UIImage(named: "rubikButton"), for: .normal)
            button.backgroundColor = nil
            button.setTitle("", for: .normal)            // Perform any additional actions to close the setup
            cube.removeFromParentNode()
        } else {
            // Open the setup
            isSetupOpen = true
            
            button.setTitle("CLEAR", for: .normal)
            button.setBackgroundImage(nil, for: .normal)
            button.backgroundColor = UIColor.rubRed
            setup()
        }
    }
}
