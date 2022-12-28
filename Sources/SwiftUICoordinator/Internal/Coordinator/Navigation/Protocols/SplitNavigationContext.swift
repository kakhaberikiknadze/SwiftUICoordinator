//
//  SplitNavigationContext.swift
//  
//
//  Created by Kakhaberi Kiknadze on 28.12.22.
//

import SwiftUI

protocol SplitNavigationContext: ObservableObject {
    var splitType: SplitNavigationType { get }
    var splitStyle: AnyNavigationSplitViewStyle { get }
    var columnVisibility: NavigationSplitViewVisibility { get set }
}
