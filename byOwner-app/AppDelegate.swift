//
//  AppDelegate.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 23.09.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let APP_ID = "D3C28F9E-2D06-1058-FFEF-D886C9261E00"
    let API_KEY = "DA5FEAF3-BD9A-7C96-FFA3-43FFFA475400"
    let VERSION_NUM = "v1"
    
    var backendless = Backendless.sharedInstance()
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        backendless!.initApp(APP_ID, apiKey: API_KEY)
        
        //IAPServise.shared.getProducts()
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: kONESIGNALAPPID, handleNotificationReceived: nil, handleNotificationAction: nil, settings: nil)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
                    DispatchQueue.main.async {
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, userInfo: ["userId" : FUser.currentId()])
                    }
                }
            }
        }
        
        func onUserDidLogin(userId: String) {
            
            //startOneSignal()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, queue: nil) { (note) in
            
            let userId = note.userInfo!["userId"] as! String
            UserDefaults.standard.set(userId, forKey: "userId")
            UserDefaults.standard.synchronize()
            
            onUserDidLogin(userId: userId)
        }
        
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            
            center.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { (granted, error) in
                
            })
            application.registerForRemoteNotifications()
        }
        
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


}

