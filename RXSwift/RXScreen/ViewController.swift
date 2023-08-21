//
//  ViewController.swift
//  RXSwift
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class ViewController: UIViewController {
    
    let mainView = View()
    private let disposeBag = DisposeBag()
    private lazy var networkService = NetworkService(
        withNameObservable: searchBarText,
        vc: self
    )
    
    private lazy var animalsRelay = PublishRelay<[Animal]>()
    private lazy var animals: Observable<[Animal]> = animalsRelay.asObservable()
    
    private lazy var errorCompletion: (_ error: Error?) -> Void = { [weak self] error in
        self?.animalsRelay.accept([])
        DispatchQueue.main.async { [weak self] in
            self?.mainView.activityIndicator.stopAnimating()
        }
        if let error {
            print("Error \(String(describing: error))")
        }
    }
    
    var searchBarText: Observable<String> {
        return mainView.textField.rx.text.orEmpty
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do(onNext: { [weak self] text in
                if text.isEmpty {
                    self?.networkService.catsDriver = Driver.just([])
                    self?.networkService.dogsDriver = Driver.just([])
                    self?.showLoadingAnimation(false)
                }
            })
            .filter { !$0.isEmpty }
            .subscribe(on: MainScheduler.instance)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = mainView
        mainView.setup()
        bindUI()
    }
    
    func showLoadingAnimation(_ value: Bool) {
        if value {
            mainView.activityIndicator.startAnimating()
        } else {
            mainView.activityIndicator.stopAnimating()
        }
    }
    
    private func bindUI() {
        
        mainView.cancelButton.rx
            .controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.mainView.textField.text = nil
                self?.networkService.catsDriver = Driver.just([])
                self?.networkService.dogsDriver = Driver.just([])
                self?.showLoadingAnimation(false)
            }, onDisposed: {
                print("cancelButton disposed")
            }).disposed(by: disposeBag)
        
        
        networkService.catsDriver.withLatestFrom(
            networkService.dogsDriver
        ){ (cats, dogs) in
            cats + dogs
        }.map { (items) in
            items.sorted(by: { (item1, item2) in
                return item1.playfulness == item2.playfulness ? item1.name < item2.name : item1.playfulness > item2.playfulness
            })
        }
        .do(onNext: { [weak self] _ in
            self?.showLoadingAnimation(false)
        })
        .drive(mainView.resultTableView.rx.items(
            cellIdentifier: "Cell",
            cellType: Cell.self
        )) { index, model, cell in
            cell.textLabel?.text = "\(model.playfulness) - \(model.name)"
        }.disposed(by: disposeBag)
    }
}
