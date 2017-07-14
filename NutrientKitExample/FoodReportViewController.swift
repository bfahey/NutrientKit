//
//  FoodReportViewController.swift
//  NutrientKitExample
//
//  Created by Blaine Fahey on 4/19/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

import UIKit
import NutrientKit

class FoodReportViewController: UITableViewController, NutrientStoreContainer {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var servingSizeField: UITextField!
    @IBOutlet weak var servingNumberField: UITextField!
    
    var nutrientStore: NutrientStore!
    
    var searchItem: SearchItem!
    
    var nutrientsByGroup = OrderedDictionary<String, [Nutrient]>()
    
    var numberOfServings: Double = 1.0
    
    var selectedMeasureIndex = 0
    
    var measureLabels = [String]() {
        didSet {
            guard let lastMeasure = measureLabels.last else { return }
            didSelect(measure: lastMeasure)
        }
    }
    
    var foodReport: FoodReport? {
        didSet {
            guard let report = foodReport, let nutrient = report.nutrients.first else { return }
            
            measureLabels = nutrient.measures.flatMap { $0.label }
            
            let rawGroups = report.nutrients.group(by:{ $0.group })
            
            let keys = ["Proximates", "Minerals", "Vitamins", "Lipids"]

            keys.forEach {
                guard let values = rawGroups[$0] else { return }
                nutrientsByGroup[$0] = values
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .interactive
        
        nameLabel.text = nil
        servingNumberField.text = "1"
        
        servingSizeField.textColor = view.tintColor
        servingNumberField.textColor = view.tintColor
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchReportWithLoadingIndicator), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        fetchReport()
    }
    
    func fetchReportWithLoadingIndicator() {
        tableView.refreshControl?.beginRefreshing()
        fetchReport()
    }
    
    func fetchReport() {        
        nutrientStore.basicReport(forNDBno: searchItem.ndbno) { [unowned self] (report, error) in
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                
                self.foodReport = report
                self.nameLabel.text = report?.name

                self.tableView.reloadData()
            }
        }
    }
    
    func getNutrient(at indexPath: IndexPath) -> Nutrient? {
        guard let nutrients = nutrientsByGroup[indexPath.section] else { return nil }
        return nutrients[indexPath.row]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return nutrientsByGroup.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let nutrients = nutrientsByGroup[section] else { return 0 }
        return nutrients.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nutrientsByGroup.keys[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NutrientCell", for: indexPath)
        
        if let nutrient = getNutrient(at: indexPath) {
            let measure = nutrient.measures[selectedMeasureIndex]
            
            cell.textLabel?.text = nutrient.name
            
            if let value = Double(measure.value) {
                cell.detailTextLabel?.text = "\(value * numberOfServings) \(nutrient.unit)"
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Actions

extension FoodReportViewController {
    
    func didSelect(measure: String) {
        if let index = measureLabels.index(of: measure) {
            selectedMeasureIndex = index
            
            DispatchQueue.main.async {
                self.servingSizeField.text = measure
                self.tableView.reloadData()
            }
        }
    }
    
    func showMeasures() {
        let actionSheet = UIAlertController(title: "Select Measure", message: nil, preferredStyle: .actionSheet)
        
        measureLabels.forEach { measure in
            actionSheet.addAction(UIAlertAction(title: measure, style: .default) { [unowned self] _ in
                self.didSelect(measure: measure)
            })
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
}

extension FoodReportViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == servingSizeField {
            showMeasures()
            return false
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resolvedString: NSString = (textField.text ?? "") as NSString
        let text = resolvedString.replacingCharacters(in: range, with: string)
        
        if let num = Double(text) {
            numberOfServings = num
            tableView.reloadData()
        }
        
        return true
    }
}
