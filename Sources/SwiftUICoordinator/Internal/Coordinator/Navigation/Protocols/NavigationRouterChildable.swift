//
//  NavigationRouterChildable.swift
//  
//
//  Created by Kakhaberi Kiknadze on 18.09.22.
//

protocol NavigationRouterChildable: AnyObject {
    func setNavigationRouter<R: NavigationPushing>(_ router: R)
}
