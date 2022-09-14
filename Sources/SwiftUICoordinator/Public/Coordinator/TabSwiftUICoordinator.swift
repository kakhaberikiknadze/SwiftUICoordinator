//
//  TabSwiftUICoordinator.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

open class TabSwiftUICoordinator<CoordinationResult>: SwiftUICoordinator<CoordinationResult> {
    @Published var selection: String
    public var tabs: [any TabSceneProviding]
    
    public init(
        id: String,
        mode: CoordinatorMode,
        presentationStyle: PresentationStyle,
        tabs: [any TabSceneProviding] = []
    ) {
        self.selection = tabs.first?.id ?? ""
        self.tabs = tabs
        super.init(id: id, mode: mode, presentationStyle: presentationStyle)
    }
    
    open override func createScene() -> AnyView {
        TabCoordinatorView(coordinator: self).erased()
    }
    
    public func selectTab(withId id: String) {
        if let newSelection = tabs.first(where: { $0.id == id })?.id {
            selection = newSelection
        }
    }
}

extension TabSwiftUICoordinator: TabCoordinating {}

