//
//  GroupBy.swift
//  NutrientKitExample
//
//  Created by Blaine Fahey on 5/17/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

public extension Collection {
    
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var categories: [U: [Iterator.Element]] = [:]
        for element in self {
            let key = key(element)
            if case nil = categories[key]?.append(element) {
                categories[key] = [element]
            }
        }
        return categories
    }
}
