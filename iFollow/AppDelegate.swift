//
//  AppDelegate.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 01/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import GooglePlaces
import UserNotificationsUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        navigateTOInitialViewController()
        GMSPlacesClient.provideAPIKey(GoogleAPIKey)
        registerForPushNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if (Utility.getLoginUserId() != 0){
            let usersRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
            usersRef.updateChildValues(["isActive" : false])
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if (Utility.getLoginUserId() != 0){
            let usersRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
            usersRef.updateChildValues(["isActive" : true])
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if (Utility.getLoginUserId() != 0){
            let usersRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
            usersRef.updateChildValues(["isActive" : true])
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if (Utility.getLoginUserId() != 0){
            let usersRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
            usersRef.updateChildValues(["isActive" : false,
                                        "isOnChat": false])
        }
    }
    
    func navigateTOInitialViewController() {
        if (UserModel.getCurrentUser() != nil){
            let vc = Utility.getTabBarViewController()
            UIWINDOW!.rootViewController = vc
        }
        else {
            let vc = Utility.getLoginNavigationController()
            UIWINDOW!.rootViewController = vc
        }
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        UserDefaults.standard.set(token as String, forKey: "DeviceToken")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
//        let notificationJSON = JSON(response.notification.request.content.userInfo)
//        if (notificationJSON["custom_data"]["node_id"].stringValue != ""){
//            navigateToChat(json: notificationJSON)
//        }
//        else{
//            navigateToNotifications()
//        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

}

