//
//  AppDelegate.swift
//  VelasLightningExample
//
//  Created by Diego vila on 10/25/22.
//

import UIKit
import VelasLightningFramework

var velas: Velas!
var lapp:LAPP!
var velas_plist:[String:Any]!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        do {
            velas = try Velas(mnemonic: "arrive remember certain all consider apology celery melt uphold blame call blame")
        } catch {
            NSLog("\(error)")
            return false
        }
        
        let path = Bundle.main.path(forResource: "velas", ofType: "plist")
        
        let url = URL(fileURLWithPath: path!)
        
        let data = try! Data(contentsOf: url)
        
        velas_plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as! [String:Any]
        
        lapp = LAPP(baseUrl: "https://\(velas_plist["grpc_ip"] as! String)",
                    jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo");
        
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

