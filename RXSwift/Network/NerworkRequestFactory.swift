//
//  NetworkRequestFactory.swift
//  RXSwift
//

import Foundation

protocol NetworkRequestFactoryProtocol {
    
}

enum AnimalType: String {
    case cats
    case dogs
}
final class NetworkRequestFactory: NetworkRequestFactoryProtocol {
    static let shared = NetworkRequestFactory()
    
    static let apiKey = "I//IsgmpQrbjs0vapG6ffg==3lc6InAZejkjUGbe"
    static let baseURL = URL(string: "https://api.api-ninjas.com/v1/")!
    
    private init() {}
    
    func getAnimalsRequest(name: String, animalType: AnimalType) -> URLRequest {
        let requestURL = NetworkRequestFactory.baseURL.appendingPathComponent(animalType.rawValue)
        var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "name", value: name)
        ]
        
        let url = urlComponents?.url
        var request = URLRequest(url: url!)
        request.setValue(NetworkRequestFactory.apiKey, forHTTPHeaderField: "X-Api-Key")
        return request
    }
}
