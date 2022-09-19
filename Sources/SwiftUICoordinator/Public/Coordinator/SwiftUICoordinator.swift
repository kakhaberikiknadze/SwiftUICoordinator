//
//  SwiftUICoordinator.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI
import Combine

/// Abstract coordinator
open class SwiftUICoordinator<CoordinationResult>: Coordinating {
    // MARK: - Private properties
    
    private var cancellables = Set<AnyCancellable>()
    private let result = PassthroughSubject<CoordinationResult, Never>()
    private let dismiss = PassthroughSubject<Void, Never>()
    private var isInNavigation: Bool
    
    // MARK: - Public properties
    
    /// Unique identifier of the coordinator
    public let id: String
    
    private(set) lazy var scene: AnyView = createScene()
    
    public private(set) weak var navigationRouter: NavigationPushing?
    
    /// New scene to be presented.
    @Published private(set) var presentable: Presentable?
    
    /// Tab Item for `TabView`.
    @Published public var tabItem: AnyView = EmptyView().erased()
    
    /// Presentation style of the `scene`to determine wether to wrap it inside navigation or not.
    public fileprivate(set) var presentationStyle: ModalPresentationStyle = .fullScreen
    
    /// Coordination mode. Either `normal` or `navigation`.
    ///
    /// If it's `navigation`, the scene is wrapped inside navigation view.
    let mode: CoordinatorMode
    
    public var onCancel: AnyPublisher<Void, Never> { dismiss.first().eraseToAnyPublisher() }
    public var onFinish: AnyPublisher<CoordinationResult, Never> { result.first().eraseToAnyPublisher() }
    
    // MARK: - Init
    
    public init(
        id: String,
        mode: CoordinatorMode = .normal
    ) {
        print(id, "Initialised!")
        self.id = id
        self.mode = mode
        isInNavigation = mode == .navigation
    }
    
    deinit {
        print("\nLOG FROM PARENT CLASS ========================")
        print(String(describing: Self.self) + id, "Deinitialised!")
        print("==============================================")
    }
    
    // MARK: - Methods
    
    func start() -> Presentable {
        print("===\n\nStarting coordinator", id , "is in navigation", mode == .navigation)
        switch mode {
        case .normal:
            return CoordinatorView(coordinator: self) { [unowned self] in
                self.scene
            }
        case .navigation:
            return NavigationCoordinatorView(
                router: .init(
                    id: "NAVIGATION_ROUTER_" + id,
                    rootSceneProvider: asNavigationScene()
                ),
                presentationStyle: presentationStyle,
                onCancel: { [weak self] in
                    self?.cancel()
                }
            )
        }
    }
    
    public func getRoot() -> AnyView {
        start().scene
            .customTransition()
            .erased()
    }
    
    
    /// Creates a scene to be wrapped inside coordinator as a presented scene.
    ///
    /// Should be overridden by the subclass. Otherwise, it's considered as a developer error
    /// and causes a crash.
    /// - Returns: A scene to be wrapped inside coordinator as a presented scene
    open func createScene() -> AnyView {
        assertionFailure("createScene not overridden by the sublcass.", file: #file, line: #line)
        return EmptyView().erased()
    }
}

// MARK: - Coordinate

public extension SwiftUICoordinator {
    func coordinate<T>(
        to coordinator: SwiftUICoordinator<T>,
        presentationStyle: ModalPresentationStyle = .fullScreen
    ) -> AnyPublisher<T, Never> {
        coordinator.presentationStyle = presentationStyle
        presentable = coordinator.start()
        handleDismiss(of: coordinator)
        print(id, "presented", coordinator.id)
        return coordinator.onFinish.eraseToAnyPublisher()
    }
    
    func handleDismiss<T>(of coordinator: SwiftUICoordinator<T>) {
        coordinator.onCancel
            .sink { [weak self, weak coordinator] _ in
                print("Dismissed", coordinator?.id ?? "nil", "in", self?.id ?? "nil")
                self?.presentable = nil
            }
            .store(in: &cancellables)
        
        coordinator.onFinish
            .map { _ in }
            .sink { [weak self] in
                self?.presentable?.dismiss()
                self?.presentable = nil
            }
            .store(in: &cancellables)
    }
}
 
// MARK: - Finish coordination

public extension SwiftUICoordinator {
    func finish(result: CoordinationResult) {
        print("\n\n")
        self.result.send(result)
    }
    
    func cancel() {
        print("\n\n")
        dismiss.send()
    }
}

public extension SwiftUICoordinator where CoordinationResult == Void {
    func finish() {
        finish(result: ())
    }
}

// MARK: - TabSceneProviding

extension SwiftUICoordinator: TabSceneProviding {
    public var tabScene: AnyView {
        start().scene
            .tabItem { tabItem }
            .tag(id)
            .erased()
    }
}

extension SwiftUICoordinator: Hashable {
    public static func == (lhs: SwiftUICoordinator<CoordinationResult>, rhs: SwiftUICoordinator<CoordinationResult>) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension SwiftUICoordinator: NavigationRouterChildable {
    func setNavigationRouter<R: NavigationPushing>(_ router: R) {
        navigationRouter = router
    }
}

public protocol NavigationPushing: AnyObject {
    func push<T>(_ coordinator: SwiftUICoordinator<T>) -> AnyPublisher<T, Never>
}
