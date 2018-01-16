//
//  FirebaseDataSnapshotMock.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/15/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import FirebaseCommunity

enum QueryOrder {
    
    case none
    case key
    case value
    case child(String)
    case priority
}

enum QueryLimit {
    
    case none
    case last(UInt)
    case first(UInt)
}

enum QueryRange {
    
    struct Limit {
        
        var value: Any?
        var childKey: String?
        
        init(_ value: Any?, _ childKey: String?) {
            self.value = value
            self.childKey = childKey
        }
    }
    
    struct Bound {
        
        var lower: Limit?
        var upper: Limit?
        
        init(_ lower: Limit?, _ upper: Limit?) {
            self.lower = lower
            self.upper = upper
        }
    }
    
    case none
    case equal(Limit)
    case bound(Bound)
}

class FirebaseDataSnapshotMock: DataSnapshot {
    
    private var aQueryRange: QueryRange = .none
    
    var mockKey: String = ""
    var mockValue: Any?
    var queryOrder: QueryOrder = .none
    var queryLimit: QueryLimit = .none
    var queryRange: QueryRange {
        set {
            switch newValue {
            case .bound(let newBound):
                switch aQueryRange {
                case .bound(let oldBound):
                    var bound = oldBound
                    if newBound.lower != nil {
                        bound.lower = newBound.lower
                    }
                    if newBound.upper != nil {
                        bound.upper = newBound.upper
                    }
                    aQueryRange = .bound(bound)
                    
                default:
                    aQueryRange = .bound(newBound)
                }
                
            default:
                aQueryRange = newValue
            }
        }
        get {
            return aQueryRange
        }
    }
    
    override var value: Any? {
        return mockValue
    }
    
    override var key: String {
        return mockKey
    }
    
    override func exists() -> Bool {
        return !mockKey.isEmpty
    }
    
    override var childrenCount: UInt {
        if let array = mockValue as? [Any] {
            return UInt(array.count)
        }
        
        if let dictionary = mockValue as? [String: Any] {
            return UInt(dictionary.count)
        }
        
        return 0
    }
    
    override func hasChildren() -> Bool {
        return childrenCount > 0
    }
    
    override func hasChild(_ childPathString: String) -> Bool {
        guard let dictionary = mockValue as? [String: Any] else {
            return false
        }
        
        return dictionary[childPathString] != nil
    }
    
    override var children: NSEnumerator {
        return Enumerator(mockValue: mockValue, queryOrder: queryOrder, queryRange: queryRange, queryLimit: queryLimit)
    }
    
    class Enumerator: NSEnumerator {
        
        var index: Int
        var mockValue: [(String, Any)]
        var queryOrder: QueryOrder
        var queryRange: QueryRange
        var queryLimit: QueryLimit
        
