//
//  SearchController.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 2/27/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SearchController: UIViewController {
    
    @IBOutlet weak var searchResults: UITableView!
    @IBOutlet weak var foodBeingAdded: UILabel!
    @IBOutlet weak var weeksPicker: UIPickerView!
    var ref: DatabaseReference!
    
    @IBAction func cancelSearch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func AddToFoodsList(_ sender: Any) {
        if (foodBeingAdded.text == "") {
            return
        }
        else {
            addFoodToUsersList()
        }
        dismiss(animated: true, completion: nil)
    }
    
    var userFoodRef: DatabaseReference!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredFood = [String]()
    var all_foods:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        all_foods = Array(FoodData.food_data.keys)
        filteredFood = all_foods
        foodBeingAdded.text = ""
        
        self.weeksPicker.delegate = self
        self.weeksPicker.dataSource = self
        
        self.searchResults.delegate = self
        self.searchResults.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Foods"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func addFoodToUsersList() {
        let foodAdded: String = foodBeingAdded.text!
        
        let daysToExpire = weeksPicker.selectedRow(inComponent: 0)
        let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
        let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
        let doe = Int(timeInterval!)
        
        //post name of food, and seconds from reference date (jan 1, 2001) that it will expire
        let post = ["name" : foodAdded,
                    "timestamp" : doe] as [String : Any]
        
        let presenter = presentingViewController?.childViewControllers[0].childViewControllers[0] as! AllFoodViewController
        if presenter.currentListName == "All" {
            ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
        }
        else {
            ref.child("AllFoodLists/\(presenter.currentListID!)").childByAutoId().setValue(post)
            ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
        }
        self.dismiss(animated: true, completion: nil)
        
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
        
        searchResults.reloadData()
    }
    
}

extension SearchController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        foodBeingAdded.text = searchController.searchBar.text!
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredFood = all_foods
        searchController.searchBar.resignFirstResponder()
    }
}

extension SearchController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 90
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

extension SearchController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredFood.count
        }
        
        return all_foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let food_name:String
        if isFiltering() {
            food_name = filteredFood[indexPath.row]
        }
        else {
            food_name = all_foods[indexPath.row]
        }
        
        cell.textLabel!.text = food_name
        cell.detailTextLabel?.text = "\(FoodData.food_data[food_name]?.0 ?? 0) days"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (isFiltering() == false) {
            filteredFood = all_foods
        }
        let name_of_food = filteredFood[indexPath.row]
        let time_to_expire = FoodData.food_data[name_of_food]?.0
        foodBeingAdded.text = filteredFood[indexPath.row]
        
        weeksPicker.selectRow(time_to_expire!, inComponent: 0, animated: true)
    }
    
}

extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
