//
//  NavigationPushing.swift
//  
//
//  Created by Kakhaberi Kiknadze on 24.09.22.
//

import Combine

public protocol NavigationPushing: AnyObject {
    func push<T>(_ coordinator: SwiftUICoordinator<T>) -> AnyPublisher<T, Never>
}
