//
//  homeViewController.swift
//  OCRtext
//
//  Created by 平良悠貴 on 2019/10/19.
//  Copyright © 2019 平良悠貴. All rights reserved.
//

import UIKit

class homeViewController: UIViewController {

    @IBOutlet var moneyButton:UIButton!
    @IBOutlet var postButton:UIButton!
    @IBOutlet var phoneButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moneyButton.layer.cornerRadius = 75
        postButton.layer.cornerRadius = 75
        phoneButton.layer.cornerRadius = 75

        // Do any additional setup after loading the view.
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

