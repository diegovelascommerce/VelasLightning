//
//  Requests.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 12/8/22.
//

import Foundation

class Request {
    
    static func get(url:String) -> Data? {
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
    
    static func getAsync(url:String) async throws -> Data? {
        var result: Data?
        let url = URL(string: url)
        let session = URLSession.shared
        
        let (data , _) = try await session.data(from:url!)
        result = data
        
        return result
    }
}
