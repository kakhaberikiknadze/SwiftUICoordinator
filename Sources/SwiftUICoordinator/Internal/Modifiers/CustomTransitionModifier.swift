//
//  CustomTransitionModifier.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct CustomTransitionModifier: ViewModifier {
    func body(content: Content) -> some View {
        CustomTransitionerView { content }
    }
}

extension View {
    /// Wraps the view inside `CustomTransitionerView` to enable
    /// custom transitioning on root scene.
    ///
    /// Should be called after `customModal(isPresented: content:)
    /// Otherwise the modifier won't have an access to CustomTransitionerView's interactor..
    ///
    ///     var body: some View {
    ///         Text("My View")
    ///             .customModal(
    ///                 isPresented: $isPresented,
    ///                 content: { Text("Presented View") }
    ///             )
    ///             .customTransition()
    ///     }
    ///
    /// - Returns: `CustomTransitionModifier`
    func customTransition() -> some View {
        modifier(CustomTransitionModifier())
    }
}

