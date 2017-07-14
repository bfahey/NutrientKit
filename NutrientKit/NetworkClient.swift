//
//  NetworkClient.swift
//  NutrientKit
//
//  Created by Blaine Fahey on 4/17/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String: AnyObject]

public protocol JSONDecodable {
    init?(json: JSONDictionary)
}

/// Abstract networking client
public class NetworkClient {

    public enum NetworkError: Error {
        case missingData
        case invalidData
        case invalidJSON
    }
    
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        
        var acceptsBody: Bool {
            if self == .post || self == .put {
                return true
            }
            return false
        }
    }
    
    public let baseURL: URL
    
    public let session: URLSession
    
    public init(baseURL: URL, session: URLSession = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    public func buildRequest(_ method: Method = .get, _ path: String, queryItems: [URLQueryItem] = [], parameters: JSONDictionary? = nil) -> URLRequest {
        var url = baseURL.appendingPathComponent(path)
        
        // Apply query items
        if !queryItems.isEmpty, var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            components.queryItems = queryItems
            
            if let modified = components.url {
                url = modified
            }
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Add defaults
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add body
        if let parameters = parameters, method.acceptsBody,
            let body = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
            request.httpBody = body
        }
        
        return request
    }
    
    /// Raw network result
    public func request(_ method: Method = .get, _ path: String, queryItems: [URLQueryItem] = [], parameters: JSONDictionary? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = buildRequest(method, path, queryItems: queryItems, parameters: parameters)
        
        // Send request
        session.dataTask(with: request, completionHandler: completion).resume()
    }
    
    /// Single JSON object
    public func request<T: JSONDecodable>(_ method: Method = .get, _ path: String, queryItems: [URLQueryItem] = [], parameters: JSONDictionary? = nil, completion: @escaping (T?, Error?) -> Void) {
        request(method, path, queryItems: queryItems, parameters: parameters) { (data, response, error) in
            // Check data
            guard let data = data else {
                completion(nil, NetworkError.missingData)
                return
            }
            
            // Parse JSON
            guard let raw = try? JSONSerialization.jsonObject(with: data, options: []) else {
                completion(nil, NetworkError.invalidData)
                return
            }
            
            // Check JSON
            guard let json = raw as? JSONDictionary else {
                completion(nil, NetworkError.invalidJSON)
                return
            }
            
            // Deserialize object
            if let object = T(json: json) {
                completion(object, error)
            } else {
                completion(nil, error)
            }
        }
    }
}
