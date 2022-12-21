//
//  NavigationRouting.swift
//  
//
//  Created by Kakhaberi Kiknadze on 24.09.22.
//

import SwiftUI

protocol NavigationRouting: ObservableObject {
    var navigationPath: NavigationPath { get set }
    func scene(for id: String) -> AnyView?
}

public enum SplitNavigationOptions {
    case doubleColumn
    case tripleColumn
}

protocol SplitNavigationRouting: ObservableObject {
    var options: SplitNavigationOptions { get }
    var columnVisibility: NavigationSplitViewVisibility { get set }
    
    var contentID: NavigationDestinationIdentifier? { get set }
    var detailID: NavigationDestinationIdentifier? { get set }
    
    func sceneForContent() -> AnyView?
    func sceneForDetail() -> AnyView?
}

enum SplitCaller: Hashable {
    case sidebar
    case content
}
