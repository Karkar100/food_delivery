//
//  CartPresenter.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 15.10.2022.
//

import Foundation

protocol CartViewProtocol: class {
    
}

protocol CartPresenterProtocol: class {
    init(view: CartViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol)
}

class CartPresenter: CartPresenterProtocol {
    var view: CartViewProtocol?
    let networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
    required init(view: CartViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
    }
}
