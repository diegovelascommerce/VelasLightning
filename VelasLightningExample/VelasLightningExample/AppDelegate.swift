//
//  AppDelegate.swift
//  VelasLightningExample
//
//  Created by Diego vila on 10/25/22.
//

import UIKit
import VelasLightningFramework

var velas: Velas!
var velasNodeId: String!

var lapp:LAPP!
var LAPPIp:String!
var LAPPJwt:String!
var LAPPPort:NSNumber!
var LAPPNodeId:String!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
//    var velas: Velas!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let plist = getPlist()
        LAPPIp = plist["ip"] as? String
        LAPPJwt = plist["jwt"] as? String
        LAPPPort = plist["port"] as? NSNumber
        
        lapp = LAPP(baseUrl: "https://\(String(describing: LAPPIp!))",
                         jwt: LAPPJwt);
        
        do {
            let info = lapp.getinfo()
            if let info = info {
                LAPPNodeId = info.identity_pubkey
                velas = try Velas(mnemonic: "arrive remember certain all consider apology celery melt uphold blame call blame")
                velasNodeId = try velas.getNodeId()
                let res = try velas.connectToPeer(nodeId: LAPPNodeId, address: LAPPIp, port: LAPPPort)
                print("connect: \(res)")
            }
            else {
                NSLog("could not connect")
            }
        }
        catch {
            NSLog("there was a problem: \(error)")
        }
        
//        do {
//            velas = try Velas(mnemonic: "arrive remember certain all consider apology celery melt uphold blame call blame")
//        } catch {
//            NSLog("\(error)")
//            return false
//        }
        
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

func getPlist() -> NSDictionary {
    let path = Bundle.main.path(forResource: "Velas", ofType:"plist")!
    let dict = NSDictionary(contentsOfFile: path)

    return dict!
}

