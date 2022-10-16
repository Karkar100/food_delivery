//
//  ProfilePresenter.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 15.10.2022.
//

import Foundation

protocol ProfileViewProtocol: class {
    
}

protocol ProfilePresenterProtocol: class {
    init(view: ProfileViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol)
}

class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewProtocol?
    let networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
    required init(view: ProfileViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
    }
}
