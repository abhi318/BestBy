//
//  NotificationPreferencesTableViewController.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 4/25/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit

class NotificationPreferencesTableViewController: UITableViewController {

    @IBOutlet var timeToNotify: UILabel!
    
    var timePickerSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let time = String(currentUser.shared.notifTime!).flatMap{Int(String($0))}
        var minutes = ""
        var hour = ""
        var amORpm:Bool = false
        if time.count == 4 {
            hour = "\(time[0])\(time[1])"
            minutes = "\(time[2])\(time[3])"
            if time[1] > 1 {
                amORpm = true
            }
        } else {
            hour = "\(time[0])"
            minutes = "\(time[1])\(time[2])"
        }
        
        timeToNotify.text = "\(hour):\(minutes) \(amORpm ? "PM":"AM")"
        
        self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else {
            timePickerSelected = true
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        else {
            timePickerSelected = false
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && timePickerSelected {
            return 200
        }
        return 45
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
