//
//  NavigationRouting.swift
//  
//
//  Created by Kakhaberi Kiknadze on 24.09.22.
//

import SwiftUI

protocol NavigationRouting: ObservableObject {
    var rootScene: AnyView { get }
    var pushedScenes: NavigationPath { get set }
}
