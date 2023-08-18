//
//  NetworkService.swift
//  RXSwift
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol NetworkServiceProtocol {
}

final class NetworkService: NetworkServiceProtocol {
    
    private var animalName: Observable<String>
    lazy var catsDriver: Driver<[Animal]> = self.fetchCats()
    lazy var dogsDriver: Driver<[Animal]> = self.fetchDogs()
    
    weak var vc: ViewController?
    
    init(withNameObservable animalName: Observable<String>,
         vc: ViewController) {
        self.animalName = animalName
        self.vc = vc
    }
    
    private func fetchCats() -> Driver<[Animal]> {
        return animalName
            .filter { !$0.isEmpty }
            .subscribe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.vc?.showLoadingAnimation(true)
            })
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { text in
                URLSession.shared.rx.data(request: NetworkRequestFactory()
                    .getCatsRequest(name: text))
                .map { data in
                    if let result = try? JSONDecoder().decode([Animal].self, from: data) {
                        return result
                    } else {
                        return []
                    }
                }
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.vc?.showLoadingAnimation(false)
            })
            .asDriver(onErrorJustReturn: [])
    }
    
    private func fetchDogs() -> Driver<[Animal]> {
        return animalName
            .filter { !$0.isEmpty }
            .subscribe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.vc?.showLoadingAnimation(true)
            })
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { text in
                URLSession.shared.rx.data(request: NetworkRequestFactory()
                    .getDogsRequest(name: text))
                .map { data in
                    if let result = try? JSONDecoder().decode([Animal].self, from: data) {
                        return result
                    } else {
                        return []
                    }
                }
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.vc?.showLoadingAnimation(false)
            })
            .asDriver(onErrorJustReturn: [])
    }
}

enum NetworkError: Error {
    case noResponse
    case failedResponse
    case cantParce
}
