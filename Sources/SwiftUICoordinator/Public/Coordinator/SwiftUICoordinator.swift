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
    
    /// A scene to be wrapped inside `CoordinatorView` or `NavigationCoordinatorView`
    private(set) lazy var scene: AnyView = createScene()
    
    /// New scene to be presented.
    @Published private(set) var presentable: PresentationContext?
    
    // MARK: - Public properties
    
    /// Unique identifier of the coordinator
    public let id: String
    
    public private(set) weak var navigationRouter: NavigationPushing?
    
    /// Tab Item for `TabView`.
    @Published public var tabItem: TabItem = .empty
    
    /// Presentation style of the `scene`to determine wether to wrap it inside navigation or not.
    public fileprivate(set) var presentationStyle: ModalPresentationStyle = .fullScreen
    
    /// Triggered when coordination is finished and provides result of a specified type.
    public var onFinish: AnyPublisher<CoordinationResult, Never> { result.first().eraseToAnyPublisher() }
    
    // MARK: - Init
    
    /// Instantiates a coordinator used for `SwiftUI.
    /// - Parameters:
    ///   - id: Unique identifier
    public init(id: String = UUID().uuidString) {
        print(id, "Initialised!")
        self.id = id
    }
    
    deinit {
        print(String(describing: Self.self), id, "Deinitialised!")
    }
    
    // MARK: - Methods
    
    /// Creates and returns a `PresentationContext`.
    func start() -> PresentationContext {
        CoordinatorView(coordinator: self) {
            self.scene
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
        coordinator.onFinish
            .map { _ in }
            .sink(receiveCompletion: { [weak self, weak coordinator] _ in
                print("Dismissed", coordinator?.id ?? "nil", "in", self?.id ?? "nil")
                self?.presentable = nil
            }, receiveValue: { [weak self] in
                self?.presentable?.dismiss()
            })
            .store(in: &cancellables)
    }
}
 
// MARK: - Finish coordination

extension SwiftUICoordinator {
    /// Call this to finish coordination and provide a coordination result.
    /// - Parameter result: Coordination result
    public func finish(result: CoordinationResult) {
        self.result.send(result)
        self.result.send(completion: .finished)
    }
    
    func cancel() {
        self.result.send(completion: .finished)
    }
}

public extension SwiftUICoordinator where CoordinationResult == Void {
    /// Call this to finish coordination with a `Void` result.
    func finish() {
        finish(result: ())
    }
}

// MARK: - NavigationRouterChildable

extension SwiftUICoordinator: NavigationRouterChildable {
    func setNavigationRouter<R: NavigationPushing>(_ router: R) {
        navigationRouter = router
    }
}
