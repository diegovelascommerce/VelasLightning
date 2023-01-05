//
//  Requests.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 12/8/22.
//

import Foundation

public class Request {
    
    public static func get(url:String) -> Data? {
        var result: Data?
        let url = URL(string: url)
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        let headers = [
            "content-type": "application/json"
        ]
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"

        let session = URLSession.shared

        let sem = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: request) { data, reponse, error in
            defer { sem.signal() }

            if error != nil {
                result = nil
            } else {
                result = data ?? Data()
            }
        }

        task.resume()

        sem.wait()

        return result
    }
    
    public static func post(url:String, body:String) throws -> Data? {
        var result: Data? = nil
//        var error: NSError? = nil
        var error: VelasError? = nil
        let url = URL(string: url)
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        let headers = [
            "content-type": "text/plain"
        ]
        request.allHTTPHeaderFields = headers
        request.httpMethod = "POST"
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared

        let sem = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: request) { data, response, _error in
            defer { sem.signal() }
            
            if _error != nil {
                result = nil
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        result = data ?? Data()
                    }
                    else {
                        //error = NSError(domain: String(decoding: data!, as: UTF8.self), code: 1, userInfo: nil)
                        error = VelasError.txFailed(msg: String(decoding: data!, as: UTF8.self))
                    }
                }
            }
        }

        task.resume()

        sem.wait()
        
        if let error = error {
            throw error
        }
        
        return result
    }
    
    public static func getAsync(url:String) async throws -> Data? {
        var result: Data?
        let url = URL(string: url)
        let session = URLSession.shared
        
        let (data , _) = try await session.data(from:url!)
        result = data
        
        return result
    }
}
