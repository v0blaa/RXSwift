//
//  InitialVC.swift
//  RXSwift
//

import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

final class InitialVC: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.navigationController?.pushViewController(ViewController(), animated: true)
        }
    }
}
