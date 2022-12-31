//
//  NavigationSplitting.swift
//  
//
//  Created by Kakhaberi Kiknadze on 26.12.22.
//

import Combine

enum SplitContext {
    case supplementary
    case detail
}

protocol NavigationSplitting: AnyObject {
    func show<T>(_ coordinator: SwiftUICoordinator<T>, context: SplitContext) -> AnyPublisher<T, Never>
}
