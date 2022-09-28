//
//  SceneProviding.swift
//  
//
//  Created by Kakhaberi Kiknadze on 18.09.22.
//

import SwiftUI

protocol SceneProviding: AnyObject {
    var id: String { get }
    var scene: AnyView { get }
}
