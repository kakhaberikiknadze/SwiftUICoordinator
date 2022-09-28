//
//  LocalImage.swift
//  
//
//  Created by Kakhaberi Kiknadze on 28.09.22.
//

public typealias ImageName = String

public enum LocalImage: Hashable {
    case normal(ImageName)
    case system(ImageName)
}
