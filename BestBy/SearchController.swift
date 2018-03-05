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
        else if FoodData.food_data[foodBeingAdded.text!] != nil {
            let foodAdded: String = foodBeingAdded.text!
            let currentListID: String = ((self.presentingViewController as! MainViewController).viewControllers![0].childViewControllers[0] as! AllFoodViewController).currentListID!
            
            let dateOfExpiration = Calendar.current.date(byAdding: .day, value: (FoodData.food_data[foodAdded]?.0)!, to: Date())
            let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
            let doe = Int(timeInterval!)
            
            let post = ["name" : foodAdded,
                        "timestamp" : doe] as [String : Any]
            ref.child("AllFoodLists/\(currentListID)").childByAutoId().setValue(post)
        }
        
        else {
            let foodAdded: String = foodBeingAdded.text!
            let currentListID: String = (self.presentingViewController as! AllFoodViewController).currentListID!
            
            
            let post = ["name" : foodAdded, "timestamp" : -1] as [String : Any]
            ref.child("AllFoodLists/\(currentListID)").childByAutoId().setValue(post)
            let s:String = foodBeingAdded.text!
            userFoodRef.child(s).setValue(true)
        }
    }
    var userFoodRef: DatabaseReference!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredFood = [String]()
    var all_foods:[String] = []
    
    func addFood() {
        
    }
    
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
        navigationItem.searchController = searchController
        definesPresentationContext = true
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

extension SearchController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 31
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row) wks"
        }
        else {
            return "\(row) days"
        }
    }
    
}

extension SearchController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        
        let name_of_food = filteredFood[indexPath.row]
        let time_to_expire = FoodData.food_data[name_of_food]?.0
        foodBeingAdded.text = filteredFood[indexPath.row]
        
        weeksPicker.selectRow(time_to_expire!/7, inComponent: 0, animated: true)
        weeksPicker.selectRow(time_to_expire! % 7, inComponent: 1, animated: true)
    }
    
}

extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
