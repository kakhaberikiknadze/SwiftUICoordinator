//
//  CustomModalModifier.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct CustomModalModifier<Destination: View>: ViewModifier {
    @Environment(\.customTransitionerInteractor) var interactor
    private let destination: () -> Destination
    private let transition: () -> AnyTransition
    @Binding var isPresented: Bool
    
    init(
        isPresented: Binding<Bool>,
        destination: @escaping () -> Destination,
        transition: @escaping () -> AnyTransition
    ) {
        self.destination = destination
        self.transition = transition
        _isPresented = isPresented
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented, perform: handlePresentation)
    }

    private func handlePresentation(_ isPresented: Bool) {
        if isPresented {
            interactor.present(destination: destination(), transition: transition())
        } else {
            interactor.dismiss()
        }
    }
}

extension View {
    func customModal<Content: View>(
        isPresented: Binding<Bool>,
        transition: @escaping @autoclosure () -> AnyTransition,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            CustomModalModifier(
                isPresented: isPresented,
                destination: content,
                transition: transition
            )
        )
    }
}
