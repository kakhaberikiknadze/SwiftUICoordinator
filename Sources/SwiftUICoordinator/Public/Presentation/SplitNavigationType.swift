//
//  SplitNavigationType.swift
//  
//
//  Created by Kakhaberi Kiknadze on 26.12.22.
//

/// Type of split navigation view. Double column or triple column.
public enum SplitNavigationType: Hashable {
    case doubleColumn(DoubleColumnWidth)
    case tripleColumn(TripleColumnWidth)
}

public struct DoubleColumnWidth: Hashable {
    let sidebar: SplitNavigationColumnWidth
    let detail: SplitNavigationColumnWidth
    
    public static var automatic: Self {
        .init(sidebar: .automatic, detail: .automatic)
    }
    
    public init(
        sidebar: SplitNavigationColumnWidth,
        detail: SplitNavigationColumnWidth
    ) {
        self.sidebar = sidebar
        self.detail = detail
    }
}

public struct TripleColumnWidth: Hashable {
    let sidebar: SplitNavigationColumnWidth
    let supplementary: SplitNavigationColumnWidth
    let detail: SplitNavigationColumnWidth
    
    public static var automatic: Self {
        .init(sidebar: .automatic, supplementary: .automatic, detail: .automatic)
    }
    
    public init(
        sidebar: SplitNavigationColumnWidth,
        supplementary: SplitNavigationColumnWidth,
        detail: SplitNavigationColumnWidth
    ) {
        self.sidebar = sidebar
        self.supplementary = supplementary
        self.detail = detail
    }
}
