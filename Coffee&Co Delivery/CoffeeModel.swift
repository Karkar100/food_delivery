//
//  CoffeeModel.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 13.10.2022.
//

struct CoffeeArrayModel: Codable {
    var hot: [CoffeeModel]
    var iced: [CoffeeModel]
}


struct CoffeeModel: Codable{
    var title: String
    var description: String
    var ingredients: [String]
    var image: String
    var id: Int
}
