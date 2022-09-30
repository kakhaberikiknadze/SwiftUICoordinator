//
//  CoordinatorView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct CoordinatorView<C: Coordinating, Content: View>: View, PresentationContext {
    @Environment(\.dismiss) private var dismissAction
    @ObservedObject private var coordinator: C
    
    public var presentationStyle: ModalPresentationStyle { coordinator.presentationStyle }
    public var scene: AnyView { .init(self) }
    private let content: () -> Content
    
    init(
        coordinator: C,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.coordinator = coordinator
        self.content = content
    }
    
    var body: some View {
        content()
            .customModal(
                isPresented: .init(
                    get: {
                        showCustomModal
                    },
                    set: { newValue in
                        guard !newValue else { return }
                        coordinator.presentable?.cancel()
                    }
                ),
                transition: customTransition,
                content: { coordinator.presentable?.scene }
            )
            .sheet(
                isPresented: .init(
                    get: {
                        showSheet
                    },
                    set: { newValue in
                        guard !newValue else { return }
                        coordinator.presentable?.cancel()
                    }
                ),
                content: {
                    coordinator.presentable?.scene
                        .customTransition()
                }
            )
            .fullScreenCover(
                isPresented: .init(
                    get: {
                        showFullScreen
                    },
                    set: { newValue in
                        guard !newValue else { return }
                        coordinator.presentable?.cancel()
                    }
                ),
                content: {
                    coordinator.presentable?.scene
                        .customTransition()
                }
            )
    }

    func cancel() {
        coordinator.cancel()
    }
    
    func dismiss() {
        dismissAction()
    }
}

extension CoordinatorView {
    var showSheet: Bool {
        guard case .sheet = coordinator.presentable?.presentationStyle else { return false }
        return true
    }
    
    var showFullScreen: Bool {
        guard case .fullScreen = coordinator.presentable?.presentationStyle else { return false }
        return true
    }
    
    var showCustomModal: Bool {
        guard case .custom = coordinator.presentable?.presentationStyle else { return false }
        return true
    }
    
    var customTransition: AnyTransition {
        guard case let .custom(transition) = coordinator.presentable?.presentationStyle else {
            return .identity
        }
        return transition
    }
}

