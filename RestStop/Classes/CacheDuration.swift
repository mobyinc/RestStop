//
//  CacheDuration.swift
//  RestStop
//
//  Created by George McCarroll on 9/18/18.
//

import Foundation

public enum CacheDuration {
    case zero
    case minutely
    case hourly
    case custom(num: TimeInterval)
}

extension CacheDuration: RawRepresentable {
    public typealias RawValue = TimeInterval
    
    public init?(rawValue: RawValue) {
        
        switch rawValue {
        case 0:
            self = .zero
        case 60:
            self = .minutely
        case 3600:
            self = .hourly
        default:
            self = .custom(num: rawValue)
        }
    }
    
    public var rawValue: RawValue {
        
        switch self {
        case .zero:
            return 0
        case .minutely:
            return 60
        case .hourly:
            return 3600
        case .custom(let num):
            return num
        }
    }
    
    public var expiresAt: Date {
        return Date(timeInterval: rawValue, since: Date())
    }
}
