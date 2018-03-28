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
import UserNotifications

var infinity = "∞"

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
        
        var daysToExpire = weeksPicker.selectedRow(inComponent: 0)
        
        if FoodData.food_data[foodAdded] == nil {
            FoodData.food_data[foodAdded] = (((daysToExpire == 0) ? -2 : daysToExpire), "", UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal))
        }
        
        if FoodData.food_data[foodAdded]!.0 < 0 {
            daysToExpire = 10000
        }
        
        let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
        let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
        let doe = Int(timeInterval!)
        
        let presenter = presentingViewController?.childViewControllers[0].childViewControllers[0] as! AllFoodViewController

        //post name of food, and seconds from reference date (jan 1, 2001) that it will expire
        let post = ["name" : foodAdded,
                    "timestamp" : doe,
                    "spaceID": presenter.currentListID,
                    "spaceName" : presenter.currentListName] as [String : Any]
        ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
        
        getNotificationForDay(on: dateOfExpiration!, foodName: foodAdded)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func getNotificationForDay(on: Date, foodName: String) {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                
                let requestTriggerDate = (request.trigger as! UNCalendarNotificationTrigger).nextTriggerDate()
                
                let order = calendar.compare(requestTriggerDate!, to: on, toGranularity: .day)
                if order.rawValue == 0 {
                    self.addRequest(calendar: calendar, request: request, center: center, foodName: foodName, date: on)
                    return
                }
            }
            self.addRequest(calendar: calendar, request: nil, center: center, foodName: foodName, date: on)
            return
        })
    }
    
    func addRequest(calendar: Calendar, request: UNNotificationRequest?, center: UNUserNotificationCenter, foodName: String, date: Date) {
        let content = UNMutableNotificationContent()
        var identifier: String?
        var trigger: UNCalendarNotificationTrigger?
        
        if request == nil {
            content.title = "What's expiring today?"
            content.body = "\(foodName)"
            
            
            var triggerDate = Calendar.current.dateComponents([.year,.month,.day], from: date)
            identifier = "\(triggerDate.month)/\(triggerDate.day)/\(triggerDate.year)"

            triggerDate.hour = 9
            triggerDate.minute = 0
            triggerDate.second = 0
            
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                        repeats: false)
        }
        else {
            content.title = request!.content.title
            content.body = request!.content.body + ", \(foodName)"
        }
        let request = UNNotificationRequest(identifier: (request != nil) ? request!.identifier : identifier!,
                                            content: content, trigger: (request != nil) ? request!.trigger : trigger!)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
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
        return 1000
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
        }
        
        var titleData = "\(row)"
        if row == 0 {
            titleData = infinity
        }
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
        cell.detailTextLabel?.text = (FoodData.food_data[food_name]!.0 > 0) ? "\(FoodData.food_data[food_name]!.0 ) days" : "\(infinity) days"
        
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
