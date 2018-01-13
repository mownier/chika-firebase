//
//  InboxQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore

public class InboxQuery: ChikaCore.InboxQuery {

    public func getInbox(withCompletion completion: @escaping (Result<[Chat]>) -> Void) -> Bool {
        return true
    }
}
