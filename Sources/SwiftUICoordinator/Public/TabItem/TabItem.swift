//
//  TabItem.swift
//  
//
//  Created by Kakhaberi Kiknadze on 28.09.22.
//

public struct TabItem: Hashable {
    let title: String
    let image: ImageSource
    let badgeCount: Int
    
    public init(
        title: String,
        image: ImageSource,
        badgeCount: Int = 0
    ) {
        self.title = title
        self.image = image
        self.badgeCount = badgeCount
    }
}

public extension TabItem {
    static var empty: Self {
        .init(title: "", image: .local(.normal("")))
    }
}
