//
//  SampleViewController.swift
//  MultiWindowModalExample
//
//  Created by 長内幸太郎 on 2020/01/24.
//  Copyright © 2020 長内幸太郎. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController, WindowModalViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 20

    }
    
    @IBAction func closeButonTapped(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
        dismissWindow()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
