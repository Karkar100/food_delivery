//
//  NetworkService.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 13.10.2022.
//

import Foundation
import UIKit

protocol NetworkServiceProtocol {
    func requestCoffeeList(urlString: String) async -> Result<[CoffeeModel]?, HTTPError>
    //func requestImage(from text: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    func requestImage(from text: String) async -> Result<Data?, HTTPError>
}

class NetworkService: NetworkServiceProtocol {
    func requestCoffeeList(urlString: String) async -> Result<[CoffeeModel]?, HTTPError> {
        await withCheckedContinuation{ continuation in
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                continuation.resume(returning: .failure(HTTPError.transportError(error)))
                return
            }
            let resp = response as! HTTPURLResponse
            let status = resp.statusCode
            guard (200...299).contains(status) else {
                continuation.resume(returning: .failure(HTTPError.httpError(status)))
                return
            }
            let correctResponse: [CoffeeModel]? = try? JSONDecoder().decode([CoffeeModel].self, from: data!)
            continuation.resume(returning: .success(correctResponse))
        }.resume()
        }
    }
    
    func requestImage(from text: String) async -> Result<Data?, HTTPError>{
        await withCheckedContinuation{ continuation in
            guard let photoUrl = URL(string: text) else { return }
            let request = URLRequest(url: photoUrl)
            URLSession.shared.dataTask(with: request){ data, response, error in
                if let error = error {
                    continuation.resume(returning: .failure(HTTPError.transportError(error)))
                    return
                }
                let resp = response as! HTTPURLResponse
                let status = resp.statusCode
                guard (200...299).contains(status) else {
                    continuation.resume(returning: .failure(HTTPError.httpError(status)))
                    return
                }
                let correctResponse: Data? = data
                continuation.resume(returning: .success(correctResponse))
            }.resume()
        }
    }
    
}
