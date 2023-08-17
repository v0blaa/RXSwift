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
    
    private let mainView = View()
    private let disposeBag = DisposeBag()
    private let networkService = NetworkService()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = mainView
        mainView.setup()
        bindUI()
    }
    
    private func bindUI() {
        mainView.cancelButton.rx
            .controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.networkService.calcelCurrentRequests()
                self?.mainView.textField.text = nil
                self?.animalsRelay.accept([])
                self?.mainView.activityIndicator.stopAnimating()
            }, onDisposed: {
                print("cancelButton disposed")
            }).disposed(by: disposeBag)
        
        mainView.textField.rx.text.orEmpty
            .changed
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                self.mainView.activityIndicator.startAnimating()
                self.networkService.calcelCurrentRequests()
                guard !text.isEmpty,
                      let catsRequest = NetworkRequestFactory().getCatsRequest(name: text),
                      let dogsRequest = NetworkRequestFactory().getDogsRequest(name: text)
                else {
                    self.errorCompletion(nil)
                    return
                }
                
                Single.zip(self.networkService.sendCatRequest(request: catsRequest),
                           self.networkService.sendDogRequest(request: dogsRequest)) { (cats, dogs) in
                    cats + dogs
                }.map { (items) in
                    items.sorted(by: { (item1, item2) in
                        item1.playfulness > item2.playfulness
                    })
                }.subscribe (onSuccess: {
                    self.animalsRelay.accept($0)
                    DispatchQueue.main.async {
                        self.mainView.activityIndicator.stopAnimating()
                    }
                }, onFailure: { error in
                    self.errorCompletion(error)
                }
                ).disposed(by: self.disposeBag)
            }, onError: { error in
                self.errorCompletion(error)
            }, onDisposed: {
                print("textField disposed")
            }).disposed(by: disposeBag)
        
        animals.bind(to: mainView.resultTableView.rx.items(
            cellIdentifier: "Cell",
            cellType: Cell.self
        )) { index, model, cell in
            cell.textLabel?.text = "\(model.name) - \(model.playfulness)"
        }.disposed(by: disposeBag)
    }
}
