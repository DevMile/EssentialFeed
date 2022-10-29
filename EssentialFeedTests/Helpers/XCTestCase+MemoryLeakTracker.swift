//
//  XCTestCase+MemoryLeakTracker.swift
//  EssentialFeedTests
//
//  Created by Milan Bojic on 16.8.22..
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance not deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
