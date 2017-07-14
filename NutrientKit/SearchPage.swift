//
//  SearchPage.swift
//  NutrientKit
//
//  Created by Blaine Fahey on 4/17/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

public struct SearchPage {
    /// The search items
    public let items: [SearchItem]
}

extension SearchPage: JSONDecodable {
    
    public init?(json: JSONDictionary) {
        let items = json["list"]?["item"] as? [JSONDictionary] ?? []
        
        self.items = items.flatMap { SearchItem(json: $0) }
    }
}
