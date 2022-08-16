//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 16.8.22..
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    var session: URLSession
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
