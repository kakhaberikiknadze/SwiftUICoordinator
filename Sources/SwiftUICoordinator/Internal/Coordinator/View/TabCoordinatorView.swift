//
//  TabCoordinatorView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct TabCoordinatorView<C: TabCoordinating>: View, PresentationContext {
    @Environment(\.dismiss) var dismissAction
    @ObservedObject private var coordinator: C
    public var presentationStyle: ModalPresentationStyle { coordinator.presentationStyle }
    var scene: AnyView { .init(self) }
    
    init(coordinator: C) {
        self.coordinator = coordinator
    }
    
    var body: some View {
        TabView(selection: $coordinator.selection) {
            ForEach(coordinator.tabs, id: \.id) { tab in
                tab.scene
                    .tabItem {
                        Label {
                            Text(tab.tabItem.title)
                        } icon: {
                            getIcon(using: tab.tabItem.image)
                        }
                    }
                    .tag(tab.id)
                    .badge(tab.tabItem.badgeCount)
            }
        }
        .onChange(of: coordinator.selection, perform: { newValue in
            Log.trace(category: String(describing: Self.self), message: "Selected tab", metadata: ["id": newValue])
        })
    }
    
    @ViewBuilder private func getIcon(
        using imageSource: ImageSource
    ) -> some View {
        switch imageSource {
        case let .local(localImage):
            Image(with: localImage)
        case let .remote(url):
            AsyncImage(url: url)
        }
    }
    
    func cancel() {
        coordinator.cancel()
    }
    
    func dismiss() {
        dismissAction()
    }
}

