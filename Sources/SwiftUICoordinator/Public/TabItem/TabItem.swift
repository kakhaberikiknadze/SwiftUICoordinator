//
//  TabItem.swift
//  
//
//  Created by Kakhaberi Kiknadze on 28.09.22.
//

public struct TabItem: Hashable {
    let title: String
    let image: ImageSource
    
    public init(title: String, image: ImageSource) {
        self.title = title
        self.image = image
    }
}

public extension TabItem {
    static var empty: Self {
        .init(title: "", image: .local(.normal("")))
    }
}
