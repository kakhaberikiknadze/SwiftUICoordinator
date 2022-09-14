//
//  NavigationCoordinatorView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct NavigationCoordinatorView<C: Coordinating, Content: View>: View, Presentable {
    @ObservedObject private var coordinator: C
    public var presentationStyle: PresentationStyle { coordinator.presentationStyle }
    public var scene: AnyView { .init(self) }
    
    private let content: () -> Content
    
    private var performNavigation: Bool {
        guard case .push = coordinator.presentable?.presentationStyle else { return false }
        return true
    }
    
    init(
        coordinator: C,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.coordinator = coordinator
        self.content = content
    }
    
    var body: some View {
        NavigationView {
            content()
                .performNavigation(
                    destination: { coordinator.presentable?.scene },
                    isActive: .init(
                        get: { performNavigation },
                        set: { newValue in
                            guard !newValue else { return }
                            coordinator.presentable?.cancel()
                        }
                    )
                )
        }
    }

    func cancel() {
        coordinator.cancel()
    }
}

