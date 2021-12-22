//
//  ViewController.swift
//  OriginalMVCSample
//
//  Created by 史翔新 on 2018/11/07.
//  Copyright © 2018年 史翔新. All rights reserved.
//

import UIKit

/// 原初 MVC の場合、`ViewController` はあくまで UIKit の仕組みに則って存在するだけであって、実際の Controller としての仕事には関与しないことにご注意ください。
class ViewController: UIViewController {
	
	private lazy var myView = View()
	
	override func loadView() {
		view = myView
		view.backgroundColor = .white
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// ここで外部から View に Model を渡しているとイメージしてください。
		myView.myModel = Model()
	}
	
}

// ビジネスロジックの塊
// 自身の変化をDependentsに登録したオブジェクトに通知する役割
class Model {
	
	let notificationCenter = NotificationCenter()
	
	private(set) var count = 0 {
		didSet {
            // 更新を複数のオブジェクトに通知する := SmalltalkのDependentsと同等の機能
            notificationCenter.post(name: NSNotification.Name(rawValue: "count"),
									object: nil,
									userInfo: ["count": count])
		}
	}
	
	func countDown() {
		count -= 1
	}
	
	func countUp() {
		count += 1
	}
	
}

// 入力に関する適切な処理をする
// 具体的なビジネスロジックはModelオブジェクトへ依頼
class Controller {
	
	weak var myModel: Model?  // 処理の依頼をするために保持
	
	required init() {
		
	}
	
	@objc func onMinusTapped() {
		myModel?.countDown()
	}
	
	@objc func onPlusTapped() {
		myModel?.countUp()
	}
	
}

// 画面の描画を担当
// 適切なControllerオブジェクトの選定・Modelオブジェクトの保持もViewの役割
class View: UIView {

    // MARK: - Properties
    
	let label = UILabel()
	let minusButton = UIButton()
	let plusButton = UIButton()
	
    // 原初MVCではViewがControllerを保持する
    // COntrollerを継承しているクラスであれば指定できる
	var defaultControllerClass: Controller.Type = Controller.self
	private var myController: Controller?
	
	var myModel: Model? {
		didSet { // ViewにModelがセットされタイミングで、Controller生成と、Model監視を開始する
			registerModel()
		}
	}
	
    // MARK: - Lifecycles
        
	deinit {
		myModel?.notificationCenter.removeObserver(self)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setSubviews()
		setLayout()
	}
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
	
    // MARK: - Helpers
    
	private func setSubviews() {
		
		addSubview(label)
		addSubview(minusButton)
		addSubview(plusButton)
		
		label.textAlignment = .center
		
		label.backgroundColor = .blue
		minusButton.backgroundColor = .red
		plusButton.backgroundColor = .green
		
		minusButton.setTitle("-1", for: .normal)
		plusButton.setTitle("+1", for: .normal)
		
	}
	
	private func setLayout() {
		
		label.translatesAutoresizingMaskIntoConstraints = false
		plusButton.translatesAutoresizingMaskIntoConstraints = false
		minusButton.translatesAutoresizingMaskIntoConstraints = false
		
		label.topAnchor.constraint(equalTo: topAnchor).isActive = true
		label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		label.bottomAnchor.constraint(equalTo: minusButton.topAnchor).isActive = true
		label.bottomAnchor.constraint(equalTo: plusButton.topAnchor).isActive = true
		label.heightAnchor.constraint(equalTo: minusButton.heightAnchor).isActive = true
		label.heightAnchor.constraint(equalTo: plusButton.heightAnchor).isActive = true
		minusButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		plusButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		minusButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		minusButton.rightAnchor.constraint(equalTo: plusButton.leftAnchor).isActive = true
		plusButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		minusButton.widthAnchor.constraint(equalTo: plusButton.widthAnchor).isActive = true
		
	}
	
	private func registerModel() {
		
		guard let model = myModel else { return }
        
		let controller = defaultControllerClass.init()
		controller.myModel = model
		myController = controller
		
		label.text = model.count.description
		
		minusButton.addTarget(controller, action: #selector(Controller.onMinusTapped), for: .touchUpInside)
		plusButton.addTarget(controller, action: #selector(Controller.onPlusTapped), for: .touchUpInside)
		
        // Modelの監視を始める
		model.notificationCenter.addObserver(forName: .init(rawValue: "count"),
											 object: nil,
											 queue: nil,
											 using: { [unowned self] notification in
												if let count = notification.userInfo?["count"] as? Int {
													self.label.text = count.description
												}
		})
		
	}
	
}
