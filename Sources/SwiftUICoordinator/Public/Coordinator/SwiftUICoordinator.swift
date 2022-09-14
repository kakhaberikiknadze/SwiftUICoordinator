//
//  SwiftUICoordinator.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI
import Combine

/// Integer to track which number of instance is being deallocated
fileprivate var instanceNumber = 0

/// Abstract coordinator
open class SwiftUICoordinator<CoordinationResult>: Coordinating {
    // MARK: - Private properties
    
    private var cancellables = Set<AnyCancellable>()
    private let result = PassthroughSubject<CoordinationResult, Never>()
    private let dismiss = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    
    /// Unique identifier of the coordinator
    public let id: String
    
    private lazy var scene: AnyView = createScene()
    
    /// New scene to be presented.
    @Published private(set) var presentable: Presentable?
    
    /// Tab Item for `TabView`.
    @Published public var tabItem: AnyView = EmptyView().erased()
    
    /// Presentation style of the `scene`to determine wether to wrap it inside navigation or not.
    public let presentationStyle: PresentationStyle
    
    /// Coordination mode. Either `normal` or `navigation`.
    ///
    /// If it's `navigation`, the scene is wrapped inside navigation view.
    let mode: CoordinatorMode
    
    public var onCancel: AnyPublisher<Void, Never> { dismiss.eraseToAnyPublisher() }
    public var onFinish: AnyPublisher<CoordinationResult, Never> { result.eraseToAnyPublisher() }
    
    // MARK: - Init
    
    public init(
        id: String,
        mode: CoordinatorMode = .normal,
        presentationStyle: PresentationStyle
    ) {
        self.id = id
        self.presentationStyle = presentationStyle
        self.mode = mode
    }
    
    deinit {
        print("LOG FROM PARENT CLASS ========================")
        print(
            String(describing: Self.self), "Deinitialised!",
            "Instance number:",
            instanceNumber
        )
        print("==============================================")
        instanceNumber += 1
    }
    
    // MARK: - Methods
    
    private func start() -> Presentable {
        CoordinatorView(coordinator: self) { [unowned self] in
            switch self.mode {
            case .normal:
                self.scene
            case .navigation:
                NavigationCoordinatorView(coordinator: self) { [unowned self] in
                    self.scene
                }
            }
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
        to coordinator: SwiftUICoordinator<T>
    ) -> AnyPublisher<T, Never> {
        presentable = coordinator.start()
        
        coordinator.onFinish
            .map { _ in }
            .merge(with: coordinator.onCancel)
            .sink { [weak self] _ in
                self?.presentable = nil
            }
            .store(in: &cancellables)
        
        return coordinator.onFinish.eraseToAnyPublisher()
    }
}
 
// MARK: - Finish coordination

public extension SwiftUICoordinator {
    func finish(result: CoordinationResult) {
        self.result.send(result)
    }
    
    func cancel() {
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

