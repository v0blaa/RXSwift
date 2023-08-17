//
//  NetworkService.swift
//  RXSwift
//

import Foundation
import RxSwift
import RxRelay

protocol NetworkServiceProtocol {
}

final class NetworkService: NetworkServiceProtocol {
    
    private var currentCatTask: URLSessionDataTask?
    private var currentDogTask: URLSessionDataTask?
    
    func calcelCurrentRequests() {
        currentCatTask?.cancel()
        currentDogTask?.cancel()
    }
    
    func sendCatRequest(request: URLRequest) -> Single<[Animal]> {
        return Single<[Animal]>.create { [weak self] single in
            let defaultSession = URLSession(configuration: .default)
            
            self?.currentCatTask = defaultSession.dataTask(
                with: request
            ) { data, response, error in
                if let error = error {
                    single(.failure(error))
                } else if let data = data {
                    if let result = try? JSONDecoder().decode([Animal].self, from: data) {
                        single(.success(result))
                    } else {
                        single(.failure(NetworkError.cantParce))
                    }
                }
            }
            
            self?.currentCatTask?.resume()
            
            return Disposables.create { [weak self] in
                self?.currentCatTask?.cancel()
            }
        }
    }
    
    func sendDogRequest(request: URLRequest) -> Single<[Animal]> {
        return Single<[Animal]>.create { [weak self] single in
            let defaultSession = URLSession(configuration: .default)
            
            self?.currentDogTask = defaultSession.dataTask(
                with: request
            ) { data, response, error in
                if let error = error {
                    single(.failure(error))
                } else if let data = data {
                    if let result = try? JSONDecoder().decode([Animal].self, from: data) {
                        single(.success(result))
                    } else {
                        single(.failure(NetworkError.cantParce))
                    }
                }
            }
            
            self?.currentDogTask?.resume()
            
            return Disposables.create { [weak self] in
                self?.currentDogTask?.cancel()
            }
        }
    }
}
    
enum NetworkError: Error {
    case noResponse
    case failedResponse
    case cantParce
}
