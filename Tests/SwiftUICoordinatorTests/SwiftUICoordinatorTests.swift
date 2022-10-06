import XCTest
import SwiftUI
import Combine
@testable import SwiftUICoordinator

final class SwiftUICoordinatorTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        cancellables = nil
    }
    
    // MARK: - Presentable
    
    func test_coordinator_presentable_exists() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2")
        
        XCTAssertNil(coordinator.presentable)
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .fullScreen)
        XCTAssertNotNil(coordinator.presentable)
    }
    
    // MARK: - Navigation
    
    func test_coordinator_navigation_router_exists() {
        let navigationCoordinator = NavigationSwiftUICoordinator<Void>(id: "nav")
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        XCTAssertNil(coordinator.navigationRouter)
        _ = navigationCoordinator.push(coordinator)
        XCTAssertNotNil(coordinator.navigationRouter)
    }
    
    func test_navigation_lifecycle() throws {
        let navigationCoordinator = NavigationSwiftUICoordinator<Void>(id: "nav")
        let coordinatorOne: SwiftUICoordinator<String>! = .init(id: "1")
        var coordinatorTwo: SwiftUICoordinator<String>! = .init(id: "2")
        let expectedResult = "Result"
        
        weak var weakCoordinatorOne = coordinatorOne
        weak var weakCoordinatorTwo = coordinatorTwo
        
        XCTAssertNil(coordinatorOne.navigationRouter)
        XCTAssertEqual(navigationCoordinator.navigationPath.count, 0)
        
        _ = navigationCoordinator.push(coordinatorOne)
        
        XCTAssertEqual(navigationCoordinator.navigationPath.count, 1)
        
        let router = try XCTUnwrap(coordinatorOne.navigationRouter)
        
        let expectation = self.expectation(description: "coordinator two finish")
        router.push(coordinatorTwo)
            .sink { completion in
                expectation.fulfill()
            } receiveValue: { result in
                XCTAssertEqual(result, expectedResult)
            }
            .store(in: &cancellables)
        
        XCTAssertEqual(navigationCoordinator.navigationPath.count, 2)
        
        coordinatorTwo.finish(result: expectedResult)
        waitForExpectations(timeout: 0.2)
        
        coordinatorTwo = nil
        XCTAssertNil(weakCoordinatorTwo)
        XCTAssertNotNil(weakCoordinatorOne)
        XCTAssertEqual(navigationCoordinator.navigationPath.count, 1)
    }
    
    // MARK: - Tab view
    
    func test_tab_coordinator_coordinators_retained() {
        var coordinatorOne: SwiftUICoordinator<Void>! = .init(id: "1")
        var coordinatorTwo: SwiftUICoordinator<Void>! = .init(id: "2")
        
        weak var weakCoordinatorOne = coordinatorOne
        weak var weakCoordinatorTwo = coordinatorTwo
        
        let coordinator: TabSwiftUICoordinator<Void> = .init(
            id: "TAB_COORDINATOR",
            tabs: [coordinatorOne, coordinatorTwo]
        )
        
        coordinatorOne = nil
        coordinatorTwo = nil
        
        XCTAssertNotNil(coordinator)
        XCTAssertNotNil(weakCoordinatorOne)
        XCTAssertNotNil(weakCoordinatorTwo)
    }
    
    func test_tab_coordinator_coordinators_property_injection_retained() {
        var coordinatorOne: SwiftUICoordinator<Void>! = .init(id: "1")
        var coordinatorTwo: SwiftUICoordinator<Void>! = .init(id: "2")
        
        weak var weakCoordinatorOne = coordinatorOne
        weak var weakCoordinatorTwo = coordinatorTwo
        
        let coordinator: TabSwiftUICoordinator<Void> = TabSwiftUICoordinator(
            id: "TAB_COORDINATOR",
            tabs: [SwiftUICoordinator<Void>]()
        )
        coordinator.setTabs([coordinatorOne, coordinatorTwo])
        
        coordinatorOne = nil
        coordinatorTwo = nil
        
        XCTAssertNotNil(coordinator)
        XCTAssertNotNil(weakCoordinatorOne)
        XCTAssertNotNil(weakCoordinatorTwo)
    }
    
    // MARK: - Deallocation
    
    func test_swiftUICoordinator_deallocation() {
        var coordinator: SwiftUICoordinator<Void>! = .init(id: "1")
        var coordinatorView: AnyView! = coordinator.getRoot()
        weak var weakCoordinator = coordinator
        
        XCTAssertNotNil(coordinatorView)
        coordinatorView = nil
        coordinator = nil
        XCTAssertNil(weakCoordinator)
    }
    
    func test_tab_coordinator_deallocation() {
        var coordinatorOne: SwiftUICoordinator<Void>! = .init(id: "1")
        var coordinatorTwo: SwiftUICoordinator<Void>! = .init(id: "2")
        
        weak var weakCoordinatorOne = coordinatorOne
        weak var weakCoordinatorTwo = coordinatorTwo
        
        var coordinator: TabSwiftUICoordinator<Void>! = .init(
            id: "TAB_COORDINATOR",
            tabs: [coordinatorOne, coordinatorTwo]
        )
        
        weak var weakCoordinator = coordinator
        
        coordinator = nil
        coordinatorOne = nil
        coordinatorTwo = nil
        
        XCTAssertNil(weakCoordinator)
        XCTAssertNil(weakCoordinatorOne)
        XCTAssertNil(weakCoordinatorTwo)
    }
}
