//
//  SampleViewController.swift
//  MultiWindowModalExample
//
//  Created by 長内幸太郎 on 2020/01/24.
//  Copyright © 2020 長内幸太郎. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController, WindowModalControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 20

        (self.navigationController as? WindowModalNavigationController)?.windowModalController?.delegate = self
    }
    
    @IBAction func closeButonTapped(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
        dismissWindowModal()
    }
    
    func windowModalController(windowModalController: WindowModalController, didMove windowFrame: CGRect) {
        print(windowFrame)
    }

}
