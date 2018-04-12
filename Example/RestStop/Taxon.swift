//
//  Taxon.swift
//  RestStop_Example
//
//  Created by James Jacoby on 4/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct Taxon : Codable {
    var id: Int
    var name: String
    var observations_count: Int
    var default_photo: Photo
}

struct Photo : Codable {
    var id: Int
    var square_url: String
    var attribution: String
}
