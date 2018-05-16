//
//  Coder+Extensions.swift
//  Pagliacci
//
//  Created by George McCarroll on 5/14/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation

typealias JSONDict = [String: Any]

extension Decodable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

extension Encodable {
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
    
    func asDictionary() throws -> JSONDict {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                                options: .allowFragments) as? JSONDict else {
                                                                    throw NSError()
        }
        return dictionary
    }
    
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data,
                                                  options: .allowFragments)).flatMap { $0 as? JSONDict }
    }
}
