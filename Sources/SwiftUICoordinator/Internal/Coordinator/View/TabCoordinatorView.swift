//
//  TabCoordinatorView.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct TabCoordinatorView<C: TabCoordinating>: View, Presentable {
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismissAction
    @ObservedObject private var coordinator: C
    public var presentationStyle: ModalPresentationStyle { coordinator.presentationStyle }
    var scene: AnyView { .init(self) }
    
    @State private var selection = 0
    
    init(coordinator: C) {
        self.coordinator = coordinator
    }
    
    var body: some View {
        TabView(selection: $coordinator.selection) {
            ForEach(coordinator.tabs, id: \.id) { tab in
                tab.tabScene
            }
        }
        .onChange(of: coordinator.selection, perform: { newValue in
            print("Selected tab with ID:", newValue)
        })
        .onChange(of: isPresented) { newValue in
            if !newValue {
                cancel()
            }
        }
    }
    
    func cancel() {
        coordinator.cancel()
    }
    
    func dismiss() {
        dismissAction()
    }
}

