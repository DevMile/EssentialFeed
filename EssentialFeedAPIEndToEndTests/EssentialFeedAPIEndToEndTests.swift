//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Milan Bojic on 16.8.22..
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {
    
    // Caching example
//    func cachingDemo() {
//        // Setup cache
//        let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 10 * 1024 * 1024, diskPath: nil)
//        let configuration = URLSessionConfiguration.default
//        configuration.urlCache = cache
//        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData // check many options for cache policy
//        let session = URLSession(configuration: configuration)
//
//        let url = URL(string: "https://any-url.com")!
//        // or setup cache policy when creating request
//        let request = URLRequest(url: url, cachePolicy: .returnCacheDataDontLoad, timeoutInterval: 30)
//
//        // If setting shared instance of URLCache, do it in application didFinishLaunching.
//        URLCache.shared = cache
//    }
    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(imageFeed)?:
            XCTAssertEqual(imageFeed.count, 8, "Expected 8 images in test account feed.")
            imageFeed.enumerated().forEach { index, item in
                XCTAssertEqual(item, expectedImage(at: index), "Unexpected value for item at index: \(index)")
            }
            
        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")
            
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        switch getFeedImageDataResult() {
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            
        case let .failure(error)?:
            XCTFail("Expected successful image data result, got \(error) instead")
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result? {
        // First server url not working because of redirection.
        //        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        // URLSession is using .ephemeral configuration, meaning - not storing url requests cache to disk
        // If default configuration was used, tests would pass even when network is offline because they used cached state.
        let loader = RemoteFeedLoader(url: feedTestServerURL, client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)
        
        var receivedResult: FeedLoader.Result?
        let exp = expectation(description: "Wait for load completion")
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func getFeedImageDataResult(file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader.Result? {
        let loader = RemoteFeedImageDataLoader(client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        let url = feedTestServerURL.appendingPathComponent("73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        
        var receivedResult: FeedImageDataLoader.Result?
        _ = loader.loadImageData(from: url) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private var feedTestServerURL: URL {
        return URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }
    
    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }

    private func expectedImage(at index: Int) -> FeedImage {
        return FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
    
}
