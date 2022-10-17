//
//  CustomTransitionerView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

// MARK: - View

struct CustomTransitionerView<Content: View>: View {
    @StateObject private var context = CustomTransitionerContext()
    private let content: () -> Content
    
    init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }
    
    var body: some View {
        ZStack {
            content()
                .environment(\.customTransitionerInteractor, context)
            
            if let presentable = context.presentable {
                presentable.scene
                    .customTransition()
                    .zIndex(1)
                    .transition(presentable.transition)
            }
        }
    }
}

// MARK: - Environment

protocol CustomTransitionerInteractable: ObservableObject {
    func present<D: View>(destination: D, transition: AnyTransition)
    func dismiss()
}

struct CustomTransitionerInteractorEnvironmentKey: EnvironmentKey {
    static var defaultValue: any CustomTransitionerInteractable = CustomTransitionerContext()
}

extension EnvironmentValues {
    var customTransitionerInteractor: any CustomTransitionerInteractable {
        get { self[CustomTransitionerInteractorEnvironmentKey.self] }
        set { self[CustomTransitionerInteractorEnvironmentKey.self] = newValue }
    }
}

// MARK: - Interactor

private final class CustomTransitionerContext: ObservableObject {
    typealias Presentable = (scene: AnyView, transition: AnyTransition)
    @Published private(set) var presentable: Presentable?
}

extension CustomTransitionerContext: CustomTransitionerInteractable {
    func dismiss() {
        guard presentable != nil else { return }
        withAnimation {
            presentable = nil
        }
    }
    
    func present<D: View>(destination: D, transition: AnyTransition) {
        withAnimation {
            presentable = (destination.erased(), transition)
        }
    }
}
