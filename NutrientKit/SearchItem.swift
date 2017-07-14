//
//  SearchItem.swift
//  NutrientKit
//
//  Created by Blaine Fahey on 4/16/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

public struct SearchItem {
    /// The food NDB number
    public let ndbno: String
    /// The food name
    public let name: String
    /// The food group
    public let group: String
    /// The data source. BL (Branded Food Products) or SR (Standard Reference).
    public let ds: String
}

extension SearchItem: JSONDecodable {
    
    public init?(json: JSONDictionary) {
        guard let ndbno = json["ndbno"] as? String,
            let name = json["name"] as? String,
            let group = json["group"] as? String,
            let ds = json["ds"] as? String else {
                return nil
        }
        
        self.ndbno = ndbno
        self.name = name
        self.group = group
        self.ds = ds
    }
}



extension SearchItem: Hashable {
    
    public var hashValue: Int {
        return ndbno.hashValue ^ name.hashValue ^ group.hashValue ^ ds.hashValue
    }
    
    public static func ==(lhs: SearchItem, rhs: SearchItem) -> Bool {
        let areEqual = lhs.ndbno == rhs.ndbno &&
            lhs.name == rhs.name &&
            lhs.group == rhs.group &&
            lhs.ds == rhs.ds
        
        return areEqual
    }
}
