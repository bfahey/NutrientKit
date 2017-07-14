//
//  NutrientStoreContainer.swift
//  NutrientKitExample
//
//  Created by Blaine Fahey on 7/14/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

import NutrientKit

/// A protocol that formally defines an object that has a NutrientStore.
protocol NutrientStoreContainer {
    var nutrientStore: NutrientStore! { get set }
}
