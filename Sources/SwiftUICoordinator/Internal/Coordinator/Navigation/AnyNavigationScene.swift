//
//  AnyNavigationScene.swift
//  
//
//  Created by Kakhaberi Kiknadze on 18.09.22.
//

import SwiftUI

typealias NavigationScene = SceneProviding & CancellableScene

final class AnyNavigationScene: NavigationScene {
    // MARK: - Properties
    
    let presentable: PresentationContext
    let id: String
    var scene: AnyView { presentable.scene }
    let cancelAction: () -> Void
    
    // MARK: - Init
    
    init(
        id: String,
        presentable: PresentationContext,
        cancel: @escaping () -> Void
    ) {
        self.id = id
        self.presentable = presentable
        cancelAction = cancel
    }
    
    deinit {
        print(String(describing: Self.self), id, "Deinitialised!")
    }
    
    // MARK: - CancellableScene
    
    func cancel() {
        cancelAction()
    }
}

// MARK: - SwiftUICoordinator + AnyNavigationScene

extension SwiftUICoordinator {
    func asNavigationScene() -> some AnyNavigationScene {
        .init(
            id: id,
            presentable: CoordinatorView(
                coordinator: self,
                content: { [weak self] in self?.scene }
            ),
            cancel: cancel
        )
    }
}
