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
import GoogleMobileAds
import Siren
import SwiftyJSON
import RealmSwift
import Braintree
import AVFoundation
import ATAppUpdater
import AgoraRtcKit
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    private lazy var agoraKit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: kAgoraAppID, delegate: nil)
        engine.setLogFilter(AgoraLogFilter.info.rawValue)
        engine.setLogFile(FileCenter.logFilePath())
        return engine
    }()
    
    private var settings = Settings()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let config = Realm.Configuration(
            schemaVersion: 10,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1){
                    migration.enumerateObjects(ofType: UserModel.className()) { (oldObject, newObject) in
                        newObject?["userTrendStatus"] = "public"
                    }
                }
                if (oldSchemaVersion < 2){
                    migration.enumerateObjects(ofType: HomePostsModel.className()) { (oldObject, newObject) in
                        newObject?["isBoostPost"] = false
                        newObject?["postBoostLink"] = ""
                    }
                    migration.enumerateObjects(ofType: UserPostsModel.className()) { (oldObject, newObject) in
                        newObject?["postBoostLink"] = ""
                        newObject?["postStatus"] = "live"
                    }
                }
                if (oldSchemaVersion < 3){
                    migration.enumerateObjects(ofType: HomePostsModel.className()) { (oldObject, newObject) in
                        newObject?["isPostUserVerified"] = 0
                    }
                }
                if (oldSchemaVersion < 4){
                    migration.enumerateObjects(ofType: UserModel.className()) { (oldObject, newObject) in
                        newObject?["userSettingVersion"] = 0
                    }
                }
                if (oldSchemaVersion < 5){
                    migration.enumerateObjects(ofType: StoryUserModel.className()) { (oldObject, newObject) in
                        newObject?["isUserVerified"] = 0
                    }
                }
                if (oldSchemaVersion < 6){
                    migration.enumerateObjects(ofType: HomePostsModel.className()) { (oldObject, newObject) in
                        newObject?["postTags"] = ""
                    }
                    migration.enumerateObjects(ofType: UserPostsModel.className()) { (oldObject, newObject) in
                        newObject?["postTags"] = ""
                    }
                    migration.enumerateObjects(ofType: UserStoryModel.className()) { (oldObject, newObject) in
                        newObject?["storyTags"] = ""
                    }
                }
                if (oldSchemaVersion < 7){
                    migration.enumerateObjects(ofType: HomePostsModel.className()) { (oldObject, newObject) in
                        newObject?["postOriginalUserId"] = 0
                        newObject?["postOriginalUserFullName"] = ""
                    }
                    migration.enumerateObjects(ofType: UserPostsModel.className()) { (oldObject, newObject) in
                        newObject?["postOriginalUserId"] = 0
                        newObject?["postOriginalUserFullName"] = ""
                    }
                }
                if (oldSchemaVersion < 8){
                    migration.enumerateObjects(ofType: UserModel.className()) { (oldObject, newObject) in
                        newObject?["userBuck"] = 0
                    }
                    migration.enumerateObjects(ofType: HomePostsModel.className()) { (oldObject, newObject) in
                        newObject?["isPublicComment"] = 0
                    }
                    migration.enumerateObjects(ofType: UserPostsModel.className()) { (oldObject, newObject) in
                        newObject?["isPublicComment"] = 0
                    }
                }
                if (oldSchemaVersion < 9){
                    migration.enumerateObjects(ofType: NotificationModel.className()) { (oldObject, newObject) in
                        newObject?["notificationRequestId"] = ""
                    }
                    
                }
                if (oldSchemaVersion < 10){
                    migration.enumerateObjects(ofType: UserModel.className()) { (oldObject, newObject) in
                        newObject?["isAppointmentAllow"] = 1
                    }
                    
                }
                
            }
        )
        Realm.Configuration.defaultConfiguration = config
        
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        navigateTOInitialViewController()
        GMSPlacesClient.provideAPIKey(GoogleAPIKey)
        BTAppSwitch.setReturnURLScheme("com.mou.iFollow.payments")
        registerForPushNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        STPAPIClient.shared().publishableKey = "pk_live_51HhICdKaVNvNNNdfEU9JDliJmNCXk918U5gytm7z8QPIHYwFEP0zTnWsODgijFmrb1namrfkxBbBmTGX7aZgjCUN004dtt45Km"
        
        let notificationOption = launchOptions?[.remoteNotification]
        if notificationOption != nil{
            let notificationJSON = JSON(notificationOption as! [AnyHashable : Any])
            self.handlePushNotification(json: notificationJSON)
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        
//        let siren = Siren.shared
//        siren.rulesManager = RulesManager(globalRules: .critical, showAlertAfterCurrentVersionHasBeenReleasedForDays: 1)
//        siren.wail()
        ATAppUpdater.init().showUpdateWithForce()
        
        if (Utility.getLoginUserId() != 0){
            let usersRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
            usersRef.updateChildValues(["isActive" : true])
            
            API.sharedInstance.executeAPI(type: .resetAppBadge, method: .post, params: nil) { (status, result, message) in
                
            }
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
        
        let notificationJSON = JSON(response.notification.request.content.userInfo)
        self.handlePushNotification(json: notificationJSON)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func handlePushNotification(json: JSON){
        
        if (UserModel.getCurrentUser() != nil){
            if (json["tag"].intValue == 3 || json["tag"].intValue == 14){
                let vc = Utility.getPostDetailViewController()
                vc.postId = json["request_id"].intValue
                vc.showCommentsDirectly = json["tag"].intValue == 14
                vc.isFromPush = true
                UIWINDOW!.rootViewController = vc
            }
            else if (json["tag"].intValue == 7){
                let vc = Utility.getTabBarViewController()
                vc.selectedIndex = 4
                UIWINDOW!.rootViewController = vc
            }
            else if (json["tag"].intValue == 11){
                let vc = Utility.getChatContainerViewController()
                vc.isFromGroupChat = true
                vc.isFromPush = true
                let model = GroupChatModel()
                model.updateModelWithJSON(json: json["request_id"])
                vc.chatId = model.groupChatId
                vc.groupChatModel = model
                let navVC = UINavigationController(rootViewController: vc)
                navVC.isNavigationBarHidden = true
                UIWINDOW!.rootViewController = navVC
            }
            else if (json["tag"].intValue == 12){
                let vc = Utility.getChatContainerViewController()
                vc.isPrivateChat = false
                vc.isFromPush = true
                vc.chatId = json["request_id"]["chat_room_id"].stringValue
                vc.userId = json["request_id"]["user_id"].intValue
                vc.userName = json["request_id"]["user_name"].stringValue
                vc.chatUserImage = json["request_id"]["image"].stringValue.replacingOccurrences(of: "\\", with: "")
                UIWINDOW!.rootViewController = vc
            }
            else if (json["tag"].intValue == 13){
                let vc = Utility.getChatContainerViewController()
                vc.isPrivateChat = true
                vc.isFromPush = true
                vc.chatId = json["request_id"]["chat_room_id"].stringValue
                vc.userId = json["request_id"]["user_id"].intValue
                vc.userName = json["request_id"]["user_name"].stringValue
                vc.chatUserImage = json["request_id"]["image"].stringValue.replacingOccurrences(of: "\\", with: "")
                UIWINDOW!.rootViewController = vc
            }
            else if (json["tag"].intValue == 15 || json["tag"].intValue == 4){
                let vc = Utility.getTabBarViewController()
                vc.selectedIndex = 0
                vc.isFromPush = true
                vc.pushTitle = json["aps"]["alert"]["title"].stringValue
                vc.pushDesc = json["aps"]["alert"]["body"].stringValue
                UIWINDOW!.rootViewController = vc
            }
            else if (json["tag"].intValue == 16){
                self.joinLiveStream(roomID: "\(json["request_id"].intValue)")
            }
            else{
                let vc = Utility.getTabBarViewController()
                vc.selectedIndex = 4
                UIWINDOW!.rootViewController = vc
            }
        }
        
    }
    
    func joinLiveStream(roomID: String){
        self.settings.roomName = roomID
        self.settings.role = .audience
        self.settings.frameRate = .fps30
        self.settings.dimension = AgoraVideoDimension1280x720
        let vc = Utility.getLiveRoomController()
        vc.liveRoomName = "\(roomID)"
        vc.dataSource = self
        vc.isFromPush = true
        vc.modalPresentationStyle = .fullScreen
        UIWINDOW!.rootViewController = vc
    }
    
}

extension AppDelegate: LiveVCDataSource {
    func liveVCNeedSettings() -> Settings {
        return settings
    }
    
    func liveVCNeedAgoraKit() -> AgoraRtcEngineKit {
        return agoraKit
    }
}
