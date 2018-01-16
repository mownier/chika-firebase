//
//  FirebaseDatabaseMock.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/15/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import FirebaseCommunity

class FirebaseDatabaseMock: Database {

    var mockDatabaseReference: FirebaseDatabaseReferenceMock
    
    init(reference: FirebaseDatabaseReferenceMock = FirebaseDatabaseReferenceMock()) {
        self.mockDatabaseReference = reference
    }
    
    override func reference() -> DatabaseReference {
        return mockDatabaseReference
    }
}
