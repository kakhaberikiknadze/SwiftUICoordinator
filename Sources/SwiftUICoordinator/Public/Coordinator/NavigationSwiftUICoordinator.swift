//
//  NavigationSwiftUICoordinator.swift
//  
//
//  Created by Kakhaberi Kiknadze on 29.09.22.
//

import SwiftUI
import Combine

open class NavigationSwiftUICoordinator<CoordinationResult>: SwiftUICoordinator<CoordinationResult> {
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var pushedScenes: [String: any NavigationScene] = [:]
    
    @Published var navigationPath = NavigationPath()
    
    // MARK: - Init
    
    public override init(id: String) {
        super.init(id: id)
        setupObservers()
    }
    
    deinit {
        Log.deinitialization(category: String(describing: Self.self), metadata: ["id": id])
    }
    
    // MARK: - Methods
    
    override func start() -> PresentationContext {
        NavigationCoordinatorView(
            router: self,
            presentationStyle: presentationStyle,
            onCancel: { [weak self] in
                self?.cancel()
            },
            content: {
                CoordinatorView(coordinator: self) { [weak self] in
                    self?.scene
                }
            }
        )
    }
    
    private func setupObservers() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        $navigationPath.compactMap(\.codable)
            .encode(encoder: encoder)
            .decode(type: [String].self, decoder: decoder)
            .map {
                $0.compactMap { $0.data(using: .utf8) }
                    .compactMap {
                        try? decoder.decode(NavigationDestinationIdentifier.self, from: $0)
                    }
            }
            .replaceError(with: [])
            .sink { [weak self] in
                self?.syncPushedScenes(using: $0)
            }
            .store(in: &cancellables)
    }
    
    private func syncPushedScenes(
        using destinationIdentifiers: [NavigationDestinationIdentifier]
    ) {
        pushedScenes
            .map(\.key)
            .filter { key in
                destinationIdentifiers.contains(where: { $0.rawValue == key }) == false
            }
            .forEach { key in
                pushedScenes[key]?.cancel()
                pushedScenes[key] = nil
            }
    }
    
    func push<S: NavigationScene>(_ sceneProvider: S) {
        pushedScenes[sceneProvider.id] = sceneProvider
        let identifier = NavigationDestinationIdentifier(rawValue: sceneProvider.id)
        navigationPath.append(identifier)
    }
    
    /// Push coordinator if the desired presentation is not possible to be performed.
    /// - Parameters:
    ///   - coordinator: Presented coordinator
    ///   - fallbackStyle: Modal fallback presentation style.
    /// - Returns: Coordination result of the presented coordinator
    public override func fallbackPush<T>(
        _ coordinator: SwiftUICoordinator<T>,
        fallbackStyle: ModalPresentationStyle
    ) -> AnyPublisher<T, Never> {
        push(coordinator)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
    
    public func popToRoot() {
        navigationPath.removeLast(pushedScenes.count)
    }
}

// MARK: - NavigatonPushing

extension NavigationSwiftUICoordinator: NavigationPushing {
    public func push<T>(_ coordinator: SwiftUICoordinator<T>) -> AnyPublisher<T, Never> {
        coordinator.navigationRouter = self
        let coordinatorId = coordinator.id
        
        coordinator.onFinish
            .sink{ [weak self] _ in
                self?.pushedScenes[coordinatorId] = nil
                self?.pop()
            }
            .store(in: &cancellables)
        
        push(coordinator.asNavigationScene())
        
        return coordinator.onFinish.eraseToAnyPublisher()
    }
}

// MARK: - NavigationRouting

extension NavigationSwiftUICoordinator: NavigationRouting {
    func scene(for id: String) -> AnyView? {
        pushedScenes[id]?.scene
    }
}
