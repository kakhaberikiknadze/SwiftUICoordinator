//
//  PerformNavigationModifier.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

import SwiftUI

struct PerformNavigationModifier<Destination: View>: ViewModifier {
    private let destination: () -> Destination
    @Binding var isActive: Bool
    
    init(
        destination: @escaping () -> Destination,
        isActive: Binding<Bool>
    ) {
        self.destination = destination
        _isActive = isActive
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                NavigationLink(
                    destination: destination(),
                    isActive: $isActive,
                    label: { EmptyView() }
                )
            )
    }
}

extension View {
    func performNavigation<D: View>(
        destination: @escaping () -> D,
        isActive: Binding<Bool>
    ) -> some View {
        modifier(PerformNavigationModifier(destination: destination, isActive: isActive))
    }
}
