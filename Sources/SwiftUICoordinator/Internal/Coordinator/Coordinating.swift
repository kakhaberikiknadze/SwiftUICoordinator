//
//  Coordinating.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

protocol Coordinating: ObservableObject {
    var presentable: Presentable? { get }
    var presentationStyle: PresentationStyle { get }
    func cancel()
}

