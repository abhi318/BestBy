//
//  FoodDescController.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/4/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit

class FoodDescController: UIViewController {
    
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodDesc: UILabel!
    
    var passedValues: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodName.text = passedValues[0]
        foodDesc.text = passedValues[2]
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
