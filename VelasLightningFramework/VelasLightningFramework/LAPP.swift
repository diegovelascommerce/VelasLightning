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

public struct LoginResponse: Codable {
    public let success: Bool
    public let token: String?
    public let message: String?
//    public let authId: UInt
//    public let authName: String
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

public struct GetNodeIdResponse: Codable {
    public let status: Bool
    public let message: String?
    public let node_id: String?
    public let public_url: String?
}

public struct OpenChannelResponse: Codable {
    public let txid: String
    public let vout: Int
}

public struct OpenChannelWorkitResponse: Codable {
    public let status: Bool
    public let message: String
    public let channel_id: String
    public let vout: Int
}

public struct PayInvoicResponse: Codable {
    public let payment_error: String
    public let payment_hash: String
    public let payment_preimage: String
}

public struct PayInvoicWorkitResponse: Codable {
    public let status: Bool
    public struct Message: Codable {
        public let payment_error: String
        public let payment_hash: String
        public let payment_preimage: String
    }
    public let message: Message
}

public struct ListChannelsResponse: Codable {
    public struct Channel: Codable {
        public let active: Bool
        public let remote_pubkey: String
        public let channel_point: String
        public let capacity: Int
        public let local_balance: Int
        public let remote_balance: Int
    }
    public let channels: [Channel]
}

public struct ListChannelsWorkitResponse: Codable {
    public let status: Bool
    public struct Message: Codable {
        public struct Channel: Codable {
            public let active: Bool
            public let remote_pubkey: String
            public let channel_point: String
            public let capacity: Int
            public let local_balance: Int
            public let remote_balance: Int
        }
        public let channels: [Channel]
    }
    public let message: Message
}

public class LAPP: NSObject, URLSessionDelegate {
    
    public static var shared:LAPP? = nil
    
    public static var Info:GetInfoResponse? = nil
    
    public static var NodeId:GetNodeIdResponse? = nil
    
    private var baseUrl:String?
    
    private var jwt:String?
    
    /// Login through workit backend
    ///
    /// params
    ///     url:  url to the backend we are login in to
    ///     username: username to login with
    ///     password: pasword to account
    public static func Login(url:String, username:String, password:String) throws {
        
        let lapp = LAPP(baseUrl: url);
        
        // login to workit backend
        let res = try lapp.login(username: username, password: password)
        
        // setup jwt token
        lapp.jwt = res?.token
        
        // save node information
        let nodeId = try lapp.getNodeId()
        NodeId = nodeId
        
        shared = lapp
    }
    

    /// Setup Velas throught plist
    public static func Setup(plist:String) throws {
        let plist = FileMgr.getPlist(plist)
        let url = plist["url"] as! String
        let jwt = plist["jwt"] as! String
        
        let lapp = LAPP(baseUrl: url, jwt: jwt);
//        lapp.jwt = jwt
        
        let info = try lapp.getinfo()
        LAPP.Info = info
        
        shared = lapp
    }
    
    /// Setup baseurl and jwt if passed in.
    public init(baseUrl:String, jwt:String? = nil) {
        self.baseUrl = baseUrl
        self.jwt = jwt
    }
    
    /// allow the request of https
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
    
    /// just for testing if node is up
    public func helloVelas() -> String? {
        let req = "\(self.baseUrl!)/"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(self.jwt!)", forHTTPHeaderField: "Authorization")
        
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
    
    /// Login into workit backend
    ///
    /// params
    ///     username: username to workit account
    ///     password: password to the workit account
    ///
    /// returns
    ///     LoginResponse
    public func login(username:String, password:String) throws -> LoginResponse? {
        let req = "\(self.baseUrl!)/auth/login"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        let parameters:[String:Any] = ["username": username, "password": password]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)

        } catch let error {
            print(error.localizedDescription)
        }
        
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
        
        var res:LoginResponse?
        if let data = data {
            do {                
                res = try JSONDecoder().decode(LoginResponse.self, from: data)
            }
            catch {
                print(error)
                throw LAPPError.JSONDecoder(msg: "Login")
            }
        }
        
        if res?.token != nil {
            return res
        }
        
        return nil;
    }
    
