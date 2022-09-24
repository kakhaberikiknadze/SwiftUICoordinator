//
//  NavigationCoordinatorView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct NavigationCoordinatorView<R: NavigationRouting>: View, PresentationContext {
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismissAction
    
    var scene: AnyView { .init(self) }
    var presentationStyle: ModalPresentationStyle
    private let cancelAction: () -> Void
    
    @ObservedObject private var router: R
    
    init(
        router: R,
        presentationStyle: ModalPresentationStyle,
        onCancel: @escaping () -> Void
    ) {
        self.router = router
        self.presentationStyle = presentationStyle
        self.cancelAction = onCancel
    }
    
    var body: some View {
        NavigationStack(path: $router.pushedScenes) {
            router.rootScene
                .navigationDestination(for: AnyNavigationScene.self) { context in
                    context.scene
                }
        }
        .onChange(of: router.pushedScenes.count) { newValue in
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
