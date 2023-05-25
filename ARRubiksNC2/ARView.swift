//
//  ViewController.swift
//  ARRubiksNC2
//
//  Created by Bayu Alif Farisqi on 24/05/23.
//

import UIKit
import SceneKit
import ARKit

class ARView: UIViewController, ARSCNViewDelegate {

    
    @IBOutlet weak var sceneView: ARCubeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cubeView = ARCubeView(frame: view.bounds)

        sceneView = cubeView
        sceneView.delegate = self

        view.addSubview(sceneView)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
