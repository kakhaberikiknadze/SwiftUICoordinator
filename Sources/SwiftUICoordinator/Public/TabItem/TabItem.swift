//
//  TabItem.swift
//  
//
//  Created by Kakhaberi Kiknadze on 28.09.22.
//

/// Tab item to be used inside tab view.
public struct TabItem: Hashable {
    /// Tab title.
    let title: String
    
    /// Tab icon. Can be either local or remote.
    /// Local one also supports system icons.
    let image: ImageSource
    
    /// Badge count to be shown on a tab item.
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
    /// Creates a `TabItem` with no title, image and badge.
    static var empty: Self {
        .init(title: "", image: .local(.normal("")))
    }
}
