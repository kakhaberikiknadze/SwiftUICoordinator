//
//  NavigationRouter.swift
//  
//
//  Created by Kakhaberi Kiknadze on 18.09.22.
//

import SwiftUI
import Combine

final class NavigationRouter: ObservableObject, NavigationRouting {
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    public let id: String
    
    @Published var pushedScenes: NavigationPath
    let rootSceneProvider: any SceneProviding
    var rootScene: AnyView { rootSceneProvider.scene }
    
    // MARK: - Init
    
    public init<S: NavigationScene>(
        id: String = UUID().uuidString,
        rootSceneProvider: S,
        pushedSceneProviders: [S] = []
    ) {
        print("|\n--NavigationRouter", id, "Initialised!")
        self.id = id
        self.rootSceneProvider = rootSceneProvider
        pushedScenes = .init(pushedSceneProviders)
        
        rootSceneProvider.setNavigationRouter(self)
        pushedSceneProviders.forEach { $0.setNavigationRouter(self) }
    }
    
    deinit {
        print(String(describing: Self.self) + id, "Deinitialised!")
    }
    
    // MARK: - Methods
    
    func push<S: NavigationScene>(_ sceneProvider: S) {
        pushedScenes.append(sceneProvider)
        sceneProvider.setNavigationRouter(self)
    }
    
    func pop() {
        pushedScenes.removeLast()
    }
    
    func popToRoot() {
        pushedScenes.removeLast(pushedScenes.count)
    }
}

extension NavigationRouter: NavigationPushing {
    public func push<T>(_ coordinator: SwiftUICoordinator<T>) -> AnyPublisher<T, Never> {
        let adapter = coordinator.asNavigationScene()
        
        coordinator.onFinish
            .map { _ in }
            .merge(with: coordinator.onCancel)
            .first()
            .sink { [weak self, unowned adapter] in
                print("Finished", adapter.id, "Count:", self!.pushedScenes.count)
                adapter.presentable.dismiss()
                self?.pop()
            }
            .store(in: &cancellables)
        
        push(adapter)
        
        return coordinator.onFinish.eraseToAnyPublisher()
    }
}
