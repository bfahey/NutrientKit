//
//  AppDelegate.swift
//  NutrientKitExample
//
//  Created by Blaine Fahey on 7/14/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

import UIKit
import NutrientKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var nutrientStore: NutrientStore?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        /** 
         Register for a Data.gov API key at https://api.data.gov/signup/
         
         DEMO_KEY has a rate limit and is for example only.
         */
        nutrientStore = NutrientStore(apiKey: "DEMO_KEY")
        
        let navigationController = window?.rootViewController as! UINavigationController
        let searchViewController = navigationController.viewControllers.first as! FoodSearchViewController
        searchViewController.nutrientStore = nutrientStore
        
        return true
    }
}

