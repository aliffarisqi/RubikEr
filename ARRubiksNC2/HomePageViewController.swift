//
//  HomePageViewController.swift
//  ARRubiksNC2
//
//  Created by Bayu Alif Farisqi on 24/05/23.
//

import UIKit

class HomePageViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var arPlayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func startButtonDidPressed(_ sender: Any) {
        let arViewController = ARView()
        navigationController?.pushViewController(arViewController, animated: true)
    }
    
    @IBAction func arPlayButtonDisPressed(_ sender: Any) {
        let arViewController = ARView()
        
        navigationController?.pushViewController(arViewController, animated: true)
    }

}
