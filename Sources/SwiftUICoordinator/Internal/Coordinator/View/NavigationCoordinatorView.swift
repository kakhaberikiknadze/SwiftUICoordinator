//
//  NavigationCoordinatorView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct NavigationCoordinatorView<R: NavigationRouting, Content: View>: View, PresentationContext {
    @Environment(\.dismiss) var dismissAction
    
    var scene: AnyView { .init(self) }
    var presentationStyle: ModalPresentationStyle
    private let cancelAction: () -> Void
    private let content: () -> Content
    
    @ObservedObject private var router: R
    
    init(
        router: R,
        presentationStyle: ModalPresentationStyle,
        onCancel: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.router = router
        self.presentationStyle = presentationStyle
        self.cancelAction = onCancel
        self.content = content
    }
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            content()
                .navigationDestination(for: NavigationDestinationIdentifier.self) { identifier in
                    router.scene(for: identifier.rawValue)
                }
        }
        .onChange(of: router.navigationPath.count) { newValue in
            print("Presented scenes count", newValue)
        }
    }
    
    func cancel() {
        cancelAction()
    }
    
    func dismiss() {
        dismissAction()
    }
}
