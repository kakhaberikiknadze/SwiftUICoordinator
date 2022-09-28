//
//  Image+LocalImage.swift
//  
//
//  Created by Kakhaberi Kiknadze on 28.09.22.
//

import SwiftUI

extension Image {
    public init(with image: LocalImage) {
        switch image {
        case .normal(let imageName):
            self.init(imageName)
        case .system(let imageName):
            self.init(systemName: imageName)
        }
    }
}
