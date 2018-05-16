//
//  Coder+Extensions.swift
//  Pagliacci
//
//  Created by George McCarroll on 5/14/18.
//  Copyright © 2018 Moby, Inc. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    public static var shared: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return decoder
    }()
}

public extension JSONEncoder {
	public static var shared: JSONEncoder = {
		let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601)
		
		return encoder
	}()
}


