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
        
        let plist = FileMgr.getPlist("velas")
        LAPPIp = plist["ip"] as? String
        LAPPJwt = plist["jwt"] as? String
        LAPPPort = plist["port"] as? NSNumber
        
        lapp = LAPP(baseUrl: "https://\(String(describing: LAPPIp!))",
                         jwt: LAPPJwt);
        
        do {
            let info = lapp.getinfo()
            if let info = info {
                if FileMgr.fileExists(path: "mnemonic") {
                    let mnemonic = try FileMgr.readString(path: "mnemonic")
                    print("mnemonic: \(mnemonic)")
                    velas = try Velas(mnemonic: mnemonic)
                }
                else {
                    velas = try Velas()
                    let mnemonic = velas.getMnemonic()
                    print("mnemonic: \(mnemonic)")
                    try FileMgr.writeString(string: mnemonic, path: "mnemonic")
                }
                
                LAPPNodeId = info.identity_pubkey
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


