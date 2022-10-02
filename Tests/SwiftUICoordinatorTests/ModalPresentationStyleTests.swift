//
//  ModalPresentationStyleTests.swift
//  
//
//  Created by Kakhaberi Kiknadze on 02.10.22.
//

import XCTest
import SwiftUI
import Combine
@testable import SwiftUICoordinator

final class ModalPresentationStyleTests: XCTestCase {
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
    
    func test_coordination_sheet_presentation() {
        // GIVEN
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        let presentedCoordinator: SwiftUICoordinator<Void> = .init(id: "2")

        // WHEN
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .sheet)
        
        // THEN
        XCTAssertEqual(presentedCoordinator.presentationStyle, .sheet)
    }
    
    func test_coordination_fullScreen_presentation() {
        // GIVEN
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        let presentedCoordinator: SwiftUICoordinator<Void> = .init(id: "2")

        // WHEN
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .fullScreen)
        
        // THEN
        XCTAssertEqual(presentedCoordinator.presentationStyle, .fullScreen)
    }
    
    func test_coordination_custom_presentation() {
        // GIVEN
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        let presentedCoordinator: SwiftUICoordinator<Void> = .init(id: "2")

        // WHEN
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .custom(.slide))
        
        // THEN
        XCTAssertEqual(presentedCoordinator.presentationStyle, .custom(.scale))
    }
    
    // MARK: - CoordinatorView modal presentation
    
    func test_coordinator_view_show_custom_modal() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2")
        
        let coordinatorView = CoordinatorView(coordinator: coordinator) {
            coordinator.scene
        }
        
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .custom(.scale))
        XCTAssertTrue(coordinatorView.showCustomModal)
        XCTAssertFalse(coordinatorView.showSheet)
        XCTAssertFalse(coordinatorView.showFullScreen)
    }
    
    func test_coordinator_view_show_sheet() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2")
        
        let coordinatorView = CoordinatorView(coordinator: coordinator) {
            coordinator.scene
        }
        
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .sheet)
        XCTAssertTrue(coordinatorView.showSheet)
        XCTAssertFalse(coordinatorView.showFullScreen)
        XCTAssertFalse(coordinatorView.showCustomModal)
    }
    
    func test_coordinator_view_show_fullScreen() {
        let coordinator: SwiftUICoordinator<Void> = .init(id: "1")
        let presentedCoordinator: SwiftUICoordinator<String> = .init(id: "2")
        
        let coordinatorView = CoordinatorView(coordinator: coordinator) {
            coordinator.scene
        }
        
        _ = coordinator.coordinate(to: presentedCoordinator, presentationStyle: .fullScreen)
        XCTAssertTrue(coordinatorView.showFullScreen)
        XCTAssertFalse(coordinatorView.showSheet)
        XCTAssertFalse(coordinatorView.showCustomModal)
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
