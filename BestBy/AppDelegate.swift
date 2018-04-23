//
//  AppDelegate.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 2/12/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        registerForPushNotifications()
        
        (window?.rootViewController as? UITabBarController)?.selectedIndex = 0
            
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func registerForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
        }
    }

}

func getNotificationForDay(on: Date, foodName: String) {
    let center = UNUserNotificationCenter.current()
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    center.getPendingNotificationRequests(completionHandler: { requests in
        for request in requests {
            print(request)
            let requestTriggerDate = request.identifier
            let newDate = dateFormatter.string(from: on)
            
            if newDate == requestTriggerDate {
                addRequest(calendar: calendar, request: request, center: center, foodName: foodName, date: on)
                return
            }
        }
        addRequest(calendar: calendar, request: nil, center: center, foodName: foodName, date: on)
        return
    })
}

func addRequest(calendar: Calendar, request: UNNotificationRequest?, center: UNUserNotificationCenter, foodName: String, date: Date) {
//
//    let content = UNMutableNotificationContent()
//    var trigger: UNCalendarNotificationTrigger?
//
//
//    content.title = "What to use today?"
//    content.body = "Eggs"
//
//    var triggerDate = DateComponents()
//
//
//    triggerDate.year = 2018
//    triggerDate.month = 4
//    triggerDate.day = 22
//    triggerDate.hour = 16
//    triggerDate.minute = 30
//    triggerDate.second = 0
//
//    trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
//                                            repeats: false)
//
//    let request = UNNotificationRequest(identifier: "who cares",
//                                       content: content, trigger: trigger)
//
//    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
//        if let error = error {
//            print(error.localizedDescription)
//        }
//    })
//    return
    
    let content = UNMutableNotificationContent()
    var identifier: String?
    var trigger: UNCalendarNotificationTrigger?
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"

    if request == nil {
        content.title = "What to use today?"
        content.body = "\(foodName)"

        var triggerDate = Calendar.current.dateComponents([.year,.month,.day], from: date)
        triggerDate.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        identifier = dateFormatter.string(from: triggerDate.date!)

        triggerDate.hour = 9
        triggerDate.minute = 0
        triggerDate.second = 0

        trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                repeats: false)
    }
    else {
        content.title = request!.content.title
        content.body = request!.content.body + ", \(foodName)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request!.identifier])
    }

    let request = UNNotificationRequest(identifier: (request != nil) ? request!.identifier : identifier!,
                                        content: content, trigger: (request != nil) ? request!.trigger : trigger!)

    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
        if let error = error {
            print(error.localizedDescription)
        }
    })
}

