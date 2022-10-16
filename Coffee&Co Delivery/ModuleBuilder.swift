//
//  ModuleBuilder.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 13.10.2022.
//

import Foundation
import UIKit
protocol ModuleBuilderProtocol {
    func buildCoffeeList(router: RouterProtocol) -> UIViewController
    func buildContacts(router: RouterProtocol) -> UIViewController
    
    func buildProfile(router: RouterProtocol) -> UIViewController
    func buildCart(router: RouterProtocol) -> UIViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    
    func buildCoffeeList(router: RouterProtocol) -> UIViewController {
        let view = CoffeeListViewController()
        let networkService = NetworkService()
        let presenter = CoffeeListPresenter(view: view, networkService: networkService, router: router)
        view.presenter = presenter
        return view
    }
    
    func buildContacts(router: RouterProtocol) -> UIViewController {
        let view = ContactsViewController()
        let networkService = NetworkService()
        let presenter = ContactsPresenter(view: view, networkService: networkService, router: router)
        view.presenter = presenter
        return view
    }
    func buildProfile(router: RouterProtocol) -> UIViewController {
        let view = ProfileViewController()
        let networkService = NetworkService()
        let presenter = ProfilePresenter(view: view, networkService: networkService, router: router)
        view.presenter = presenter
        return view
    }
    func buildCart(router: RouterProtocol) -> UIViewController {
        let view = CartViewController()
        let networkService = NetworkService()
        let presenter = CartPresenter(view: view, networkService: networkService, router: router)
        view.presenter = presenter
        return view
    }
}
