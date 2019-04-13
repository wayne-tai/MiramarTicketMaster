//
//  OrderResultViewController.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/13.
//  Copyright © 2019 Wayne. All rights reserved.
//

import UIKit
import RxSwift

class OrderResultViewController: UIViewController {
	
	private struct Layout {
		static let margin = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
	}
	
	private let disposeag = DisposeBag()
	
	private let viewModel: OrderResultViewModel
	
	private lazy var contentView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 8
		view.backgroundColor = .white
		view.addSubview(stackview)
		stackview.snp.makeConstraints({ (maker) in
			maker.edges.equalToSuperview()
		})
		return view
	}()
	
	private lazy var stackview: UIStackView = {
		let stackview = UIStackView(arrangedSubviews: [
			movieNameRowView,
			movieDateTimeRowView,
			movieSeatsRowView,
			closeButton
			])
		stackview.alignment = .fill
		stackview.distribution = .fillProportionally
		stackview.axis = .vertical
		stackview.spacing = 8
		stackview.isLayoutMarginsRelativeArrangement = true
		stackview.layoutMargins = Layout.margin
		return stackview
	}()
	
	private let movieNameRowView = RowView()
	private let movieDateTimeRowView = RowView()
	private let movieSeatsRowView = RowView()
	
	private lazy var closeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Close", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .defaultDisplayFont(ofSize: 18, weight: .light)
		button.backgroundColor = UIColor.cobinhood.green
		button.cornerRadius = 4.0
		button.applyShadow(style: .light)
		
		button.snp.makeConstraints {
			$0.height.equalTo(50)
		}
		return button
	}()
	
	init(with viewModel: OrderResultViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		modalTransitionStyle = .crossDissolve
		modalPresentationStyle = .overFullScreen
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		view.addSubview(blurEffectView)
		blurEffectView.snp.makeConstraints { (maker) in
			maker.edges.equalToSuperview()
		}
		
		blurEffectView.contentView.addSubview(contentView)
		contentView.snp.makeConstraints { (maker) in
			maker.center.equalToSuperview()
		}
		
		movieNameRowView.title = "Name"
		movieNameRowView.value = viewModel.movieName
		
		movieDateTimeRowView.title = "Date"
		movieDateTimeRowView.value = viewModel.movieDate
		
		movieSeatsRowView.title = "Seats"
		movieSeatsRowView.value = viewModel.movieSeats
		
		closeButton.rx.tap
			.asObservable()
			.throttle(0.3, scheduler: MainScheduler.asyncInstance)
			.bind { [weak self] in
				guard let self = self else { return }
				self.dismiss(animated: true, completion: nil)
			}
			.disposed(by: disposeag)
    }
}

class RowView: UIView {
	
	private struct Layout {
		static let margin = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
	}
	
	var title: String? {
		get { return titleLabel.text }
		set { titleLabel.text = newValue }
	}
	
	var value: String? {
		get { return valueLabel.text }
		set { valueLabel.text = newValue }
	}
	
	private lazy var stackview: UIStackView = {
		let stackview = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
		stackview.alignment = .fill
		stackview.distribution = .fillProportionally
		stackview.axis = .vertical
		stackview.spacing = 0
		stackview.isLayoutMarginsRelativeArrangement = true
		stackview.layoutMargins = Layout.margin
		return stackview
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultDisplayFont(ofSize: 14, weight: .bold)
		label.textColor = .black
		label.setContentHuggingPriority(.required, for: .vertical)
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}()
	
	private lazy var valueLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultDisplayFont(ofSize: 20, weight: .regular)
		label.textColor = .black
		label.setContentHuggingPriority(.required, for: .vertical)
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}()
	
	init() {
		super.init(frame: .zero)
		initialize()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func initialize() {
		addSubview(stackview)
		stackview.snp.makeConstraints { (maker) in
			maker.edges.equalToSuperview()
		}
	}
}
