//
//  ShoppingListsViewController.swift
//  
//
//  Created by Erin Jensby on 2/27/18.
//

import UIKit

class ShoppingListsViewController: UIViewController {

    @IBOutlet weak var listTypeSegControl: UISegmentedControl!
    @IBOutlet weak var shopListsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shopListsTableView.delegate = self
        self.shopListsTableView.dataSource = self
        
        // Do any additional setup after loading the view.
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

extension ShoppingListsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopListID") as? ShoppingListCellTableViewCell
        
        let name = "Walmart Shopping List"
        cell?.listNameLabel.text = name
        return cell!
    }
    
    
    
}
