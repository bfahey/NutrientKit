//
//  FoodSearchViewController.swift
//  NutrientKitExample
//
//  Created by Blaine Fahey on 4/18/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

import UIKit
import NutrientKit

class FoodSearchViewController: UITableViewController, NutrientStoreContainer {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredItems = [SearchItem]()
    
    var nutrientStore: NutrientStore!
    
    let searchDelayInterval = 0.3
    
    var timer: Timer?
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        searchBar.scopeButtonTitles = ["Standard Reference", "Branded Food Products"]
        searchBar.showsScopeBar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar.resignFirstResponder()
        
        timer?.invalidate()
        timer = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FoodReport" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }

            let searchItem = filteredItems[indexPath.row]
            
            let foodReportViewController = segue.destination as! FoodReportViewController
            foodReportViewController.nutrientStore = nutrientStore
            foodReportViewController.searchItem = searchItem
        }
    }
    
    // MARK: Search
    
    func restartSearch() {
        // Invalidate the existing timer
        timer?.invalidate()
        
        // Create a timer to rate limit the number of searches being made
        timer = Timer.scheduledTimer(timeInterval: searchDelayInterval,
                                     target: self,
                                     selector: #selector(delayedSearch(_:)),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    func delayedSearch(_ sender: Any) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let isStandard = searchBar.selectedScopeButtonIndex == 0
        
        let ds: FoodDataSource = isStandard ? .standardReference : .brandedFoodProducts
        
        nutrientStore.search(withQuery: query, dataSource: ds) { [unowned self] (page, error) in
            if let page = page {
                self.filteredItems = page.items
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.tableView.reloadData()
                }
                
            } else if let error = error {
                print(error)
            }
        }

    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 88.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        
        let item = filteredItems[indexPath.row]
        
        cell.textLabel?.attributedText = item.attributedName(for: searchBar.text)
        
        return cell
    }
}

extension FoodSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        restartSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        restartSearch()
    }
}

extension SearchItem {
    
    func attributedName(for searchText: String?) -> NSAttributedString {
        guard let words = searchText?.components(separatedBy: " ") else {
            return NSAttributedString(string: name)
        }
        
        let attributed = NSMutableAttributedString(string: name)
        
        words.forEach { word in
            let range = (name as NSString).range(of: word,
                                                 options: [.caseInsensitive, .diacriticInsensitive])
            
            attributed.addAttribute(NSBackgroundColorAttributeName,
                                    value: UIColor(red: 255.0/255.0, green: 255/255.0, blue: 153.0/255.0, alpha: 1.0),
                                    range: range)
        }
        
        return attributed
    }
}
