//
//  Router.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 13.10.2022.
//

import Foundation
import UIKit

protocol RouterBasic {
    var tabBarController: UITabBarController? { get set }
    var moduleBuilder: ModuleBuilderProtocol? { get set }
}

protocol RouterProtocol: RouterBasic {
    func initialViewControllers()
}

class Router: RouterProtocol {
    var tabBarController: UITabBarController?
    var moduleBuilder: ModuleBuilderProtocol?
    init(tabBarController: UITabBarController, moduleBuilder: ModuleBuilderProtocol) {
        self.tabBarController = tabBarController
        self.moduleBuilder = moduleBuilder
    }
    
    func initialViewControllers() {
        
        if let tabBarController = tabBarController {
            guard let coffeeListViewController = moduleBuilder?.buildCoffeeList(router: self) else { return }
            guard let contactsViewController = moduleBuilder?.buildContacts(router: self) else { return }
            guard let profileVC = moduleBuilder?.buildProfile(router: self) else { return }
            guard let cartVC = moduleBuilder?.buildCart(router: self) else { return }
            
            let coffeeIcon = UIImage(named: "food")?.withTintColor(UIColor(hex: "#C3C4C9"), renderingMode: .alwaysTemplate)
            let coffeeTabBarItem = UITabBarItem(title: "Меню", image: coffeeIcon, tag: 0)
            let contactsTabBarItem = UITabBarItem(title: "Контакты", image: UIImage(named: "pinpoint"), tag: 1)
            let profileTabBarItem = UITabBarItem(title: "Профиль", image: UIImage(named: "profile"), tag: 2)
            let cartTabBarItem = UITabBarItem(title: "Корзина", image: UIImage(named: "basket"), tag: 3)
            coffeeListViewController.tabBarItem = coffeeTabBarItem
            contactsViewController.tabBarItem = contactsTabBarItem
            profileVC.tabBarItem = profileTabBarItem
            cartVC.tabBarItem = cartTabBarItem
            UITabBar.appearance().backgroundColor = .white
            tabBarController.tabBar.tintColor = UIColor(hex: "#FD3A69")
            tabBarController.viewControllers = [coffeeListViewController, contactsViewController, profileVC, cartVC]
        }
    }
    
}
