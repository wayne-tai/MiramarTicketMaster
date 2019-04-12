//
//  ViewController.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2018/3/26.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Alamofire

struct TargetSeatRange {
    let row: String
    let range: CountableClosedRange<Int>
}

class ViewController: UIViewController {
    
    /// Operations
	
    fileprivate let disposeBag = DisposeBag()
    
    /// Configs
	
	let network = MiramarService()
	
	var viewModel: ViewModel = EmptyViewModel()
	
	var authToken: String = ""
    var member: Member?
	var movieSession: MovieSession?
    var seatPlan: SeatPlan?
	
    /// Others
    
    fileprivate var logString:String = ""
    fileprivate lazy var screenLogger: ScreenLogger = {
        let logger = ScreenLogger(with: self.textView)
        return logger
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate let requestScheduler: OperationQueueScheduler = {
        let queue = OperationQueue()
        queue.name = "idv.wayne.requests"
        queue.maxConcurrentOperationCount = 20
        return OperationQueueScheduler(operationQueue: queue)
    }()
	
    private var components: [UIView] {
        return [textView,
                separatorView2,
                buttonsStackview]
    }
    
    fileprivate lazy var stackView: UIStackView = {
        let stackview = UIStackView()
        stackview.alignment = .fill
        stackview.distribution = .fill
        stackview.axis = .vertical
        stackview.spacing = 4.0
        
        components.forEach { stackview.addArrangedSubview($0) }
        
        return stackview
    }()
    
    fileprivate lazy var sessionIdTitle: UILabel = {
        let label = UILabel()
        label.text = "Session Id"
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .white
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    fileprivate lazy var sessionIdTextField: UITextField = {
        let textField = UITextField()
        textField.addPaddingLeft(4.0)
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 15, weight: .light)
        textField.setContentHuggingPriority(.required, for: .vertical)
        
        return textField
    }()
    
    fileprivate lazy var separatorView: UIView = {
        let view = UIView()
        view.snp.makeConstraints {
            $0.height.equalTo(16)
        }
        return view
    }()
    
    fileprivate lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.textColor = UIColor.cobinhood.darkGray
        textView.font = .systemFont(ofSize: 10, weight: .light)
        textView.cornerRadius = 4.0
        textView.isEditable = false
        return textView
    }()
    
    fileprivate lazy var separatorView2: UIView = {
        let view = UIView()
        view.snp.makeConstraints {
            $0.height.equalTo(8)
        }
        return view
    }()
    
    fileprivate lazy var buttonsStackview: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [startButton, backButton])
        stackview.alignment = .fill
        stackview.distribution = .fillEqually
        stackview.axis = .horizontal
        stackview.spacing = 10
        return stackview
    }()
    
    fileprivate lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start".uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleFont = .systemFont(ofSize: 18, weight: .light)
        button.backgroundColor = UIColor.cobinhood.green
        button.cornerRadius = 4.0
        
        button.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        return button
    }()
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back".uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleFont = .systemFont(ofSize: 18, weight: .light)
        button.backgroundColor = UIColor.cobinhood.green
        button.cornerRadius = 4.0
        
        button.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
		let viewModel = LoginViewModel()
		viewModel.delegate = self
		viewModel.logger = self
		self.viewModel = viewModel
        
        startButton.rx.tap
            .asObservable()
            .bind { [weak self] in
				guard let self = self else { return }
				self.viewModel.start()
            }
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .asObservable()
            .bind { [weak self] in
                guard let self = self else { return }
                self.back()
            }
            .disposed(by: disposeBag)
        
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = UIColor.cobinhood.darkGray
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(topLayoutGuide.snp.bottom).offset(24)
            $0.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    func back() {
        if viewModel is OrderViewModel {
            guard let memberId = member?.memberId else { return }
            guard let movieSession = movieSession else { return }
            let viewModel = SeatAndTicketViewModel(token: authToken, memberId: memberId, movieSession: movieSession)
            viewModel.delegate = self
            viewModel.logger = self
            self.viewModel = viewModel
            log("[INFO] Back to get seat and ticket...\n")
            
        } else if viewModel is SeatAndTicketViewModel {
            let viewModel = MovieViewModel(token: authToken)
            viewModel.delegate = self
            viewModel.logger = self
            self.viewModel = viewModel
            log("[INFO] Back to get movie session...\n")
            
        } else {
            return
        }
    }
}

// MARK: -
// MARK: ScreenLogger

extension ViewController {
    
    class ScreenLogger {
        var message: String = ""
        var textView: UITextView
        
        init(with textView: UITextView) {
            self.textView = textView
        }
        
        func log(_ message: String) {
            self.message = message
            
            DispatchQueue.main.async {
                self.textView.text = self.message
            }
        }
    }
}

extension ViewController: ViewModelLogger {
	func log(_ text: String) {
		screenLogger.log(text)
	}
}

extension ViewController: LoginViewModelDelegate {
	func didLoginCompleted(with token: String, member: Member) {
        self.authToken = token
        self.member = member
        
		let viewModel = MovieViewModel(token: token)
		viewModel.delegate = self
		viewModel.logger = self
		self.viewModel = viewModel
	}
}

extension ViewController: MovieViewModelDelegate {
	func didGetMovieSession(movieSession: MovieSession) {
		self.movieSession = movieSession
        
        guard let memberId = member?.memberId else { return }
        let viewModel = SeatAndTicketViewModel(token: authToken, memberId: memberId, movieSession: movieSession)
		viewModel.delegate = self
		viewModel.logger = self
        self.viewModel = viewModel
	}
}

extension ViewController: SeatAndTicketViewModelDelegate {
	
	func didGetSeatOrTicketFailed(reason: String) {
		log(reason)
	}
	

	func didGetSeatAndTicket(seats: [Order.SelectedSeat], ticketTypes: [Order.TicketType], sessionId: String) {
		guard let member = member else { return }
		let order = Order()
		order.memberId = member.memberId
		order.ticketTypes = ticketTypes
		order.cinemaId = "1001"
		order.selectedSeats = seats
		order.userSessionId = Config().sessionId
		order.sessionId = sessionId
		
		let viewModel = OrderViewModel(token: authToken, member: member, order: order)
		viewModel.logger = self
		viewModel.delegate = self
		self.viewModel = viewModel
	}
}

extension ViewController: OrderViewModelDelegate {

	func didOrderTicketAndPaymentSuccess() {
		log("[SUCCESS] Order ticket completed!!! 🎉🎉🎉")
	}
}
