//
//  SplitNavigationRouting.swift
//  
//
//  Created by Kakhaberi Kiknadze on 26.12.22.
//

import SwiftUI

protocol SplitNavigationRouting: ObservableObject {
    var splitType: SplitNavigationType { get }
    var columnVisibility: NavigationSplitViewVisibility { get set }
    
    ///
    var supplementaryID: NavigationDestinationIdentifier? { get set }
    var detailID: NavigationDestinationIdentifier? { get set }
    
    func sceneForSupplementary() -> AnyView?
    func sceneForDetail() -> AnyView?
}
