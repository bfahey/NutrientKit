//
//  Nutrient.swift
//  NutrientKit
//
//  Created by Blaine Fahey on 4/16/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

public struct Nutrient {
    /// Nutrient number (nutrient_no) for the nutrient
    public let id: String
    /// Nutrient name
    public let name: String
    /// Group for this nutrient
    public let group: String
    /// Unit of measure for this nutrient
    public let unit: String
    /// 100g equivalent value of the nutrient
    public let value: String
    /// List of measures reported for a nutrient
    public let measures: [Measure]
}

extension Nutrient: JSONDecodable {
    
    public init?(json: JSONDictionary) {
        guard let id = json["nutrient_id"] as? String,
            let name = json["name"] as? String,
            let group = json["group"] as? String,
            let unit = json["unit"] as? String,
            let value = json["value"] as? String,
            let measures = json["measures"] as? [JSONDictionary] else {
                return nil
        }
        
        self.id = id
        self.name = name
        self.group = group
        self.unit = unit
        self.value = value
        self.measures = measures.flatMap { Measure(json: $0) }
    }
}
