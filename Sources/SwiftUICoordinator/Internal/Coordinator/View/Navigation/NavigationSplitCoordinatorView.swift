//
//  NavigationSplitCoordinatorView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 18.12.22.
//

import SwiftUI

struct NavigationSplitCoordinatorView<
    Router: SplitNavigationRouting,
    Context: SplitNavigationContext,
    Sidebar: View
>: View, PresentationContext {
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismissAction
    
    // MARK: - Properties
    
    var scene: AnyView { .init(self) }
    var presentationStyle: ModalPresentationStyle
    private let cancelAction: () -> Void
    private let sidebar: () -> Sidebar
    
    @ObservedObject private var router: Router
    @ObservedObject private var context: Context
    
    var columnVisibility: Binding<NavigationSplitViewVisibility> {
        .init(
            get: { context.columnVisibility },
            set: { context.columnVisibility = $0 }
        )
    }
    
    // MARK: - Init
    
    init(
        router: Router,
        context: Context,
        presentationStyle: ModalPresentationStyle,
        onCancel: @escaping () -> Void,
        @ViewBuilder sidebar: @escaping () -> Sidebar
    ) {
        self.presentationStyle = presentationStyle
        self.router = router
        self.context = context
        cancelAction = onCancel
        self.sidebar = sidebar
    }
    
    // MARK: - Body
    
    var body: some View {
        switch context.splitType {
        case let .doubleColumn(columnWidth):
            renderDoubleColumnNavigation(columnWidth)
        case let .tripleColumn(columnWidth):
            renderTripleColumnNavigation(columnWidth)
        }
    }
    
    // MARK: - Content
    
    func renderDoubleColumnNavigation(
        _ columnWidth: DoubleColumnWidth
    ) -> some View {
        NavigationSplitView(columnVisibility: columnVisibility) {
            _sidebar(columnWidth: columnWidth.sidebar)
        } detail: {
            router.detailScene?
                .columnWidth(using: columnWidth.detail)
        }
        .navigationSplitViewStyle(context.splitStyle)
    }
        
    func renderTripleColumnNavigation(
        _ columnWidth: TripleColumnWidth
    ) -> some View {
        NavigationSplitView(columnVisibility: columnVisibility) {
            _sidebar(columnWidth: columnWidth.sidebar)
        } content: {
            _content(columnWidth: columnWidth.supplementary)
        } detail: {
            router.detailScene?
                .columnWidth(using: columnWidth.detail)
        }
        .navigationSplitViewStyle(context.splitStyle)
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
    @ViewBuilder func _sidebar(
        columnWidth: SplitNavigationColumnWidth
    ) -> some View {
        ZStack {
            List(selection: fakeListBinding) {}
            sidebar()
        }
        .columnWidth(using: columnWidth)
    }
    
    @ViewBuilder func _content(
        columnWidth: SplitNavigationColumnWidth
    ) -> some View {
        ZStack {
            List(selection: detailID) {}
            router.supplementaryScene
        }
        .columnWidth(using: columnWidth)
    }
    
    var fakeListBinding: Binding<NavigationDestinationIdentifier?> {
        switch context.splitType {
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

// MARK: - Column width

private struct SplitColumnWidthModifier: ViewModifier {
    let columnType: SplitNavigationColumnWidth
    
    func body(content: Content) -> some View {
        switch columnType {
        case .automatic:
            content
        case let .fixed(value):
            content
                .navigationSplitViewColumnWidth(value)
        case let .dynamic(min, ideal, max):
            content
                .navigationSplitViewColumnWidth(min: min, ideal: ideal, max: max)
        }
    }
}

private extension View {
    @ViewBuilder func columnWidth(using columnType: SplitNavigationColumnWidth) -> some View {
        modifier(SplitColumnWidthModifier(columnType: columnType))
    }
}
