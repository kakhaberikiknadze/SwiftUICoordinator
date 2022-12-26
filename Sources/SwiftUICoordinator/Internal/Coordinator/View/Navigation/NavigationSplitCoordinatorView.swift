//
//  NavigationSplitCoordinatorView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 18.12.22.
//

import SwiftUI

struct NavigationSplitCoordinatorView<
    R: SplitNavigationRouting,
    Sidebar: View
>: View, PresentationContext {
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismissAction
    
    // MARK: - Properties
    
    var scene: AnyView { .init(self) }
    var presentationStyle: ModalPresentationStyle
    private let cancelAction: () -> Void
    private let sidebar: () -> Sidebar
    
    @ObservedObject private var router: R
    
    var columnVisibility: Binding<NavigationSplitViewVisibility> {
        .init(
            get: { router.columnVisibility },
            set: { router.columnVisibility = $0 }
        )
    }
    
    // MARK: - Init
    
    init(
        router: R,
        presentationStyle: ModalPresentationStyle,
        onCancel: @escaping () -> Void,
        @ViewBuilder sidebar: @escaping () -> Sidebar
    ) {
        self.presentationStyle = presentationStyle
        self.router = router
        cancelAction = onCancel
        self.sidebar = sidebar
    }
    
    // MARK: - Body
    
    var body: some View {
        switch router.splitType {
        case .doubleColumn:
            renderDoubleColumnNavigation()
        case .tripleColumn:
            renderTripleColumnNavigation()
        }
    }
    
    // MARK: - Content
    
    func renderDoubleColumnNavigation() -> some View {
        NavigationSplitView(
            columnVisibility: columnVisibility,
            sidebar: _sidebar,
            detail: router.sceneForDetail
        )
    }
        
    func renderTripleColumnNavigation() -> some View {
        NavigationSplitView(
            columnVisibility: columnVisibility,
            sidebar: _sidebar,
            content: _content,
            detail: router.sceneForDetail
        )
    }
    
    // MARK: - PresentationContext methods
    
    func cancel() {
        cancelAction()
    }
    
    func dismiss() {
        dismissAction()
    }
}

// MARK: - Fake list workaround

private extension NavigationSplitCoordinatorView {
    @ViewBuilder func _sidebar() -> some View {
        ZStack {
            List(selection: fakeListBinding) {}
            sidebar()
        }
    }
    
    @ViewBuilder func _content() -> some View {
        ZStack {
            List(selection: detailID) {}
            router.sceneForSupplementary()
        }
    }
    
    var fakeListBinding: Binding<NavigationDestinationIdentifier?> {
        switch router.splitType {
        case .doubleColumn:
            return detailID
        case .tripleColumn:
            return supplementaryID
        }
    }
    
    var supplementaryID: Binding<NavigationDestinationIdentifier?> {
        .init(
            get: {
                router.supplementaryID
            },
            set: {
                router.supplementaryID = $0
            }
        )
    }
    
    var detailID: Binding<NavigationDestinationIdentifier?> {
        .init(
            get: {
                router.detailID
            },
            set: {
                router.detailID = $0
            }
        )
    }
}
