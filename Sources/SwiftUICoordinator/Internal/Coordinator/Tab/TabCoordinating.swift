//
//  TabCoordinating.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

protocol TabCoordinating: Coordinating {
    var selection: String { get set }
    var tabs: [any TabSceneProviding] { get }
}
