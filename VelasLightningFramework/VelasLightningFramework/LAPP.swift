//
//  LAPP.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 1/30/23.
//
import Foundation

public enum LAPPError: Error {
    case JSONDecoder(msg:String)
    case Error(msg:String)
}


public struct GetInfoResponse: Codable {
    let alias: String
    let best_header_timestamp: UInt32
    let block_hash: String
    public let identity_pubkey: String
    let num_active_channels: Int32
    let num_inactive_channels: Int32
    let num_peers: Int32
    
    public struct URLS: Codable {
        enum CodingKeys: String, CodingKey {
            case localIP = "local"
            // Map the JSON key "url" to the Swift property name "htmlLink"
            case publicIP = "public"
        }
        public let localIP: String
        public let publicIP: String
        
    }
    public let urls: URLS
}

public struct OpenChannelResponse: Codable {
    public let txid: String
    public let vout: Int
}

public struct PayInvoicResponse: Codable {
    public let payment_error: String
    public let payment_hash: String
    public let payment_preimage: String
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
        let task = session.dataTask(with: urlRequest) { (_data, response, _error) in
            defer { sem.signal() }
            if let _error = _error {
                print(_error)
            }
            if let _data = _data {
                data = _data
            }
        }
        task.resume()
        sem.wait()

        
        let res = String(decoding: data!, as: UTF8.self)
        
        return res;
    }
    
    public func getinfo() throws -> GetInfoResponse? {
        let req = "\(self.baseUrl)/getinfo"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(self.jwt)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        var data:Data?
        var error: Error?

        let sem = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: urlRequest) { _data, response, _error in
            defer { sem.signal() }
            if let _error = _error {
                error = _error
            }
            if let _data = _data {
                data = _data
            }
        }
        task.resume()
        sem.wait()

        if let error = error {
            throw LAPPError.Error(msg: "\(error)")
        }
        
        var res:GetInfoResponse?
        if let data {
            do {
                res = try JSONDecoder().decode(GetInfoResponse.self, from: data)
            }
            catch {
                print(error)
                throw LAPPError.JSONDecoder(msg: "getinfo")
            }
        }
        
        return res;
    }
    
    public func openChannel(nodeId:String, amt:Int, target_conf:Int, min_confs:Int, privChan:Bool) -> OpenChannelResponse? {
        let req = "\(self.baseUrl)/openchannel"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.setValue("Bearer \(self.jwt)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.httpMethod = "POST"
        
        let parameters:[String:Any] = ["nodeId": nodeId, "amt": amt, "private": privChan ? 1 : 0, "target_conf":target_conf, "min_confs":min_confs ]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to data object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
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
        
        var res:OpenChannelResponse?
        do {
            res = try JSONDecoder().decode(OpenChannelResponse.self, from: data!)
        }
        catch {
            let res = String(decoding: data!, as: UTF8.self)
            print(res)
            return nil
        }
       
        return res
    }
    
    public func payInvoice(bolt11:String) -> PayInvoicResponse? {
        let req = "\(self.baseUrl)/payinvoice"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.setValue("Bearer \(self.jwt)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.httpMethod = "POST"
        
        let parameters:[String:Any] = ["bolt11": bolt11]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to data object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
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
        
        var res:PayInvoicResponse?
        if let data = data {
            do {
                res = try JSONDecoder().decode(PayInvoicResponse.self, from: data)
            }
            catch {
                let res = String(decoding: data, as: UTF8.self)
                print(res)
                return nil
            }
        }
       
        return res
    }
    
}
