//
//  AppDelegate.swift
//  VelasLightningExample
//
//  Created by Diego vila on 10/25/22.
//

import UIKit
import VelasLightningFramework

var velas: Velas!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
//    var velas: Velas!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        do {
            velas = try Velas(mnemonic: "arrive remember certain all consider apology celery melt uphold blame call blame",
                              getChannels: {
                                let data = Request.get(url:"https://www.workit/channel_backup")
                                return [data!]
                              },
                              backUpChannel: { data in
                                _ = Request.post(url: "https://www.workit.com/channel_backup", data:data )
                                print("please backup channel to workit server: \(data)")
                              },
                              getChannelManager: {
                                let data = Request.get(url:"https://www.workit/hannel_manager_backup")
                                return data!
                              },
                              backUpChannelManager: { data in
                                _ = Request.post(url: "https://www.workit.com/channel_manager_backup", data:data )
                                print("please backup channel manager to workit server: \(data)")
                              });

            
        } catch {
            NSLog("\(error)")
            return false
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

