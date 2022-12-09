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
    
    public static func post(url:String, data:Data) -> Data? {
        var result: Data?
        let url = URL(string: url)
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        let headers = [
            "content-type": "application/json"
        ]
        request.allHTTPHeaderFields = headers
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = ["data": String(decoding: data, as: UTF8.self)]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
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
    
    public static func getAsync(url:String) async throws -> Data? {
        var result: Data?
        let url = URL(string: url)
        let session = URLSession.shared
        
        let (data , _) = try await session.data(from:url!)
        result = data
        
        return result
    }
}
