//
//  SplitNavigationColumnWidth.swift
//  
//
//  Created by Kakhaberi Kiknadze on 27.12.22.
//

import CoreGraphics

public enum SplitNavigationColumnWidth: Hashable {
    case automatic
    case fixed(CGFloat)
    case dynamic(min: CGFloat, ideal: CGFloat, max: CGFloat)
}
