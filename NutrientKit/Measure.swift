//
//  Measure.swift
//  NutrientKit
//
//  Created by Blaine Fahey on 4/16/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

public struct Measure {
    /// Name of the measure
    public let label: String
    /// Equivalent of the measure expressed as an eunit
    public let eqv: Double
    /// Unit in with the equivalent amount is expressed. Usually either gram (g) or milliliter (ml)
    public let eunit: String
    /// Quantity of the measure
    public let qty: Double
    /// Gram equivalent value of the measure
    public let value: String
}

extension Measure: JSONDecodable {
    
    public init?(json: JSONDictionary) {
        guard let label = json["label"] as? String,
            let eqv = json["eqv"] as? Double,
            let eunit = json["eunit"] as? String,
            let qty = json["qty"] as? Double,
            let value = json["value"] as? String else {
                return nil
        }
        
        self.label = label
        self.eqv = eqv
        self.eunit = eunit
        self.qty = qty
        self.value = value
    }
}
