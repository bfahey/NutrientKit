//
//  NutrientsStore.swift
//  NutrientKit
//
//  Created by Blaine Fahey on 4/16/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

import Foundation

private struct Constants {
    static let baseURL = "https://api.nal.usda.gov/"
}

public enum FoodDataSource: String {
    case brandedFoodProducts = "Branded Food Products"
    case standardReference = "Standard Reference"
    case any = ""
}

public class NutrientStore {

    let apiKeyItem: URLQueryItem
    
    let networkClient: NetworkClient
    
    /// Initialize with your Data.gov API key
    public init(apiKey: String) {
        self.apiKeyItem = URLQueryItem(name: "api_key", value: apiKey)
        self.networkClient = NetworkClient(baseURL: URL(string: Constants.baseURL)!)
    }
    
    /**
     A search request sends keyword queries and returns lists of foods which contain one or more of
     the keywords in the food description, scientific name, or commerical name fields.
     
     More info: https://ndb.nal.usda.gov/ndb/doc/apilist/API-SEARCH.md
     
     - parameter query: The query to search
     - parameter pageSize: The max items per page
     - parameter pageOffset: The page offset
     - parameter completion: The completion handler which returns a search page
     */
    public func search(withQuery query: String,
                       dataSource: FoodDataSource = .brandedFoodProducts,
                       pageSize: Int = 50,
                       pageOffset: Int = 0,
                       completion: @escaping (SearchPage?, Error?) -> Void) {
        
        let items = [URLQueryItem(name: "q", value: query.encoded),
                     URLQueryItem(name: "ds", value: dataSource.rawValue),
                     URLQueryItem(name: "max", value: String(pageSize)),
                     URLQueryItem(name: "offset", value: String(pageOffset)),
                     apiKeyItem]
    
        networkClient.request(.get, "ndb/search", queryItems: items, completion: completion)
    }
    
    /**
     A food report is a list of nutrients and their values in various portions for a specific food.
     
     More info: https://ndb.nal.usda.gov/ndb/doc/apilist/API-FOOD-REPORTV2.md
     
     - parameter ndbno: The food NDB number
     - parameter completion: The completion handler which returns a food report
     */
    public func basicReport(forNDBno ndbno: String, completion: @escaping (FoodReport?, Error?) -> Void) {
        let items = [URLQueryItem(name: "ndbno", value: ndbno), apiKeyItem]
        
        networkClient.request(.get, "ndb/V2/reports", queryItems: items, completion: completion)
    }
    
}

extension String {
    var encoded: String? {
        let s = self.replacingOccurrences(of: " ", with: "+")
        return s.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
}
