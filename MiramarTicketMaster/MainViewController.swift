//
//  MainViewController.swift
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

class MainViewController: ViewController {
	
	private struct Layout {
		static let horizontalMargin = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
		static let verticalMargin = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
		static let spacing: CGFloat = 8
	}
    
    /// Operations
	
    fileprivate let disposeBag = DisposeBag()
    
    /// Configs
	
	let network = MiramarService()
	
	var viewModel: ViewModel = EmptyViewModel()
	
	var authToken: String = ""
    var member: Member?
	var movieSession: MovieSession?
	
	let tasks: [TaskStateView.Task] = [
		TaskStateView.Task.waiting(task: "Get auth token"),
		TaskStateView.Task.waiting(task: "Account login"),
		TaskStateView.Task.waiting(task: "Get movie sesssion"),
		TaskStateView.MultipleTask.waiting(tasks: [
			TaskStateView.Task.waiting(task: "Get seats"),
			TaskStateView.Task.waiting(task: "Get tickets"),
		]),
		TaskStateView.Task.waiting(task: "Order ticket"),
		TaskStateView.Task.waiting(task: "Get order payment"),
	]
	
    /// Others
    
    fileprivate var logString:String = ""
    fileprivate lazy var screenLogger: ScreenLogger = {
        let logger = ScreenLogger(with: self.textView)
        return logger
    }()
    
    private lazy var settingsBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(named: "settings")
        return item
    }()
	
    private var mainComponents: [UIView] {
        return [
			titleLabel,
			.spacer(.horizontal(Layout.spacing)),
            taskStateView,
            .spacer(.horizontal(Layout.spacing)),
            buttonsStackview
        ]
    }
    
    fileprivate lazy var stackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: mainComponents)
        stackview.alignment = .fill
        stackview.distribution = .fill
        stackview.axis = .vertical
        stackview.spacing = 4.0
        return stackview
    }()
	
	fileprivate lazy var titleLabel: UILabel = {
		let label = Label()
		label.text = "Tasks"
		label.textColor = .black
		label.font = .defaultDisplayFont(ofSize: 36, weight: .bold)
		label.margin = Layout.horizontalMargin
		return label
	}()
	
	fileprivate lazy var taskStateView: TaskStateView = {
		let view = TaskStateView(with: tasks)
		return view
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
        textView.applyShadow(style: .normal)
        return textView
    }()
    
    fileprivate lazy var buttonsStackview: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [startButton, backButton])
        stackview.alignment = .fill
        stackview.distribution = .fillEqually
        stackview.axis = .horizontal
        stackview.spacing = 10
		stackview.isLayoutMarginsRelativeArrangement = true
		stackview.layoutMargins = Layout.horizontalMargin
        return stackview
    }()
    
    fileprivate lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start".uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleFont = .defaultDisplayFont(ofSize: 18, weight: .light)
        button.backgroundColor = UIColor.cobinhood.green
        button.cornerRadius = 4.0
        button.applyShadow(style: .light)
        
        button.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        return button
    }()
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back".uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleFont = .defaultDisplayFont(ofSize: 18, weight: .light)
        button.backgroundColor = UIColor.cobinhood.green
        button.cornerRadius = 4.0
        button.applyShadow(style: .light)
        
        button.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        configureLayout()
        addActions()
    }
    
    private func initialize() {
        let viewModel = LoginViewModel()
        viewModel.delegate = self
        self.viewModel = viewModel
    }
    
    fileprivate func configureLayout() {
        navigationItem.rightBarButtonItem = settingsBarButtonItem
        navigationItem.backBarButtonItem = .back
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(topLayoutGuide.snp.bottom).offset(Layout.verticalMargin.top)
            $0.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-Layout.verticalMargin.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addActions() {
        
        settingsBarButtonItem.rx.tap
            .asObservable()
            .throttle(0.3, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] in
                guard let self = self else { return }
                let configVC = SettingsViewController()
                self.navigationController?.pushViewController(configVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .asObservable()
            .throttle(0.3, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] in
                guard let self = self else { return }
                self.viewModel.start()
            }
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .asObservable()
            .throttle(0.3, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] in
                guard let self = self else { return }
                self.back()
            }
            .disposed(by: disposeBag)
    }
    
    func back() {
        if viewModel is OrderViewModel {
            guard let memberId = member?.memberId else { return }
            guard let movieSession = movieSession else { return }
            let viewModel = SeatAndTicketViewModel(token: authToken, memberId: memberId, movieSession: movieSession)
            viewModel.delegate = self
            self.viewModel = viewModel
            log.info("[INFO] Back to get seat and ticket...\n")
			taskStateView.update(state: .waiting, forTaskAtIndexPath: IndexPath(indexes: [3, 0]))
			taskStateView.update(state: .waiting, forTaskAtIndexPath: IndexPath(indexes: [3, 1]))
            
        } else if viewModel is SeatAndTicketViewModel {
            let viewModel = MovieViewModel(token: authToken)
            viewModel.delegate = self
            self.viewModel = viewModel
            log.info("[INFO] Back to get movie session...\n")
			taskStateView.update(state: .waiting, forTaskAtIndexPath: IndexPath(index: 2))
            
        } else {
            return
        }
    }
}

