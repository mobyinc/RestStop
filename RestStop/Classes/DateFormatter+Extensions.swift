//
//  DateFormatter+Extensions.swift
//  Pagliacci
//
//  Created by George McCarroll on 5/14/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation

public extension DateFormatter {

    public static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return formatter
    }()
}
