//
//  ImageSource.swift
//  
//
//  Created by Kakhaberi Kiknadze on 28.09.22.
//

import Foundation

public enum ImageSource: Hashable {
    case local(LocalImage)
    case remote(URL)
}
