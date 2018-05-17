//
//  Coder+Extensions.swift
//  Pagliacci
//
//  Created by George McCarroll on 5/14/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation

public typealias JSONDict = [String: Any]

public extension Decodable {
    public static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

public extension Encodable {
    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
    
    public func asDictionary() throws -> JSONDict {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                                options: .allowFragments) as? JSONDict else {
                                                                    throw NSError()
        }
        return dictionary
    }
    
    public var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data,
                                                  options: .allowFragments)).flatMap { $0 as? JSONDict }
    }
}
