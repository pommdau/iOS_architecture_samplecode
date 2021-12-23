//
//  ViewController.swift
//  RxSimpleSample
//
//  Created by Kenji Tanaka on 2018/10/08.
//  Copyright © 2018年 Kenji Tanaka. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var validationLabel: UILabel!

    // RxではViewModelを作成する際に、UITextFieldのObservableを渡す
    // UITextFieldのrx拡張からtextプロパティを取り出し、更にasObservable()でObservableを取り出し渡している
    private lazy var viewModel = ViewModel(
        idTextObservable: idTextField.rx.text.asObservable(),
        passwordTextObservable: passwordTextField.rx.text.asObservable(),
        model: Model()
    )
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewModel.validationTextとvalidationLabel.rx.textとをbind(to:)でデータバインディング
        // これえviewModel.validationTextの変更に同期して、validationLabelの文字も変更されるようになる
        viewModel.validationText
            .bind(to: validationLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.loadLabelColor
            .bind(to: loadLabelColor)
            .disposed(by: disposeBag)
    }
    
    // 色の更新処理をBinder化する
    private var loadLabelColor: Binder<UIColor> {
        return Binder(self) { me, color in
            me.validationLabel.textColor = color
        }
    }
}

