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
    
    /// Publishes result of a specified type.
    private let result = PassthroughSubject<CoordinationResult, Never>()

    /// Triggered to terminate coordination without providing any result.
    private let dismiss = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    
    /// Unique identifier of the coordinator
    public let id: String
    
    /// A scene to be wrapped inside `CoordinatorView` or `NavigationCoordinatorView`
    private(set) lazy var scene: AnyView = createScene()
    
    public private(set) weak var navigationRouter: NavigationPushing?
    
    /// New scene to be presented.
    @Published private(set) var presentable: PresentationContext?
    
    /// Tab Item for `TabView`.
    @Published public var tabItem: TabItem = .empty
    
    /// Presentation style of the `scene`to determine wether to wrap it inside navigation or not.
    public fileprivate(set) var presentationStyle: ModalPresentationStyle = .fullScreen
    
    /// Coordination mode. Either `normal` or `navigation`.
    ///
    /// If it's `navigation`, the scene is wrapped inside navigation view.
    let mode: CoordinatorMode
    
    /// Triggered to terminate coordination without providing any result.
    public var onCancel: AnyPublisher<Void, Never> { dismiss.first().eraseToAnyPublisher() }
    
    /// Triggered when coordination is finished and provides result of a specified type.
    public var onFinish: AnyPublisher<CoordinationResult, Never> { result.first().eraseToAnyPublisher() }
    
    // MARK: - Init
    
    /// Instantiates a coordinator used for `SwiftUI.
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - mode: Coordination mode. Either `.normal` or  `.navigation`.
    ///   If it's `.navigation` new `NavigationStack` will be created and the scene
    ///   will be wrapped inside it.
    public init(
        id: String,
        mode: CoordinatorMode = .normal
    ) {
        print(id, "Initialised!")
        self.id = id
        self.mode = mode
    }
    
    deinit {
        print("\nLOG FROM PARENT CLASS ========================")
        print(String(describing: Self.self) + id, "Deinitialised!")
        print("==============================================")
    }
    
    // MARK: - Methods
    
    /// Root presentation context  providing a scene wrapped inside either `CoordinatorView` or `NavigationCoordinatorView`
    /// as well as cancelation and dismiss actions.
    func start() -> PresentationContext {
        print("===\n\nStarting coordinator", id , "is in navigation", mode == .navigation)
        switch mode {
        case .normal:
            return CoordinatorView(coordinator: self) {
                self.scene
            }
        case .navigation:
            return NavigationCoordinatorView(
                router: NavigationRouter(
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
    
    /// Get the root scene ready to be presented inside `SwiftUI` view.
    /// - Returns: Type erased view.
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
    /// Coordinates to the provided coordinator using a presentation style.
    /// - Parameters:
    ///   - coordinator: A destination coordinator
    ///   - presentationStyle: Modal presentation style. E.g.,`.sheet`, `.fullScren`, `.custom`
    /// - Returns: A publisher containing a coordination result
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
    
    private func handleDismiss<T>(of coordinator: SwiftUICoordinator<T>) {
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

extension SwiftUICoordinator {
    /// Call this to finish coordination and provide a coordination result.
    /// - Parameter result: Coordination result
    public func finish(result: CoordinationResult) {
        print("\n\n")
        self.result.send(result)
    }
    
    func cancel() {
        print("\n\n")
        dismiss.send()
    }
}

public extension SwiftUICoordinator where CoordinationResult == Void {
    /// Call this to finish coordination with a `Void` result.
    func finish() {
        finish(result: ())
    }
}

// MARK: - Hashable

extension SwiftUICoordinator: Hashable {
    public static func == (lhs: SwiftUICoordinator<CoordinationResult>, rhs: SwiftUICoordinator<CoordinationResult>) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - NavigationRouterChildable

extension SwiftUICoordinator: NavigationRouterChildable {
    func setNavigationRouter<R: NavigationPushing>(_ router: R) {
        navigationRouter = router
    }
}
