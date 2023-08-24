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
        withNameObservable: searchBarText
    )
    
    private var animalsDisposable: Disposable?
    
    var searchBarText: Observable<String> {
        return mainView.textField.rx.text.orEmpty.skip(1)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(on: MainScheduler.instance)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = mainView
        mainView.setup()
        bindUI()
        bindNetworkService()
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
                self?.showLoadingAnimation(false)
                self?.bindNetworkService()
            }, onDisposed: {
                print("cancelButton disposed")
            }).disposed(by: disposeBag)
        
        networkService.errorRelay.asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard self?.presentedViewController == nil else { return }
                let alert = UIAlertController(
                    title: error.localizedDescription,
                    message: nil,
                    preferredStyle: .alert
                )
                self?.present(alert, animated: true)
                // чтобы на кнопочку не тыкань сделала....
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.dismiss(animated: true)
                }
            }, onDisposed: {
                print("networkService.errorRelay.asObservable() disposed")
            }
            ).disposed(by: disposeBag)
    }
    
    private func bindNetworkService() {
        animalsDisposable?.dispose()
        animalsDisposable = networkService.animals
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.showLoadingAnimation(false)
            })
            .bind(to: mainView.resultTableView.rx.items(
                cellIdentifier: "Cell",
                cellType: Cell.self
            )) { index, model, cell in
                cell.textLabel?.text = "\(model.playfulness) - \(model.name)"
            }
    }
}
