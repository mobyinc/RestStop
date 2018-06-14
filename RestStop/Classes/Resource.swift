//
//  Resource.swift
//  RestStop
//
//  Created by James Jacoby on 5/4/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation

public struct Resource : Codable {
    public private(set) var data: Data?
    
    public static func fromCodable<T: Codable>(_ object: T) -> Resource {
        let data = try? JSONEncoder.shared.encode(object)
        return Resource(data: data)
    }
    
    public init(data: Data?) {
        self.data = data;
    }
    
    public func asType<T: Codable>(_ type: T.Type) -> T? {
        if let data = self.data {
            
            do {
                return try JSONDecoder.shared.decode(T.self, from: data)
            } catch {
                debugPrint(error)
                return nil
            }
        } else {
            return nil
        }
    }
}
