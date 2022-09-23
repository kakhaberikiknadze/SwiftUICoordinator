//
//  Coordinating.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

protocol Coordinating: ObservableObject {
    var presentable: PresentationContext? { get }
    var presentationStyle: ModalPresentationStyle { get }
    func cancel()
}

