//
//  ContactsPresenter.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 15.10.2022.
//

import Foundation

protocol ContactsViewProtocol: class {
    
}

protocol ContactsPresenterProtocol: class {
    init(view: ContactsViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol)
}

class ContactsPresenter: ContactsPresenterProtocol {
    var view: ContactsViewProtocol?
    let networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
    
    required init(view: ContactsViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
    }
}
