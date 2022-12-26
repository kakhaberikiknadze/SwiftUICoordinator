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
