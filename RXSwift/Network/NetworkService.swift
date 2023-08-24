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
    
    lazy var animals: Observable<[Animal]> = self.fetchAnimals()
    var errorRelay = PublishRelay<Error>()
    
    init(withNameObservable animalName: Observable<String>) {
        self.animalName = animalName
    }
    
    private func fetchAnimals() -> Observable<[Animal]> {
        return animalName
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { [weak self] text in
                if text.isEmpty {
                    return Observable<[Animal]>.just([])
                }
                let catsRequest = URLSession.shared.rx.data(request: NetworkRequestFactory.shared
                    .getAnimalsRequest(name: text, animalType: .cats))
                    .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .catch { [weak self] error in
                        self?.errorRelay.accept(error)
                        return Observable.just(Data())
                    }
                    .map { data in
                        if let result = try? JSONDecoder().decode([Animal].self, from: data) {
                            return result
                        } else {
                            self?.errorRelay.accept(NetworkError.cantParce)
                            return []
                        }
                    }
                
                let dogsRequest = URLSession.shared.rx.data(request: NetworkRequestFactory.shared
                    .getAnimalsRequest(name: text, animalType: .dogs))
                    .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .catch { [weak self] error in
                        self?.errorRelay.accept(error)
                        return Observable.just(Data())
                    }
                    .map { data in
                        if let result = try? JSONDecoder().decode([Animal].self, from: data) {
                            return result
                        } else {
                            self?.errorRelay.accept(NetworkError.cantParce)
                            return []
                        }
                    }
                
                
                return Observable<[Animal]>
                    .zip(catsRequest, dogsRequest) { (cats, dogs) in
                        cats + dogs
                    }
                    .map { (items) in
                        items.sorted(by: { (item1, item2) in
                            return item1.playfulness == item2.playfulness ? item1.name < item2.name : item1.playfulness > item2.playfulness
                        })
                    }
            }
    }
}

enum NetworkError: Error {
    case cantParce
}
