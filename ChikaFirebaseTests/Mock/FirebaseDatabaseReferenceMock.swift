//
//  FirebaseDatabaseReferenceMock.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/15/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import Foundation
import FirebaseCommunity

class FirebaseDatabaseReferenceMock: DatabaseReference {
    
    var store: [String: Any]
    var mockSnapshot: FirebaseDataSnapshotMock
    
    init(mockSnapshot: FirebaseDataSnapshotMock = FirebaseDataSnapshotMock()) {
        self.store = [:]
        self.mockSnapshot = mockSnapshot
        
        let bundle = Bundle(identifier: "com.nir.ChikaFirebaseTests")!
        
        if let path = bundle.path(forResource: "TestData", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String: Any] {
                    self.store = jsonResult
                }
            } catch {
                // handle error
            }
        }
    }
    
    override func observe(_ eventType: DataEventType, with block: @escaping (DataSnapshot) -> Void) -> UInt {
        block(mockSnapshot)
        return 1
    }
    
    override func observeSingleEvent(of eventType: DataEventType, with block: @escaping (DataSnapshot) -> Void) {
        block(mockSnapshot)
    }
    
    override func child(_ pathString: String) -> DatabaseReference {
        let paths = pathString.split(separator: "/")
        
        var mockValue: Any?
        for i in 0..<paths.count {
            if mockValue == nil {
                mockValue = store[String(paths[i])]
            
            } else {
                if let dictionary = mockValue as? [String: Any] {
                    mockValue = dictionary[String(paths[i])]
                }
            }
            
            if i == paths.count - 1 {
                mockSnapshot.mockKey = String(paths[i])
                mockSnapshot.mockValue = mockValue
            }
        }
        
        return self
    }
    
    override func childByAutoId() -> DatabaseReference {
        return self
    }
    
    override func queryOrderedByKey() -> DatabaseQuery {
        mockSnapshot.queryOrder = .key
        return self
    }
    
    override func queryOrderedByPriority() -> DatabaseQuery {
        mockSnapshot.queryOrder = .priority
        return self
    }
    
    override func queryOrderedByValue() -> DatabaseQuery {
        mockSnapshot.queryOrder = .value
        return self
    }
    
    override func queryOrdered(byChild key: String) -> DatabaseQuery {
        mockSnapshot.queryOrder = .child(key)
        return self
    }
    
    override func queryLimited(toLast limit: UInt) -> DatabaseQuery {
        mockSnapshot.queryLimit = .last(limit)
        return self
    }
    
    override func queryLimited(toFirst limit: UInt) -> DatabaseQuery {
        mockSnapshot.queryLimit = .first(limit)
        return self
    }
    
    override func queryEqual(toValue value: Any?) -> DatabaseQuery {
        mockSnapshot.queryRange = .equal(QueryRange.Limit(value, nil))
        return self
    }
    
    override func queryEnding(atValue endValue: Any?) -> DatabaseQuery {
        mockSnapshot.queryRange = .bound(QueryRange.Bound(nil, QueryRange.Limit(endValue, nil)))
        return self
    }
    
    override func queryStarting(atValue startValue: Any?) -> DatabaseQuery {
        mockSnapshot.queryRange = .bound(QueryRange.Bound(QueryRange.Limit(startValue, nil), nil))
        return self
    }
    
    override func queryEqual(toValue value: Any?, childKey: String?) -> DatabaseQuery {
        mockSnapshot.queryRange = .equal(QueryRange.Limit(value, nil))
        return self
    }
    
    override func queryEnding(atValue endValue: Any?, childKey: String?) -> DatabaseQuery {
        mockSnapshot.queryRange = .bound(QueryRange.Bound(nil, QueryRange.Limit(endValue, childKey)))
        return self
    }
    
    override func queryStarting(atValue startValue: Any?, childKey: String?) -> DatabaseQuery {
        mockSnapshot.queryRange = .bound(QueryRange.Bound(QueryRange.Limit(startValue, childKey), nil))
        return self
    }

}
