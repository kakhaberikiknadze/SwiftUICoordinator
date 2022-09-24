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
    
    // MARK: - Presentation style
    
    func test_coordination_sheet_presentation() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .normal)
        let presentedCoordinator: SwiftUICoordinator<Void> = .init(id: "2", mode: .normal)

        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .sheet)
        XCTAssertEqual(presentedCoordinator.presentationStyle, .sheet)
    }
    
    func test_coordination_fullScreen_presentation() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .normal)
        let presentedCoordinator: SwiftUICoordinator<Void> = .init(id: "2", mode: .normal)

        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .fullScreen)
        XCTAssertEqual(presentedCoordinator.presentationStyle, .fullScreen)
    }
    
    func test_coordination_custom_presentation() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .normal)
        let presentedCoordinator: SwiftUICoordinator<Void> = .init(id: "2", mode: .normal)

        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .custom(.slide))
        XCTAssertEqual(presentedCoordinator.presentationStyle, .custom(.scale))
    }
    
    func test_coordination_sheet_finish() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .normal)
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2", mode: .normal)
        let expectedResult = "Result"

        let expectation = self.expectation(description: "coordination finish")
        coordinator.coordinate(to: presentedCoordinator, presentationStyle: .sheet)
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { result in
                XCTAssertEqual(result, expectedResult)
            })
            .store(in: &cancellables)
        
        presentedCoordinator.finish(result: expectedResult)
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: - Finish
    
    func test_coordination_fullScreen_finish() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .normal)
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2", mode: .normal)
        let expectedResult = "Result"

        let expectation = self.expectation(description: "coordination finish")
        coordinator.coordinate(to: presentedCoordinator, presentationStyle: .fullScreen)
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { result in
                XCTAssertEqual(result, expectedResult)
            })
            .store(in: &cancellables)
        
        presentedCoordinator.finish(result: expectedResult)
        waitForExpectations(timeout: 0.1)
    }
    
    func test_coordination_custom_finish() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .normal)
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2", mode: .normal)
        let expectedResult = "Result"

        let expectation = self.expectation(description: "coordination finish")
        coordinator.coordinate(to: presentedCoordinator, presentationStyle: .custom(.scale))
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { result in
                XCTAssertEqual(result, expectedResult)
            })
            .store(in: &cancellables)
        
        presentedCoordinator.finish(result: expectedResult)
        waitForExpectations(timeout: 0.1)
    }
    
    func test_coordination_navigation_finish() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .navigation)
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2", mode: .normal)
        let expectedResult = "Result"
        let scene = coordinator.getRoot()
        _ = scene // Silence compiler warning about "never read"
        
        let expectation = self.expectation(description: "coordination finish")
        XCTAssertNotNil(coordinator.navigationRouter)
        coordinator.navigationRouter!.push(presentedCoordinator)
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { result in
                
            })
            .store(in: &cancellables)

        presentedCoordinator.finish(result: expectedResult)
        waitForExpectations(timeout: 0.1)
    }
    
    func test_coordinator_finish() {
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "1", mode: .normal)
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
    
    // MARK: - Cancel
    
    func test_coordinator_cancel() {
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "1", mode: .normal)
        let expectation = self.expectation(description: "coordinator cancel")
        
        presentedCoordinator.onCancel
            .sink { completion in
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)

        presentedCoordinator.cancel()
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: - CoordinatorView modal presentation
    
    func test_coordinator_view_show_custom_modal() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .normal)
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2", mode: .normal)
        
        let coordinatorView = CoordinatorView(coordinator: coordinator) {
            coordinator.scene
        }
        
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .custom(.scale))
        XCTAssertTrue(coordinatorView.showCustomModal)
        XCTAssertFalse(coordinatorView.showSheet)
        XCTAssertFalse(coordinatorView.showFullScreen)
    }
    
    func test_coordinator_view_show_sheet() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .normal)
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2", mode: .normal)
        
        let coordinatorView = CoordinatorView(coordinator: coordinator) {
            coordinator.scene
        }
        
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .sheet)
        XCTAssertTrue(coordinatorView.showSheet)
        XCTAssertFalse(coordinatorView.showFullScreen)
        XCTAssertFalse(coordinatorView.showCustomModal)
    }
    
    func test_coordinator_view_show_fullScreen() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .normal)
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2", mode: .normal)
        
        let coordinatorView = CoordinatorView(coordinator: coordinator) {
            coordinator.scene
        }
        
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .fullScreen)
        XCTAssertTrue(coordinatorView.showFullScreen)
        XCTAssertFalse(coordinatorView.showSheet)
        XCTAssertFalse(coordinatorView.showCustomModal)
    }
    
    // MARK: - Presentable
    
    func test_coordinator_presentable_exists() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .normal)
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2", mode: .normal)
        
        XCTAssertNil(coordinator.presentable)
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .fullScreen)
        XCTAssertNotNil(coordinator.presentable)
    }
    
    // MARK: - NavigationRouter
    
    func test_coordinator_navigation_router_exists() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1", mode: .navigation)
        XCTAssertNil(coordinator.navigationRouter)
        let scene = coordinator.getRoot()
        _ = scene // Silence compiler warning about "never read"
        XCTAssertNotNil(coordinator.navigationRouter)
    }
    
    // MARK: - Deallocation
    
    func test_swiftUICoordinator_deallocation() {
        var coordinator: SwiftUICoordinator<Void>! = .init(id: "1", mode: .normal)
        var coordinatorView: AnyView! = coordinator.getRoot()
        _ = coordinatorView // Silence compiler warning about "never read"
        weak var weakCoordinator = coordinator
        
        coordinatorView = nil
        coordinator = nil
        XCTAssertNil(weakCoordinator)
    }
}

extension ModalPresentationStyle: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.sheet, .sheet),
            (.fullScreen, .fullScreen),
            (.custom, .custom):
            return true
        default:
            return false
        }
    }
}
