//
//  HTTPError.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 13.10.2022.
//

public enum HTTPError: Error{
    case transportError(Error)
    case httpError(Int)
}
