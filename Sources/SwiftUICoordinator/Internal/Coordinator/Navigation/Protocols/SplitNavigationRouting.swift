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
    
    // Needed as a workaround for stacked style
    var supplementaryID: NavigationDestinationIdentifier? { get set }
    var detailID: NavigationDestinationIdentifier? { get set }
    
    var supplementaryScene: AnyView? { get }
    var detailScene: AnyView? { get }
}
