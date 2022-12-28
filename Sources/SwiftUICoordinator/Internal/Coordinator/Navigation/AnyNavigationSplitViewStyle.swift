//
//  AnyNavigationSplitViewStyle.swift
//  
//
//  Created by Kakhaberi Kiknadze on 28.12.22.
//

import SwiftUI

struct AnyNavigationSplitViewStyle: NavigationSplitViewStyle {
    private let closure: (Configuration) -> any View
    
    init(
        _ closure: @escaping (Configuration) -> some View
    ) {
        self.closure = closure
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        closure(configuration).erased()
    }
}

extension NavigationSplitViewStyle {
    func eraseToAnySplitViewStyle() -> AnyNavigationSplitViewStyle {
        .init(makeBody)
    }
}
