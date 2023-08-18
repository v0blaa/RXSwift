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
        let networkService = NetworkService(withNameObservable: searchBarText,
                                                         vc: self)
        
        mainView.cancelButton.rx
            .controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.mainView.textField.text = nil
            }, onDisposed: {
                print("cancelButton disposed")
            }).disposed(by: disposeBag)
        
        Driver
            .zip(networkService.catsDriver,
                 networkService.dogsDriver)
            { (cats, dogs) in
                cats + dogs
            }
            .map { (items) in
                items.sorted(by: { (item1, item2) in
                    return item1.playfulness == item2.playfulness ? item1.name < item2.name : item1.playfulness > item2.playfulness
                })
            }
            .drive(mainView.resultTableView.rx.items(
                cellIdentifier: "Cell",
                cellType: Cell.self
            )) { index, model, cell in
                cell.textLabel?.text = "\(model.playfulness) - \(model.name)"
            }.disposed(by: disposeBag)
    }
}
