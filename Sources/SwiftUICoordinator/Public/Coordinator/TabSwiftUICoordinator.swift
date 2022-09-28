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
        mode: CoordinatorMode,
        tabs: [SwiftUICoordinator<Void>] = []
    ) {
        self.selection = tabs.first?.id ?? ""
        self.tabs = tabs.map(SwiftUICoordinatorTabSceneAdapter.init)
        super.init(id: id, mode: mode)
    }
    
    open override func createScene() -> AnyView {
        TabCoordinatorView(coordinator: self).erased()
    }
    
    public func selectTab(withId id: String) {
        if let newSelection = tabs.first(where: { $0.id == id })?.id {
            selection = newSelection
        }
    }
    
    public func setTabs(_ tabs: [SwiftUICoordinator<Void>]) {
        self.tabs = tabs.map(SwiftUICoordinatorTabSceneAdapter.init)
    }
}

extension TabSwiftUICoordinator: TabCoordinating {}

private final class SwiftUICoordinatorTabSceneAdapter<T>: TabSceneProviding {
    let id: String
    private let _scene: AnyView
    /// A scene ready to be presented inside `TabView`
    public var scene: AnyView { _scene }
    let tabItem: TabItem
    
    init(coordinator: SwiftUICoordinator<T>) {
        id = coordinator.id
        _scene = coordinator.start().scene
        tabItem = coordinator.tabItem
    }
}
