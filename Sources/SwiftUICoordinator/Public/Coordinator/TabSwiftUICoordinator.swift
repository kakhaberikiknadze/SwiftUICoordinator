//
//  TabSwiftUICoordinator.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

open class TabSwiftUICoordinator<CoordinationResult>: SwiftUICoordinator<CoordinationResult> {
    @Published var selection: String
    private(set) var tabs: [any TabSceneProviding]
    
    public init(
        id: String,
        tabs: [SwiftUICoordinator<Void>] = []
    ) {
        self.selection = tabs.first?.id ?? ""
        self.tabs = tabs
        super.init(id: id)
    }
    
    public init<T: TabSceneProviding>(
        id: String,
        tabs: [T]
    ) {
        self.selection = tabs.first?.id ?? ""
        self.tabs = tabs
        super.init(id: id)
    }
    
    override func start() -> PresentationContext {
        TabCoordinatorView(coordinator: self)
    }
    
    public func selectTab(withId id: String) {
        if let newSelection = tabs.first(where: { $0.id == id })?.id {
            selection = newSelection
        }
    }
    
    public func setTabs<T: TabSceneProviding>(_ tabs: [T]) {
        self.tabs = tabs
    }
}

extension TabSwiftUICoordinator: TabCoordinating {}

extension SwiftUICoordinator: TabSceneProviding {
    public var tabScene: AnyView { start().scene }
}