    /// Get node info from LAPP
    public func getinfo() throws -> GetInfoResponse? {
        let req = "\(self.baseUrl!)/getinfo"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(self.jwt!)", forHTTPHeaderField: "Authorization")
        
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
    
    /// Get node information through workit backend
    public func getNodeId() throws -> GetNodeIdResponse? {
        let req = "\(self.baseUrl!)/lapp/get_node_id"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(self.jwt!)", forHTTPHeaderField: "Authorization")
        
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
        
        var res:GetNodeIdResponse?
        if let data {
            do {
                res = try JSONDecoder().decode(GetNodeIdResponse.self, from: data)
            }
            catch {
                let res = String(decoding: data, as: UTF8.self)
                print(res)
                throw LAPPError.JSONDecoder(msg: "getinfo: \(error)")
            }
        }
        
        return res;
    }
    
    /// request to openchannel through LAPP
    public func openChannel(nodeId:String, amt:Int, target_conf:Int, min_confs:Int, privChan:Bool) -> OpenChannelResponse? {
        let req = "\(self.baseUrl!)/openchannel"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.setValue("Bearer \(self.jwt!)", forHTTPHeaderField: "Authorization")
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
    
    /// request to open a channel through workit
    public func openChannelWorkit(nodeId:String, amt:Int, userId:Int) -> OpenChannelWorkitResponse? {
        let req = "\(self.baseUrl!)/lapp/open_channel"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.setValue("Bearer \(self.jwt!)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.httpMethod = "POST"
        
        let parameters:[String:Any] = [ "node_id": nodeId, "user_id": userId, "amount": amt ]
        
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
        
        var res:OpenChannelWorkitResponse?
        do {
            res = try JSONDecoder().decode(OpenChannelWorkitResponse.self, from: data!)
        }
        catch {
            let res = String(decoding: data!, as: UTF8.self)
            print(res)
            return nil
        }
       
        return res
    }
    
    /// List channels from LAPP or workit
    public static func ListChannels(peer:String="",workIt:Bool=false) ->  [[String:Any]] {
        if let lapp = shared {
            do {
                if workIt {
                    let res = try lapp.listChannelsWorkit(peer:peer)
                    if let res = res {
                        let result = res.message.channels.map {[
                            "active":$0.active,
                            "remote_pubkey":$0.remote_pubkey,
                            "channel_point":$0.channel_point,
                            "capacity":$0.capacity,
                            "local_balance":$0.local_balance,
                            "remote_balance":$0.remote_balance,
                        ]}
                        return result
                    }
                }
                else {
                    let res = try lapp.listChannels(peer:peer)
                    if let res = res {
                        let result = res.channels.map {[
                            "active":$0.active,
                            "remote_pubkey":$0.remote_pubkey,
                            "channel_point":$0.channel_point,
                            "capacity":$0.capacity,
                            "local_balance":$0.local_balance,
                            "remote_balance":$0.remote_balance,
                        ]}
                        return result
                    }
                }
                
            }
            catch {
                NSLog("could not list channels")
            }
        }
        return []
    }
    
    
    /// List channels with workit
    public func listChannelsWorkit(peer:String="") throws -> ListChannelsWorkitResponse? {
        let req = "\(self.baseUrl!)/lapp/list_channels"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        urlRequest.setValue("Bearer \(self.jwt!)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.httpMethod = "POST"
        
        let parameters:[String:Any] = ["peer": peer]
        
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
        
        var res:ListChannelsWorkitResponse? = nil
        if let data {
            do {
                res = try JSONDecoder().decode(ListChannelsWorkitResponse.self, from: data)
            }
            catch {
                throw LAPPError.JSONDecoder(msg: "listchannels: \(error)")
            }
        }
        
        return res
    }
    
    /// return list of channel from LAPP
    public func listChannels(peer:String="", active_only:Int=0, inactive_only:Int=0, public_only:Int=0, private_only:Int=0) throws -> ListChannelsResponse? {
        let req = "\(self.baseUrl!)/listchannels"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        urlRequest.setValue("Bearer \(self.jwt!)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.httpMethod = "POST"
        
        let parameters:[String:Any] = ["peer": peer, "active_only": active_only, "inactive_only": inactive_only, "public_only":public_only, "private_only":private_only ]
        
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
        
        var res:ListChannelsResponse? = nil
        if let data {
            do {
                res = try JSONDecoder().decode(ListChannelsResponse.self, from: data)
            }
            catch {
                throw LAPPError.JSONDecoder(msg: "listchannels: \(error)")
            }
        }
        
        return res
    }
    
    /// Make a request to LAPP to pay a invoice.
    public static func PayInvoice(bolt11:String, workit:Bool=false, userId:Int?=nil) -> PayInvoicResponse? {
        if let lapp = shared {
            if let userId = userId, workit {
                let res = lapp.payInvoiceWorkit(bolt11: bolt11, userId: userId)
                if let res = res, res.status {
                    let message = res.message
                    let result:PayInvoicResponse = PayInvoicResponse(payment_error: message.payment_error, payment_hash: message.payment_hash, payment_preimage: message.payment_preimage)
                    
                    return result
                }
                return nil
            }
            else {
                let res = lapp.payInvoice(bolt11: bolt11)
                return res
            }
        }
        return nil
    }
    
    /// make request to pay invoice through LAPP
    public func payInvoice(bolt11:String) -> PayInvoicResponse? {
        let req = "\(self.baseUrl!)/payinvoice"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.setValue("Bearer \(self.jwt!)", forHTTPHeaderField: "Authorization")
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
    
    /// make a request to pay invoice through workit backend
    public func payInvoiceWorkit(bolt11:String, userId:Int) -> PayInvoicWorkitResponse? {
        let req = "\(self.baseUrl!)/lapp/pay_invoice"
        let url = URL(string: req)
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.setValue("Bearer \(self.jwt!)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.httpMethod = "POST"
        
        let parameters:[String:Any] = ["user_id": userId, "bolt11": bolt11]
        
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
        
        var res:PayInvoicWorkitResponse?
        if let data = data {
            do {
                res = try JSONDecoder().decode(PayInvoicWorkitResponse.self, from: data)
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
