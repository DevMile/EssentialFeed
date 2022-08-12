//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Milan Bojic on 6.8.22..
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https:a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https:a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorWhenNon200HTTPResponseCode() {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 300, 400, 500]
        
        statusCodes.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, at: index, data: json)
            }
        }
    }
    
    func test_load_deliversErrorWhen200HTTPResponseCodeWithInvalidJSON() {
        let (sut, client) = makeSUT()
                
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyJSON = Data("{\"items\": []}".utf8) // or use: makeItemsJSON(items: [])
            client.complete(withStatusCode: 200, data: emptyJSON)
        }
    }
    
    func test_load_deliversFeedItemsOn200HTTPResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), image: URL(string: "https://a-image-url.com")!)
        let item2 = makeItem(id: UUID(), description: "a description", location: "a location", image: URL(string: "https://another-image-url.com")!)
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON(items: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_notDeliversResultAfterSUTInstanceHasBeenDealocated() {
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON(items: []))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https:a-url.com")!,
                         file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance not deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result,
                        when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        // Add expectation because sut.load is asynchronious
        let exp = expectation(description: "Wait for load completion.")
        
        // This is done so RemoteFeedLoader.Result which is a LoadFeedResult does not need to be Equatable
        // In this way we dont change production code in FeedLoader because of test cases.
        
        sut.load { receivedResult in
            // Switch two enums at the same time :)
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected to receive \(receivedResult) but got \(expectedResult) result.")
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(id: UUID,
                             description: String? = nil,
                             location: String? = nil,
                             image: URL) -> (model: FeedItem, json: [String: Any]) {
        
        let feedItem = FeedItem(id: id, description: description, location: location, imageURL: image)
        let json = [
            "id": feedItem.id.uuidString,
            "description": feedItem.description,
            "location": feedItem.location,
            "image": feedItem.imageURL.absoluteString
        ].compactMapValues { $0 } // return only non-nil values
        
        return (feedItem, json)
    }
    
    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    // MARK: - HTTPClientSpy
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            // store url and completion in messages array
            // completion will be executed later with complete(with:) methods
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0, data: Data) {
            let statusCode = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, statusCode))
        }
    }
}
