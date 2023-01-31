//
//  LAPP.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 1/30/23.
//

import Foundation

public struct GetInfoResponse: Codable {
    let alias: String
    let best_header_timestamp: UInt32
    let block_hash: String
    let identity_pubkey: String
    let num_active_channels: Int32
    let num_inactive_channels: Int32
    let num_peers: Int32
}

public class LAPP: NSObject, URLSessionDelegate {
    
    private var baseUrl:String
    
    private var jwt:String
    
    public init(baseUrl:String, jwt:String) {
        self.baseUrl = baseUrl
        self.jwt = jwt
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            if challenge.protectionSpace.serverTrust == nil {
                if challenge.protectionSpace.host == "192.168.0.10" {
                    completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
                }
                else {
                    completionHandler(.useCredential, nil)
                }
            } else {
                let trust: SecTrust = challenge.protectionSpace.serverTrust!
                let credential = URLCredential(trust: trust)
                completionHandler(.useCredential, credential)
            }
        }
    
    public func helloVelas() -> String? {
        let req = "\(self.baseUrl)/"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(self.jwt)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        var data:Data?
        let sem = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: urlRequest) { _data, response, error in
            defer { sem.signal() }
            if let error = error {
                print(error)
            }
            if let _data = _data {
                data = _data
                print(data!)
            }
        }
        task.resume()
        sem.wait()

        
        let res = String(decoding: data!, as: UTF8.self)
        print(res)
        
        return res;
    }
    
    public func getinfo() -> GetInfoResponse? {
        let req = "\(self.baseUrl)/getinfo"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(self.jwt)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        var data:Data?
        let sem = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: urlRequest) { _data, response, error in
            defer { sem.signal() }
            if let error = error {
                print(error)
            }
            if let _data = _data {
                data = _data
                print(data!)
            }
        }
        task.resume()
        sem.wait()

        
        var res:GetInfoResponse?
        do {
            res = try JSONDecoder().decode(GetInfoResponse.self, from: data!)
        }
        catch {
            print(error)
            return nil
        }
        
        return res;
    }
    
}
