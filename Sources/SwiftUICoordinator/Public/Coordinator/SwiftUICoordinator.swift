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
    
    public internal(set) weak var navigationRouter: NavigationPushing?
    fileprivate(set) weak var splitRouter: NavigationSplitting?
    
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
        self.id = id
        Log.initialization(category: String(describing: Self.self), metadata: ["id": id])
    }
    
    deinit {
        Log.deinitialization(
            category: String(describing: Self.self),
            metadata: ["id": id]
        )
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
        Log.critical(
            category: String(describing: Self.self),
            message: "createScene not overridden by the sublcass",
            metadata: ["id": id]
        )
        assertionFailure("createScene not overridden by the sublcass.", file: #file, line: #line)
        return EmptyView().erased()
    }
    
    // MARK: - Split navigation
    
    /// Shows coordinator's presentation context as a detail content in navigation split view.
    ///
    /// Works only when the presenting coordinator is inside navigation split view as
    /// a supplementary content. Otherwise, fallback presentation would happen (Pushing inside navigation stack / presenting
    /// modally).
    ///
    /// - Parameter coordinator: Presented coordinator.
    /// - Returns: Coordination result of the presented coordinator.
    public func show<T>(
        _ coordinator: SwiftUICoordinator<T>,
        fallbackPresentationStyle: FallbackPresentationStyle = .modal
    ) -> AnyPublisher<T, Never> {
        showDetail(coordinator, fallbackPresentationStyle: fallbackPresentationStyle)
    }
    
    /// Push coordinator if the desired presentation is not possible to be performed.
    /// - Parameters:
    ///   - coordinator: Presented coordinator
    ///   - fallbackStyle: Modal fallback presentation style.
    /// - Returns: Coordination result of the presented coordinator
    func fallbackPush<T>(
        _ coordinator: SwiftUICoordinator<T>,
        fallbackStyle: ModalPresentationStyle
    ) -> AnyPublisher<T, Never> {
        guard let router = navigationRouter else {
            return coordinate(to: coordinator, presentationStyle: fallbackStyle)
        }
        return router.push(coordinator)
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
        Log.trace(
            category: String(describing: Self.self),
            message: "Coordinator presented",
            metadata: [
                "Presenting coordinator id": id,
                "Presented coordinator id": coordinator.id
            ]
        )
        return coordinator.onFinish.eraseToAnyPublisher()
    }
    
    private func handleDismiss<T>(of coordinator: SwiftUICoordinator<T>) {
        coordinator.onFinish
            .map { _ in }
            .sink(receiveCompletion: { [weak self, weak coordinator] _ in
                Log.trace(
                    category: String(describing: Self.self),
                    message: "Coordinator dismissed",
                    metadata: [
                        "Presenting coordinator id": self?.id as Any,
                        "Dismissed coordinator id": coordinator?.id as Any
                    ]
                )
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

// MARK: - Split navigation INTERNAL

public struct FallbackPresentationStyle {
    fileprivate enum Context {
        case navigation
        case modal
    }
    fileprivate let modalFallbackStyle: ModalPresentationStyle
    fileprivate let context: Context
    
    public static var modal: Self = .modal(.sheet)
    
    public static func navigation(modalFallbackStyle: ModalPresentationStyle) -> Self {
        .init(modalFallbackStyle: modalFallbackStyle, context: .navigation)
    }
    
    public static func modal(_ fallbackStyle: ModalPresentationStyle) -> Self {
        .init(modalFallbackStyle: fallbackStyle, context: .modal)
    }
}

extension SwiftUICoordinator {
    func showDetail<T>(
        _ coordinator: SwiftUICoordinator<T>,
        fallbackPresentationStyle: FallbackPresentationStyle = .modal
    ) -> AnyPublisher<T, Never> {
        guard let splitRouter else {
            return fallbackCoordinate(to: coordinator, style: fallbackPresentationStyle)
        }
        return splitRouter.show(coordinator, context: .detail)
    }
    
    private func fallbackCoordinate<T>(
        to coordinator: SwiftUICoordinator<T>,
        style: FallbackPresentationStyle
    ) -> AnyPublisher<T, Never> {
        switch style.context {
        case .navigation:
            return fallbackPush(coordinator, fallbackStyle: style.modalFallbackStyle)
        case .modal:
            return coordinate(to: coordinator, presentationStyle: style.modalFallbackStyle)
        }
    }
}

extension SplitNavigationSwiftUICoordinator {
    func _addChild<T>(
        _ coordinator: SwiftUICoordinator<T>,
        context: SplitContext
    ) {
        coordinator.splitRouter = self
        addChild(coordinator, context: context)
    }
}
