//
//  AddFoodToShopListViewController.swift
//  BestBy
//
//  Created by Erin Jensby on 3/30/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddFoodToShopListViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var AllFoodsTableView: UITableView!
    
    @IBAction func addFoodToShoppingList(_ sender: Any) {
        if nameLabel.text == "" {
            return
        } else {
            addFoodToUserShoppingList()
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)

    var currentListID: String = ""
    var userFoodRef: DatabaseReference!
    var ref: DatabaseReference!
    var filteredFood = [String]()
    var all_foods:[String] = []
    
    override
    func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        all_foods = Array(FoodData.food_data.keys)
        filteredFood = all_foods
        nameLabel.text = ""
        
        self.AllFoodsTableView.dataSource = self
        self.AllFoodsTableView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Foods"
        searchController.searchBar.delegate = self
        searchController.searchBar.returnKeyType = (UIReturnKeyType.done)
        
        navigationItem.searchController = searchController
        definesPresentationContext = true

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

    func addFoodToUserShoppingList() {
        let foodAdded: String = nameLabel.text!
        
        let listRef = ref.child("AllShoppingLists/\(currentListID)").childByAutoId()
        ref.child("AllShoppingLists/\(currentListID)/\(listRef.key)").setValue(foodAdded)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        let all_food_names = FoodData.food_data.keys
        filteredFood = all_food_names.filter({( food_name : String) -> Bool in
            return food_name.lowercased().contains(searchText.lowercased())
        })
        AllFoodsTableView.reloadData()
    }

}

extension AddFoodToShopListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredFood.count
        }
        return all_foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)
        
        let food_name:String
        if isFiltering() {
            food_name = filteredFood[indexPath.row]
        }
        else {
            food_name = all_foods[indexPath.row]
        }
        
        cell.textLabel!.text = food_name
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isFiltering() == false) {
            filteredFood = all_foods
        }
        nameLabel.text = filteredFood[indexPath.row]
    }
}

extension AddFoodToShopListViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1000
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
        }
        
        let titleData = "\(row)"

        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Futura-Medium", size:20.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        
        return pickerLabel!
    }
    
}

extension AddFoodToShopListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        nameLabel.text = searchController.searchBar.text!
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredFood = all_foods
        searchController.searchBar.resignFirstResponder()
    }
}

extension AddFoodToShopListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
