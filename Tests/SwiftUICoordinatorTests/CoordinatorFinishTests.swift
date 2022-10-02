//
//  CoordinatorFinishTests.swift
//  
//
//  Created by Kakhaberi Kiknadze on 02.10.22.
//

import XCTest
import SwiftUI
import Combine
@testable import SwiftUICoordinator

final class CoordinatorFinishTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        cancellables = nil
    }
    
    // MARK: - Cases
    
    func test_coordination_sheet_finish_result() {
        // GIVEN
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2")
        let expectedResult = "Result"

        let expectation = self.expectation(description: "coordination finish")
        
        // WHEN
        coordinator.coordinate(to: presentedCoordinator, presentationStyle: .sheet)
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { result in
                // THEN
                XCTAssertEqual(result, expectedResult)
            })
            .store(in: &cancellables)
        
        presentedCoordinator.finish(result: expectedResult)
        waitForExpectations(timeout: 0.1)
    }
    
    func test_coordination_fullScreen_finish_result() {
        // GIVEN
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2")
        let expectedResult = "Result"

        let expectation = self.expectation(description: "coordination finish")
        
        // WHEN
        coordinator.coordinate(to: presentedCoordinator, presentationStyle: .fullScreen)
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { result in
                // THEN
                XCTAssertEqual(result, expectedResult)
            })
            .store(in: &cancellables)
        
        presentedCoordinator.finish(result: expectedResult)
        waitForExpectations(timeout: 0.1)
    }
    
    func test_coordination_custom_finish_result() {
        // GIVEN
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2")
        let expectedResult = "Result"

        let expectation = self.expectation(description: "coordination finish")
        
        // WHEN
        coordinator.coordinate(to: presentedCoordinator, presentationStyle: .custom(.scale))
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { result in
                // THEN
                XCTAssertEqual(result, expectedResult)
            })
            .store(in: &cancellables)
        
        presentedCoordinator.finish(result: expectedResult)
        waitForExpectations(timeout: 0.1)
    }
    
    func test_coordination_navigation_finish_and_deacllocation() {
        // GIVEN
        let coordinator: NavigationSwiftUICoordinator<Void> = .init(id: "1")
        var presentedCoordinator: SwiftUICoordinator<String>! = .init(id: "2")
        weak var weakPresentedCoordinator = presentedCoordinator
        let expectedResult = "Result"
        
        let expectation = self.expectation(description: "coordination finish")
        XCTAssertNil(presentedCoordinator.navigationRouter)
        
        // WHEN
        coordinator.push(presentedCoordinator)
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { result in
                // THEN
                XCTAssertEqual(result, expectedResult)
            })
            .store(in: &cancellables)
        
        // THEN
        XCTAssertNotNil(presentedCoordinator.navigationRouter)

        presentedCoordinator.finish(result: expectedResult)
        waitForExpectations(timeout: 0.1)
        
        presentedCoordinator = nil
        XCTAssertNil(weakPresentedCoordinator)
    }
    
    func test_coordinator_finish() {
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "1")
        let expectation = self.expectation(description: "coordinator finish")
        let expectedResult = "Result"
        
        presentedCoordinator.onFinish
            .sink { completion in
                expectation.fulfill()
            } receiveValue: { result in
                XCTAssertEqual(result, expectedResult)
            }
            .store(in: &cancellables)

        presentedCoordinator.finish(result: expectedResult)
        waitForExpectations(timeout: 0.1)
    }
    
    func test_coordinator_cancel() {
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "1")
        let expectation = self.expectation(description: "coordinator cancel")
        
        presentedCoordinator.onFinish
            .sink { completion in
                expectation.fulfill()
            } receiveValue: { _ in
                XCTFail("Shouldn't have received a value when cancelled")
            }
            .store(in: &cancellables)

        presentedCoordinator.cancel()
        waitForExpectations(timeout: 0.1)
    }
}

