//
//  ViewController.swift
//  MultiWindowModalExample
//
//  Created by 長内幸太郎 on 2020/01/24.
//  Copyright © 2020 長内幸太郎. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let wc = WindowModalController()
    
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SampleViewController") as! SampleViewController
        wc.present(viewController: vc, sizeType: .small)
    }
    
    
    @IBAction func tappppped(_ sender: Any) {
//        wc.changeFrame(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: WindowModalController.WindowSize.max.size.height))
        wc.changeFrame(sizeType: .large)
    }
    
    
    @IBAction func taaaaaap(_ sender: Any) {
        let items = ["This app is my favorite"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    
}

