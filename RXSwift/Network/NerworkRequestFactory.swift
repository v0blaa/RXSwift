//
//  NetworkRequestFactory.swift
//  RXSwift
//

import Foundation

protocol NetworkRequestFactoryProtocol {
    
}

final class NetworkRequestFactory: NetworkRequestFactoryProtocol {
    static let apiKey = "I//IsgmpQrbjs0vapG6ffg==3lc6InAZejkjUGbe"
    static let baseURL = URL(string: "https://api.api-ninjas.com/v1/")!
    
    func getCatsRequest(name: String?) -> URLRequest? {
        let requestURL = NetworkRequestFactory.baseURL.appendingPathComponent("cats")
        var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "name", value: name)
        ]
        
        guard let url = urlComponents?.url else {
            assertionFailure("Something has gone wrong and URL could not be constructed!")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue(NetworkRequestFactory.apiKey, forHTTPHeaderField: "X-Api-Key")
        return request
    }
    
    func getDogsRequest(name: String) -> URLRequest? {
        let requestURL = NetworkRequestFactory.baseURL.appendingPathComponent("dogs")
        var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "name", value: name)
        ]
        
        guard let url = urlComponents?.url else {
            assertionFailure("Something has gone wrong and URL could not be constructed!")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue(NetworkRequestFactory.apiKey, forHTTPHeaderField: "X-Api-Key")
        return request
    }
    
}
