//
//  FoodReport.swift
//  NutrientKit
//
//  Created by Blaine Fahey on 4/17/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

public struct FoodReport {
    /// The food name
    public let name: String
    /// The food ingredients
    public let ingredients: String?
    /// The food nutrients
    public let nutrients: [Nutrient]
}

extension FoodReport: JSONDecodable {
    
    public init?(json: JSONDictionary) {
        guard let foods = json["foods"] as? [JSONDictionary],
            let food = foods.first?["food"] as? JSONDictionary,
            let name = food["desc"]?["name"] as? String else {
                return nil
        }
        
        let ingredients = food["ing"]?["desc"] as? String
        let nutrients = food["nutrients"] as? [JSONDictionary] ?? []
        
        self.name = name
        self.ingredients = ingredients
        self.nutrients = nutrients.flatMap { Nutrient(json: $0) }
    }
}
