//
//  AnyNavigationScene.swift
//  
//
//  Created by Kakhaberi Kiknadze on 18.09.22.
//

import SwiftUI

typealias NavigationScene = SceneProviding & NavigationRouterChildable & Hashable

final class AnyNavigationScene: NavigationScene {
    let presentable: PresentationContext
    let id: String
    var scene: AnyView { presentable.scene }
    
    private let navigationRouterChildable: NavigationRouterChildable
    
    init(
        id: String,
        presentable: PresentationContext,
        navigationRouterChildable: NavigationRouterChildable
    ) {
        self.id = id
        self.presentable = presentable
        self.navigationRouterChildable = navigationRouterChildable
    }
    
    deinit {
        print(String(describing: Self.self), id, "Deinitialised!")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AnyNavigationScene, rhs: AnyNavigationScene) -> Bool {
        lhs.id == rhs.id
    }
    
    func setNavigationRouter<R>(_ router: R) where R: NavigationPushing {
        navigationRouterChildable.setNavigationRouter(router)
    }
}

extension SwiftUICoordinator {
    func asNavigationScene() -> some AnyNavigationScene {
        .init(
            id: id,
            presentable: CoordinatorView(
                coordinator: self,
                content: { [weak self] in self?.scene }
            ),
            navigationRouterChildable: self
        )
    }
}
