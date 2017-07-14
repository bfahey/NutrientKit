//
//  OrderedDictionary.swift
//  NutrientKitExample
//
//  Created by Blaine Fahey on 7/14/17.
//  Copyright © 2017 Blaine Fahey. All rights reserved.
//

struct OrderedDictionary<K: Hashable, V> {
    var keys: Array<K> = []
    var values: Dictionary<K,V> = [:]
    
    var count: Int {
        assert(keys.count == values.count, "Keys and values array out of sync.")
        return self.keys.count;
    }
    
    subscript(index: Int) -> V? {
        get {
            let key = self.keys[index]
            return self.values[key]
        }
        set {
            let key = self.keys[index]
            if (newValue != nil) {
                self.values[key] = newValue
            } else {
                self.values.removeValue(forKey: key)
                self.keys.remove(at: index)
            }
        }
    }
    
    subscript(key: K) -> V? {
        get {
            return self.values[key]
        }
        set {
            if newValue == nil {
                self.values.removeValue(forKey: key)
                self.keys = self.keys.filter {$0 != key}
            } else {
                let oldValue = self.values.updateValue(newValue!, forKey: key)
                if oldValue == nil {
                    self.keys.append(key)
                }
            }
        }
    }
    
    var description: String {
        var result = "{\n"
        for i in 0..<self.count {
            result += "[\(i)]: \(self.keys[i]) => \(self[i]!)\n"
        }
        result += "}"
        return result
    }
}
