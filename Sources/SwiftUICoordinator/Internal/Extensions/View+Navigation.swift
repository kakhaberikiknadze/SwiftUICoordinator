//
//  View+Navigation.swift
//  
//
//  Created by Kakhaberi Kiknadze on 14.09.22.
//

//import SwiftUI
//
//extension View {
//    func performNavigation<Destination: View>(
//        @ViewBuilder destination: () -> Destination?,
//        onDismiss: (() -> Void)?
//    ) -> some View {
//        let view = destination()
//        let isActive = Binding(
//            get: { view != nil },
//            set: { value in
//                if !value {
//                    onDismiss?()
//                }
//            }
//        )
//        return overlay(
//            NavigationLink(
//                destination: view,
//                isActive: isActive,
//                label: { EmptyView() }
//            )
//        )
//    }
//}
//
//extension View {
//    @ViewBuilder
//    func performNavigation(
//        presentable: Presentable?
//    ) -> some View {
//        if let presentable = presentable,
//           case .push = presentable.presentationStyle {
//            performNavigation(
//                destination: { presentable.scene },
//                onDismiss: presentable.cancel
//            )
//        } else {
//            self
//        }
//    }
//}
