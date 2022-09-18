//
//  NavigationCoordinatorView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct NavigationCoordinatorView: View {
    @ObservedObject private var router: NavigationRouter
    
    init(router: NavigationRouter) {
        self.router = router
    }
    
    var body: some View {
        NavigationStack(path: $router.presentedScenes) {
            router.rootSceneProvider.scene
                .navigationDestination(for: AnyNavigationScene.self) { context in
                    context.scene
                }
        }
        .onChange(of: router.presentedScenes.count) { newValue in
            print("Presented scenes count", newValue)
        }
    }
}
