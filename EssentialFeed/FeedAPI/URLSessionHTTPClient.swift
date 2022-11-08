//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 16.8.22..
//

import Foundation

// Adapter type

public class URLSessionHTTPClient: HTTPClient {
    var session: URLSession
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            // Using: Result(catching: () throws -> (Data, HTTPURLResponse))
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}
