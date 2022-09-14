//
//  TabSceneProviding.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

public protocol TabSceneProviding {
    var id: String { get }
    var tabScene: AnyView { get }
}
