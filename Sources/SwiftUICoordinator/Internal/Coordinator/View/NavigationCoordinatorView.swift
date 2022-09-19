//
//  NavigationCoordinatorView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct NavigationCoordinatorView: View, Presentable {
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) private var dismissAction
    
    var scene: AnyView { .init(self) }
    var presentationStyle: ModalPresentationStyle
    private let cancelAction: () -> Void
    
    @ObservedObject private var router: NavigationRouter
    
    init(
        router: NavigationRouter,
        presentationStyle: ModalPresentationStyle,
        onCancel: @escaping () -> Void
    ) {
        self.router = router
        self.presentationStyle = presentationStyle
        self.cancelAction = onCancel
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
        .onChange(of: isPresented) { newValue in
            if !newValue {
                cancel()
            }
        }
    }
    
    func cancel() {
        cancelAction()
    }
    
    func dismiss() {
        dismissAction()
    }
}
