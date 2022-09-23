//
//  NavigationRouter.swift
//  
//
//  Created by Kakhaberi Kiknadze on 18.09.22.
//

import SwiftUI
import Combine

final class NavigationRouter: ObservableObject {
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    public let id: String
    
    @Published var presentedScenes: NavigationPath
    let rootSceneProvider: any SceneProviding
    
    // MARK: - Init
    
    public init<S: NavigationScene>(
        id: String = UUID().uuidString,
        rootSceneProvider: S,
        pushedSceneProviders: [S] = []
    ) {
        print("|\n--NavigationRouter", id, "Initialised!")
        self.id = id
        self.rootSceneProvider = rootSceneProvider
        presentedScenes = .init(pushedSceneProviders)
        
        rootSceneProvider.setNavigationRouter(self)
        pushedSceneProviders.forEach { $0.setNavigationRouter(self) }
    }
    
    deinit {
        print(String(describing: Self.self) + id, "Deinitialised!")
    }
    
    // MARK: - Methods
    
    func push<S: NavigationScene>(_ sceneProvider: S) {
        presentedScenes.append(sceneProvider)
        sceneProvider.setNavigationRouter(self)
    }
    
    func pop() {
        presentedScenes.removeLast()
    }
    
    func popToRoot() {
        presentedScenes.removeLast(presentedScenes.count)
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
                print("Finished", adapter.id, "Count:", self!.presentedScenes.count)
                adapter.presentable.dismiss()
                self?.pop()
            }
            .store(in: &cancellables)
        
        push(adapter)
        
        return coordinator.onFinish.eraseToAnyPublisher()
    }
}
