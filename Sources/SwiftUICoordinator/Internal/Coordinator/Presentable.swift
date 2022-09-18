//
//  Presentable.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

protocol Presentable {
    var scene: AnyView { get }
    var presentationStyle: ModalPresentationStyle { get }
    func cancel()
    func dismiss()
}
