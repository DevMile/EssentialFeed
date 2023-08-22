//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 22.8.23..
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