// MARK: -
// MARK: ScreenLogger

extension MainViewController {
    
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

extension MainViewController: LoginViewModelDelegate {
	func isGoingToGetAuthToken() {
		taskStateView.update(state: .running, forTaskAtIndexPath: IndexPath(index: 0))
	}

	func didAuthTokenGetSucceed(token: String) {
		self.authToken = token
		taskStateView.update(state: .success, forTaskAtIndexPath: IndexPath(index: 0))
	}
	
	func isGoingToLogin() {
		taskStateView.update(state: .running, forTaskAtIndexPath: IndexPath(index: 1))
	}
	
	func didLoginCompleted(with token: String, member: Member) {
        self.member = member
		taskStateView.update(state: .success, forTaskAtIndexPath: IndexPath(index: 1))
        
		let viewModel = MovieViewModel(token: token)
		viewModel.delegate = self
		self.viewModel = viewModel
	}
}

extension MainViewController: MovieViewModelDelegate {
	func isGoingToGetMovieSession() {
		taskStateView.update(state: .running, forTaskAtIndexPath: IndexPath(index: 2))
	}
	
	func didGetMovieSession(movieSession: MovieSession) {
		self.movieSession = movieSession
		taskStateView.update(state: .success, forTaskAtIndexPath: IndexPath(index: 2))
        
        guard let memberId = member?.memberId else { return }
        let viewModel = SeatAndTicketViewModel(token: authToken, memberId: memberId, movieSession: movieSession)
		viewModel.delegate = self
        self.viewModel = viewModel
	}
}

extension MainViewController: SeatAndTicketViewModelDelegate {
	func willGetSeatPlan() {
		taskStateView.update(state: .running, forTaskAtIndexPath: IndexPath(indexes: [3, 0]))
	}
	
	func didGetSeats() {
		taskStateView.update(state: .success, forTaskAtIndexPath: IndexPath(indexes: [3, 0]))
	}
	
	func willGetTicketType() {
		taskStateView.update(state: .running, forTaskAtIndexPath: IndexPath(indexes: [3, 1]))
	}
	
	func didGetTicketTypes() {
		taskStateView.update(state: .success, forTaskAtIndexPath: IndexPath(indexes: [3, 1]))
	}
	
	func didTasksCompleted(seats: [Order.SelectedSeat], ticketTypes: [Order.TicketType], sessionId: String) {
		guard let member = member else { return }
		let order = Order()
		order.memberId = member.memberId
		order.ticketTypes = ticketTypes
		order.cinemaId = "1001"
		order.selectedSeats = seats
		order.userSessionId = Config().sessionId
		order.sessionId = sessionId
		
		let viewModel = OrderViewModel(token: authToken, member: member, order: order)
		viewModel.delegate = self
		self.viewModel = viewModel
	}
	
	func didTaskFailed() {
		let task = tasks[3]
		task.state = .failed
	}
}

extension MainViewController: OrderViewModelDelegate {
	func willOrderTicket() {
		taskStateView.update(state: .running, forTaskAtIndexPath: IndexPath(index: 4))
	}
	
	func didTicketOrdered() {
		taskStateView.update(state: .success, forTaskAtIndexPath: IndexPath(index: 4))
	}
	
	func willGetOrderPayment() {
		taskStateView.update(state: .running, forTaskAtIndexPath: IndexPath(index: 5))
	}
	
	func didGetOrderPayment(orderedTicket: OrderTicket) {
		taskStateView.update(state: .success, forTaskAtIndexPath: IndexPath(index: 5))
		log.info("[SUCCESS] Order ticket completed!!! 🎉🎉🎉")
		
		let viewModel = OrderResultViewModel(orderTicket: orderedTicket)
		let vc = OrderResultViewController(with: viewModel)
		present(vc, animated: true, completion: nil)
	}
}