        init(mockValue: Any?, queryOrder: QueryOrder, queryRange: QueryRange, queryLimit: QueryLimit) {
            self.index = 0
            self.mockValue = []
            self.queryOrder = queryOrder
            self.queryRange = queryRange
            self.queryLimit = queryLimit
            
            guard let mock = mockValue as? [String: Any] else {
                return
            }
            
            switch queryOrder {
            case .none:
                self.mockValue = mock.flatMap({ ($0.key, $0.value) })
            
            case .key:
                self.mockValue = mock.sorted(by: { $0.key < $1.key })
                
            case .value:
                self.mockValue = mock.sorted(by: { item1, item2 -> Bool in
                    if let value1 = item1.value as? Int, let value2 = item2.value as? Int {
                        return value1 < value2
                    }
                    
                    if let value1 = item1.value as? Double, let value2 = item2.value as? Double {
                        return value1 < value2
                    }
                    
                    if let value1 = item1.value as? String, let value2 = item2.value as? String {
                        return value1 < value2
                    }
                    
                    return false
                })
            
            case .child(let childKey):
                self.mockValue = mock.sorted(by: { item1, item2 -> Bool in
                    let paths = childKey.split(separator: "/")
                    
                    if let item1Value = item1.value as? [String: Any], let item2Value = item2.value as? [String: Any] {
                        var value1: Any?
                        var value2: Any?
                        
                        for i in 0..<paths.count {
                            if value1 == nil {
                                value1 = item1Value[String(paths[i])]
                                
                            } else {
                                if let value = value1 as? [String: Any] {
                                    value1 = value[String(paths[i])]
                                }
                            }
                            
                            if value2 == nil {
                                value2 = item2Value[String(paths[i])]
                                
                            } else {
                                if let value = value2 as? [String: Any] {
                                    value2 = value[String(paths[i])]
                                }
                            }
                        }
                        
                        if let value1 = item1.value as? Int, let value2 = item2.value as? Int {
                            return value1 < value2
                        }
                        
                        if let value1 = item1.value as? Double, let value2 = item2.value as? Double {
                            return value1 < value2
                        }
                        
                        if let value1 = item1.value as? String, let value2 = item2.value as? String {
                            return value1 < value2
                        }
                    }
                    
                    return false
                })
                
            case .priority:
                break
            }
            
            switch queryLimit {
            case .none:
                break
                
            case .first(let limit):
                self.mockValue = Array(self.mockValue.dropFirst(Int(limit)))
                
            case .last(let limit):
                self.mockValue = Array(self.mockValue.dropLast(Int(limit)))
            }
            
            switch queryRange {
            case .none:
                break
            
            case .equal(let limit):
                if limit.childKey == nil {
                    self.mockValue = self.mockValue.filter({ item -> Bool in
                        if let itemValue = item.1 as? Int, let value = limit.value as? Int {
                            return itemValue == value
                        }
                        
                        if let itemValue = item.1 as? Double, let value = limit.value as? Double {
                            return itemValue == value
                        }
                        
                        if let itemValue = item.1 as? String, let value = limit.value as? String {
                            return itemValue == value
                        }
                        
                        return false
                    })
                    
                } else {
                    self.mockValue = self.mockValue.filter({ item -> Bool in
                        guard let itemValue = item.1 as? [String: Any] else {
                            return false
                        }
                        
                        let paths = limit.childKey!.split(separator: "/")
                        var childValue: Any?
                        for i in 0..<paths.count {
                            if childValue == nil {
                                childValue = itemValue[String(paths[i])]
                                
                            } else {
                                if let value = childValue as? [String: Any] {
                                    childValue = value[String(paths[i])]
                                }
                            }
                        }
                        
                        if let childValue = childValue as? Int, let value = limit.value as? Int {
                            return childValue == value
                        }
                        
                        if let childValue = childValue as? Double, let value = limit.value as? Double {
                            return childValue == value
                        }
                        
                        if let childValue = childValue as? String, let value = limit.value as? String {
                            return childValue == value
                        }
                        
                        return false
                    })
                }
                
            case .bound(let bound):
                if let start = bound.lower {
                    if start.childKey == nil {
                        let index = self.mockValue.index(where: { item -> Bool in
                            if let itemValue = item.1 as? Int, let value = start.value as? Int {
                                return itemValue == value
                            }

                            if let itemValue = item.1 as? Double, let value = start.value as? Double {
                                return itemValue == value
                            }

                            if let itemValue = item.1 as? String, let value = start.value as? String {
                                return itemValue == value
                            }

                            return false
                        })

                        if index != nil {
                            self.mockValue = Array(self.mockValue.suffix(index!))
                        }
                    
                    } else {
                        self.mockValue = self.mockValue.filter({ item -> Bool in
                            guard let itemValue = item.1 as? [String: Any] else {
                                return false
                            }
                            
                            let paths = start.childKey!.split(separator: "/")
                            var childValue: Any?
                            for i in 0..<paths.count {
                                if childValue == nil {
                                    childValue = itemValue[String(paths[i])]
                                    
                                } else {
                                    if let value = childValue as? [String: Any] {
                                        childValue = value[String(paths[i])]
                                    }
                                }
                            }
                            
                            return false
                        })
                    }
                }
                
                if let end = bound.upper {
                    if end.childKey == nil {
                        let index = self.mockValue.index(where: { item -> Bool in
                            if let itemValue = item.1 as? Int, let value = end.value as? Int {
                                return itemValue == value
                            }
                            
                            if let itemValue = item.1 as? Double, let value = end.value as? Double {
                                return itemValue == value
                            }
                            
                            if let itemValue = item.1 as? String, let value = end.value as? String {
                                return itemValue == value
                            }
                            
                            return false
                        })
                        
                        if index != nil {
                            self.mockValue = Array(self.mockValue.prefix(index!))
                        }
                    }
                }
            }
        }
        
        override func nextObject() -> Any? {
            guard !mockValue.isEmpty, index >= 0, index < mockValue.count else {
                return nil
            }
            
            let (snapshotKey, snapshotValue) = mockValue[index]
            let snapshot = FirebaseDataSnapshotMock()
            snapshot.mockKey = snapshotKey
            snapshot.mockValue = snapshotValue
            index += 1
            return snapshot
        }
    }
}
