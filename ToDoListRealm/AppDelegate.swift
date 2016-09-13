//
//  AppDelegate.swift
//  ToDoListRealm
//
//  Created by Ajay Ghodadra on 13/09/16.
//  Copyright © 2016 Ajay Ghodadra. All rights reserved.
//

import UIKit
import KVNProgress
import RealmSwift

let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
let uiRealm = try! Realm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability: Reachability?
    var internetConnection: Bool!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //KVNProgress initializer
        KVNProgress.setConfiguration(self.kvnFullScreenConfig())
        
        //Reachability initializer
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            self.reachability = reachability
        } catch ReachabilityError.FailedToCreateWithAddress(let address) {
            print(address)
        } catch {}
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start\nnotifier")
        }
        
        // Initial reachability check
        if let reachability = reachability {
            if reachability.isReachable() {
                self.internetConnection = true
            } else {
                self.internetConnection = false
            }
        }
        
        return true
    }
    
    // MARK: - KVNProgressConfiguration
    
    func kvnFullScreenConfig() -> KVNProgressConfiguration{
        let configuration: KVNProgressConfiguration = KVNProgressConfiguration.defaultConfiguration()
        configuration.circleSize = 50
        return configuration
    }
    
    // MARK: - UIAlertController
    
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) {
            (action) in
            alertController .dismissViewControllerAnimated(true, completion:nil)
        }
        alertController.addAction(OKAction)
        
        self.window!.rootViewController!.presentViewController(alertController, animated: true) {
            
        }
    }
    
    //MARK: - Reachability
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            internetConnection = true
        } else {
            internetConnection = false
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

