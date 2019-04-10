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

enum CinemaName: String {
    case IMAX = "大直IMAX影廳"
    case normal = "美麗華大直影城"
    case royal = "美麗華大直皇家影城"
}

//enum MasterState {
//    case initial
//	case didLoggedIn
//
//
//
//
//
//
//
//    case announceReceived(key: String)
//    case showTimeReceived(cinemas: [Cinema])
//    case ticketTypeReceived(ticketTypes: [TicketType])
////    case sessionSeatDataReceived(ticketTypes: [Area])
////    case orderConfirmReceived(orderConfirm: OrderConfirm)
//    case orderResultReceived(orderResult: OrderResult)
//}

struct TargetSeatRange {
    let row: String
    let range: CountableClosedRange<Int>
}

class ViewController: UIViewController {
    
    /// Operations
    
    fileprivate var repeatInterval: DispatchTimeInterval = .seconds(2)
    
    fileprivate var timer: DispatchSourceTimer?
    
    fileprivate var timerQueue: DispatchQueue = DispatchQueue(label: "idv.wayne.miramar.ticket.master.timer", attributes: .concurrent)
    
    fileprivate let disposeBag = DisposeBag()
    
    /// Configs
    
    fileprivate var targetCinema: CinemaName { return .IMAX }
	
	fileprivate var targetMovieName: String { return "沙贊" }
    
//	fileprivate var targetMovieName: String { return "復仇者聯盟" }
	
    fileprivate var targetTicketType: String { return "IMAX Adult" }
    
    fileprivate var targetTicketQuantity: Int { return 2 }
    
    fileprivate var targetSeats: [TargetSeatRange] { return [TargetSeatRange(row: "L", range: 14...27),
                                                             TargetSeatRange(row: "K", range: 14...25)] }
    
    fileprivate var key: String? = UserDefaults.standard.string(forKey: Environments.UserDefaultsKey.Key) {
        didSet {
            UserDefaults.standard.set(key, forKey: Environments.UserDefaultsKey.Key)
            UserDefaults.standard.synchronize()
        }
    }
	
	var targetMovieDateTimes: [Date] = {
		let dateTimeStrings = [
			"2019-04-12T19:00:00",
			"2019-04-27T19:00:00",
			"2019-04-28T19:00:00"
		]
		return dateTimeStrings.compactMap { $0.date }
	}()
	
	let network = MiramarService()
	
	let sessionId = "YRHYN04001LX684ETHW1ZA4S4YED01X9"
	
	var viewModel: ViewModel = EmptyViewModel()
	
	var authToken: String?
	var movieSession: MovieSession?
    
    /// Local Memory Caches
    
//    fileprivate var cinemas: [Cinema] = []
	
//    fileprivate var ticketTypes: [TicketType] = []
	
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
    
//    fileprivate var currentState: MasterState = .initial {
//        didSet {
//            switch currentState {
//            case .initial:
//                break
//
//			/// ==========================================================================================================
//			/// Login
//			/// ==========================================================================================================
//			case .loginWithToken(let token):
//				self.screenLogger.log("Get auth token success!\n")
//				self.screenLogger.log("============================\n\n")
//				DispatchQueue.global().async {
//					self.startGetShowTime(with: key)
//				}
//
//            /// ==========================================================================================================
//            /// Announce Received
//            /// ==========================================================================================================
//            case .announceReceived(let key):
//                self.screenLogger.log("Request for announce success!\n")
//                self.screenLogger.log("Get key \(key.data)\n\n")
//                self.screenLogger.log("============================\n\n")
//
//                DispatchQueue.global().async {
//                    self.startGetShowTime(with: key)
//                }
//
//            /// ==========================================================================================================
//            /// Show Time Received
//            /// ==========================================================================================================
//            case .showTimeReceived(let cinemas):
//                self.screenLogger.log("Request for show time success!\n")
//                self.screenLogger.log("Get cinemas count \(cinemas.count)\n\n")
//
//                DispatchQueue.global().async {
//                    guard let ciname = cinemas.first(where: { $0.cinemaCName.contains(self.targetCinema.rawValue) }) else {
//                        self.screenLogger.log("\(self.targetCinema) couldn't be found...\n")
//
//                        return
//                    }
//                    self.cinemaId = ciname.cinemaId
//
//                    guard let movie = ciname.movieList.first(where: { $0.movieCName.contains(self.targetMovieName) }) else {
//                        self.screenLogger.log("Target movie \(self.targetMovieName) couldn't be found...\n")
//
//                        return
//                    }
//
//                    guard let showDate = movie.showDateList.first(where: { $0.showDateISO.contains(self.targetMovieDate) }) else {
//                        self.screenLogger.log("Target date \(self.targetMovieDate) couldn't be found...\n")
//
//                        return
//                    }
//
//                    guard let sessionList =
//                        (showDate.showTimeList.first(where: { $0.movieHallEn == "IMAX" })?.sessionList ?? showDate.showTimeList.first?.sessionList)
//                    else {
//                        self.screenLogger.log("Neither IMAX or IMAX 3D couldn't be found...\n")
//
//                        return
//                    }
//
//                    var minutesDiff: Int = 1440
//                    var targetSession: Session? = nil
//
//                    for session in sessionList {
//                        let time = session.showTime.components(separatedBy: ":")
//                        let hour = time.first?.intValue ?? 0
//                        let min = time.last?.intValue ?? 0
//
//                        let newDiff: Int = (((hour - self.targetMovieHour) * 60) + (min - self.targetMovieMin)).abs
//                        if newDiff < minutesDiff {
//                            minutesDiff = newDiff
//                            targetSession = session
//                        }
//                    }
//
//                    guard let session = targetSession else {
//                        self.screenLogger.log("Target time \(self.targetMovieHour):\(self.targetMovieMin) of the session couldn't be found...\n")
//
//                        return
//                    }
//                    self.sessionId = session.sessionId
//
//                    let message = """
//                    Session: {
//                        "SessionId": "\(session.sessionId)",
//                        "AvailableSeats": "\(session.availableSeats)",
//                        "ShowTime": "\(session.showTime)",
//                        "Status": \(session.status),
//                        "MovieHallCode": "\(session.movieHallCode)"
//                    }\n\n
//                    """
//                    self.screenLogger.log(message)
//                    self.screenLogger.log("============================\n\n")
//
//
//                    guard let key = self.key else {
//                        self.screenLogger.log("Key is not available...\n")
//
//                        return
//                    }
//                    self.startGetTicketTypes(with: key, cinemaId: ciname.cinemaId, sessionId: session.sessionId)
//                }
//
//            /// ==========================================================================================================
//            /// Ticket Types Received
//            /// ==========================================================================================================
//            case .ticketTypeReceived(let ticketTypes):
//                self.screenLogger.log("Request for ticket types success!\n")
//                self.screenLogger.log("Get ticket types \(ticketTypes.count)\n\n")
//
//                DispatchQueue.global().async {
//                    guard let ticketType = ticketTypes.first(where: { $0.ticketTypeDescriptEn == self.targetTicketType }) else {
//                        self.screenLogger.log("Target ticket type \(self.targetTicketType) couldn't be found...\n")
//
//                        return
//                    }
//
//                    guard let key = self.key else {
//                        self.screenLogger.log("Key is not available...\n")
//
//                        return
//                    }
//
//                    guard let cinemaId = self.cinemaId else {
//                        self.screenLogger.log("Cinema Id is not available...\n")
//
//                        return
//                    }
//
//                    guard let sessionId = self.sessionId else {
//                        self.screenLogger.log("Session Id is not available...\n")
//
//                        return
//                    }
//
//                    let json = "[{\"TicketPrice\":\(ticketType.ticketPrice), \"TicketTypeCode\":\"\(ticketType.ticketTypeCode)\", \"Quantity\":\(self.targetTicketQuantity)}]"
//                    log.debug(json)
//
//                    let message = """
//                    TicketType: {
//                        "TicketTypeCode": "\(ticketType.ticketTypeCode)",
//                        "TicketTypeDescriptEn": "\(ticketType.ticketTypeDescriptEn)",
//                        "TicketTypeDescriptCht": "\(ticketType.ticketTypeDescriptCht)",
//                        "TicketPrice": \(ticketType.ticketPrice),
//                        "Quantity": "\(self.targetTicketQuantity)"
//                    }\n\n
//                    """
//                    self.screenLogger.log(message)
//                    self.screenLogger.log("============================\n\n")
//
//                    self.startGetSessionSeatData(with: key, cinemaId: cinemaId, sessionId: sessionId, ticketTypeJson: json)
//                }
//
//            /// ==========================================================================================================
//            /// Session Seat Data Received
//            /// ==========================================================================================================
////            case .sessionSeatDataReceived(let areas):
//
//            /// ==========================================================================================================
//            /// Order Confirm Received
//            /// ==========================================================================================================
////            case .orderConfirmReceived(let orderConfirm):
//
//            /// ==========================================================================================================
//            /// Order Result Received
//            /// ==========================================================================================================
//            case .orderResultReceived(let orderResult):
//                self.screenLogger.log("Request for complete order success!\n")
//                self.screenLogger.log("Get order result\n")
//                log.debug(orderResult)
//
//                self.screenLogger.log("VistaBookingNumber: \(orderResult.vistaBookingNumber)\n\n")
//                self.screenLogger.log("============================\n\n")
//
//                self.screenLogger.log("Done!!\n\n")
//                self.screenLogger.log("============================\n\n")
//
//            }
//        }
//    }
	
    private var components: [UIView] {
        return [textView,
                separatorView2,
                actionButton]
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
    
    fileprivate lazy var captchaTitle: UILabel = {
        let label = UILabel()
        label.text = "Captcha"
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .white
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    fileprivate lazy var captchaTextField: UITextField = {
        let textField = UITextField()
        textField.addPaddingLeft(4.0)
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 15, weight: .light)
        textField.setContentHuggingPriority(.required, for: .vertical)
        
        return textField
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
    
    fileprivate lazy var actionButton: UIButton = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
		let viewModel = LoginViewModel(sessionId: sessionId)
		viewModel.delegate = self
		viewModel.logger = self
		self.viewModel = viewModel
        
        actionButton.rx.tap
            .asObservable()
            .bind { [weak self] in
				guard let self = self else { return }
				self.viewModel.start()
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
    
    // MARK: -
    // MARK: Actions
    
//    fileprivate func getShowTime(with key: String) {
//        self.screenLogger.log("Requesting for show time...\n")
//
//
//        API.getShowTime(with: key)
//            .observeOn(MainScheduler.asyncInstance)
//            .filter { _ -> Bool in
//                switch self.currentState {
//                case .initial, .announceReceived:
//                    return true
//                default:
//                    return false
//                }
//            }
//            .subscribe(
//                onNext: { (cinemas) in
//                    self.stopAnyTimer()
//                    self.cinemas = cinemas
//                    self.currentState = .showTimeReceived(cinemas: cinemas)
//            },
//                onError: { (error) in
//                    self.screenLogger.log("Request for show time failed...\n\n")
//                    self.screenLogger.log("Error \(error)\n")
//
//            })
//            .disposed(by: disposeBag)
//    }
//
//    fileprivate func getTicketTypes(with key: String, cinemaId: String, sessionId: String) {
//        self.screenLogger.log("Requesting for ticket types...\n")
//
//
//        API.getTicketTypes(with: key, cinemaId: cinemaId, sessionId: sessionId)
//            .observeOn(MainScheduler.asyncInstance)
//            .filter { _ -> Bool in
//                switch self.currentState {
//                case .initial, .announceReceived, .showTimeReceived:
//                    return true
//                default:
//                    return false
//                }
//            }
//            .subscribe(
//                onNext: { (ticketTypes) in
//                    self.stopAnyTimer()
//                    self.ticketTypes = ticketTypes
//                    self.currentState = .ticketTypeReceived(ticketTypes: ticketTypes)
//            },
//                onError: { (error) in
//                    self.screenLogger.log("Request for ticket types failed...\n\n")
//                    self.screenLogger.log("Error \(error)\n")
//
//            })
//            .disposed(by: disposeBag)
//    }
//
//    fileprivate func getSessionSeatData(with key: String, cinemaId: String, sessionId: String, ticketTypeJson: String) {
//        self.screenLogger.log("Requesting for session seat data...\n")
//
//
//        API.getSessionSeatData(with: key, cinemaId: cinemaId, sessionId: sessionId, ticketTypeJson: ticketTypeJson)
//            .retry(10)
//            .observeOn(MainScheduler.asyncInstance)
//            .subscribe(
//                onNext: { (areas) in
////                    self.stopAnyTimer()
////                    self.currentState = .sessionSeatDataReceived(ticketTypes: areas)
//                    self.getTargetSeats(by: areas)
//            },
//                onError: { (error) in
//                    self.screenLogger.log("Request for session seat data failed...\n\n")
//                    self.screenLogger.log("Error \(error)\n")
//
//            })
//            .disposed(by: disposeBag)
//    }
//
//    fileprivate func setSelectedSeat(with key: String, cinemaId: String, sessionId: String, selectedSeatJson: String) {
//        self.screenLogger.log("Requesting for set selected seat...\n")
//
//
//        API.setSelectedSeat(with: key, cinemaId: cinemaId, sessionId: sessionId, selectedSeatJson: selectedSeatJson)
//            .observeOn(MainScheduler.asyncInstance)
//            .retry(10)
//            .subscribe(
//                onNext: { (confirm) in
////                    self.stopAnyTimer()
////                    self.currentState = .orderConfirmReceived(orderConfirm: confirm)
//                    self.confirmOrder(by: confirm)
//            },
//                onError: { (error) in
//                    self.screenLogger.log("Request for set selected seat failed...\n\n")
//                    self.screenLogger.log("Error \(error)\n")
//
//            })
//            .disposed(by: disposeBag)
//    }
//
//    fileprivate func completeOrder(with key: String, cinemaId: String, sessionId: String, paymentValue: Int) {
//        self.screenLogger.log("Requesting for complete order...\n")
//
//
//        API.completeOrder(with: key, cinemaId: cinemaId, sessionId: sessionId, paymentValue: paymentValue)
//            .observeOn(MainScheduler.asyncInstance)
//            .retry(10)
//            .subscribe(
//                onNext: { (result) in
//                    self.stopAnyTimer()
//                    self.currentState = .orderResultReceived(orderResult: result)
//            },
//                onError: { (error) in
//                    self.screenLogger.log("Request for complete order failed...\n\n")
//                    self.screenLogger.log("Error \(error)\n")
//
//            })
//            .disposed(by: disposeBag)
//    }
}

// MARK: -
// MARK: Actions for Each State

//extension ViewController {
	
//    fileprivate func getTargetSeats(by areas: [Area]) {
//        self.screenLogger.log("Request for session seat data success!\n")
//        self.screenLogger.log("Get areas count \(areas.count)\n")
//
//        DispatchQueue.global().async {
//            guard let area = areas.first else {
//                self.screenLogger.log("No area could be found...\n")
//
//                return
//            }
//
//            self.screenLogger.log("Get rows count \(area.rows.count)\n")
//
//
//            var selectedSeats = [Seat]()
//            var selectedSeatsScores: Int = 0
//            let maxSeatPriorityScore: Int = Int(round(Double(area.rows.reduce(0, { max($0, $1.seats.count) })) / 2.0))
//
//            for targetSeat in self.targetSeats {
//                guard let row = area.rows.first(where: { $0.physicalName == .some(targetSeat.row) }) else {
//                    self.screenLogger.log("Target row \(targetSeat.row) couldn't be found...\n")
//
//                    return
//                }
//
//                var currentPickedSeats = [Seat]()
//
//                let seats = row.seats.filter{ targetSeat.range.contains($0.id.intValue) }
//                seats.forEach { (seat) in
//                    let seatId = seat.id.intValue
//                    seat.score = (seat.status == .empty) ? maxSeatPriorityScore - (seatId - maxSeatPriorityScore).abs : -(maxSeatPriorityScore)
//
//                    currentPickedSeats.append(seat)
//                    if currentPickedSeats.count > self.targetTicketQuantity {
//                        currentPickedSeats.removeFirst()
//                    }
//
//                    if currentPickedSeats.count == self.targetTicketQuantity {
//                        /// Make sure all seats are available.
//                        guard currentPickedSeats.filter({ $0.status != .empty }).isEmpty else { return }
//
//                        /// Compare two seats array and picked the one with higher scores.
//                        let pickedSeatsScore = currentPickedSeats.reduce(0, { $0 + $1.score })
//                        if pickedSeatsScore >= selectedSeatsScores {
//                            selectedSeats = currentPickedSeats
//                            selectedSeatsScores = pickedSeatsScore
//                        }
//                    }
//                }
//
//                if !selectedSeats.isEmpty {
//                    break
//                }
//            }
//
//            guard selectedSeats.count == self.targetTicketQuantity else {
//                self.screenLogger.log("Available seats are not enough...\n")
//
//                return
//            }
//
//            /// Create JSON string.
//            var jsonStringArray = [String]()
//            self.screenLogger.log("Seats: [\n")
//            selectedSeats.enumerated().forEach { (index, seat) in
//                let message = """
//                {
//                    "RowIndex": "\(seat.position.rowIndex)",
//                    "Id": "\(seat.id)",
//                    "Status": "\(seat.status.rawValue)"
//                }
//                """
//                self.screenLogger.log(message)
//                self.screenLogger.log(((selectedSeats.endIndex - 1) == index) ? "\n" : ",\n")
//
//                let jsonString = "{\"AreaCategoryCode\": \"\(area.areaCategoryCode)\", \"AreaNumber\": \(seat.position.areaNumber), \"RowIndex\": \(seat.position.rowIndex), \"ColumnIndex\": \(seat.position.columnIndex)}"
//                jsonStringArray.append(jsonString)
//            }
//            self.screenLogger.log("]\n\n")
//            self.screenLogger.log("============================\n\n")
//
//
//            let json = "[\(jsonStringArray.joined(separator: ", "))]"
//            log.debug(json)
//
//            guard let key = self.key else {
//                self.screenLogger.log("Key is not available...\n")
//
//                return
//            }
//
//            guard let cinemaId = self.cinemaId else {
//                self.screenLogger.log("Cinema Id is not available...\n")
//
//                return
//            }
//
//            guard let sessionId = self.sessionId else {
//                self.screenLogger.log("Session Id is not available...\n")
//
//                return
//            }
//
//            self.setSelectedSeat(with: key, cinemaId: cinemaId, sessionId: sessionId, selectedSeatJson: json)
//        }
//    }
	
//    fileprivate func confirmOrder(by orderConfirm: OrderConfirm) {
//        self.screenLogger.log("Request for set selected seat success!\n")
//        self.screenLogger.log("Get order confirm\n")
//        log.debug(orderConfirm)
//
//        DispatchQueue.global().async {
//            var message = ""
//            orderConfirm.ticketTypeList.enumerated().forEach { (index, ticketType) in
//                message += """
//                {
//                    "TicketDescriptEn": \(ticketType.ticketDescriptEn),
//                    "TicketDescriptCht": \(ticketType.ticketDescriptCht),
//                    "Quantity": \(ticketType.quantity),
//                    "TicketSumPrice": \(ticketType.ticketSumPrice)
//                }
//                """
//                message += ((orderConfirm.ticketTypeList.endIndex - 1) == index) ? "\n" : ",\n"
//            }
//
//            let info = """
//            {
//            "TicketTypeList": [
//                \(message)],
//                "CinemaId": \(orderConfirm.cinemaId),
//                "CinemaCName": \(orderConfirm.cinemaCName),
//                "CinemaEName": \(orderConfirm.cinemaEName),
//                "SeatId": \(orderConfirm.seatId),
//                "MovieCName": \(orderConfirm.movieCName),
//                "MovieEName": \(orderConfirm.movieEName),
//                "MovieShowTime": \(orderConfirm.movieShowTime),
//                "TotalValue": \(orderConfirm.totalValue),
//                "BookingFeeValue": \(orderConfirm.bookingFeeValue),
//                "TotalOrderCount": \(orderConfirm.totalOrderCount),
//                "TimeSpan": \(orderConfirm.timeSpan)
//            }\n\n
//            """
//            self.screenLogger.log(info)
//            self.screenLogger.log("============================\n\n")
//
//
//            guard let key = self.key else {
//                self.screenLogger.log("Key is not available...\n")
//
//                return
//            }
//
//            guard let cinemaId = self.cinemaId else {
//                self.screenLogger.log("Cinema Id is not available...\n")
//
//                return
//            }
//
//            guard let sessionId = self.sessionId else {
//                self.screenLogger.log("Session Id is not available...\n")
//
//                return
//            }
//
//            self.completeOrder(with: key, cinemaId: cinemaId, sessionId: sessionId, paymentValue: orderConfirm.totalValue)
//        }
//    }
//}

// MARK: -
// MARK: Timer and Thread

//extension ViewController {
	
    
//    internal func startGetAnnounce() {
//        /// Cancel previous timer if any
//        self.timer?.cancel()
//
//        self.timer = DispatchSource.makeTimerSource(queue: timerQueue)
//        self.timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
//
//        self.timer?.setEventHandler { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            self.getAnnounce()
//        }
//        self.timer?.resume()
//    }
	
//    internal func startGetShowTime(with key: String) {
//        /// Cancel previous timer if any
//        self.timer?.cancel()
//
//        self.timer = DispatchSource.makeTimerSource(queue: timerQueue)
//        self.timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
//
//        self.timer?.setEventHandler { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            self.getShowTime(with: key)
//        }
//        self.timer?.resume()
//    }
//
//    internal func startGetTicketTypes(with key: String, cinemaId: String, sessionId: String) {
//        /// Cancel previous timer if any
//        self.timer?.cancel()
//
//        self.timer = DispatchSource.makeTimerSource(queue: timerQueue)
//        self.timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
//
//        self.timer?.setEventHandler { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            self.getTicketTypes(with: key, cinemaId: cinemaId, sessionId: sessionId)
//        }
//        self.timer?.resume()
//    }
//
//    internal func startGetSessionSeatData(with key: String, cinemaId: String, sessionId: String, ticketTypeJson: String) {
//        /// Cancel previous timer if any
//        self.timer?.cancel()
//
//        self.timer = DispatchSource.makeTimerSource(queue: timerQueue)
//        self.timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
//
//        self.timer?.setEventHandler { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            self.getSessionSeatData(with: key, cinemaId: cinemaId, sessionId: sessionId, ticketTypeJson: ticketTypeJson)
//        }
//        self.timer?.resume()
//    }
	
//    internal func startSetSelectedSeat(with key: String, cinemaId: String, sessionId: String, selectedSeatJson: String) {
//        /// Cancel previous timer if any
//        self.timer?.cancel()
//
//        self.timer = DispatchSource.makeTimerSource(queue: timerQueue)
//        self.timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
//
//        self.timer?.setEventHandler { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            self.setSelectedSeat(with: key, cinemaId: cinemaId, sessionId: sessionId, selectedSeatJson: selectedSeatJson)
//        }
//        self.timer?.resume()
//    }
    
//    internal func startCompleteOrder(with key: String, cinemaId: String, sessionId: String, paymentValue: Int) {
//        /// Cancel previous timer if any
//        self.timer?.cancel()
//
//        self.timer = DispatchSource.makeTimerSource(queue: timerQueue)
//        self.timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
//
//        self.timer?.setEventHandler { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            self.completeOrder(with: key, cinemaId: cinemaId, sessionId: sessionId, paymentValue: paymentValue)
//        }
//        self.timer?.resume()
//    }
    
//    internal func stopAnyTimer() {
//        self.timer?.cancel()
//        self.timer = nil
//    }
//}

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
            self.message += message
            
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
	func didLoginCompleted(with token: String, authData: String) {
		let viewModel = MovieViewModel(token: token, authData: authData, sessionId: sessionId)
		viewModel.delegate = self
		viewModel.logger = self
		self.viewModel = viewModel
	}
}

extension ViewController: MovieViewModelDelegate {
	func didGetMovieSession(movieSession: MovieSession) {
		self.movieSession = movieSession
		log("Trying to get the best movie session...\n")
		guard let targetDate = targetMovieDateTimes.first else { return }
		guard let session = giveMeAGoodSession(movieSession: movieSession, forTargetDate: targetDate) else { return }
		log("Get the best movie session \(session.sessionId), at time \(session.showtime)")
		log("============================\n\n")
	}
	
	func giveMeAGoodSession(
		movieSession: MovieSession,
		forTargetDate targetDate: Date) -> MovieSession.ShowDate.Movie.Screen.Session?
	{
		guard let targetShowDateIndex = movieSession.data.showDates.firstIndex(where: { (showDate) -> Bool in
			guard let date = showDate.dateTime.date else { return false }
			return Calendar.current.isDate(date, inSameDayAs: targetDate)
		}) else { return nil }
		
		guard let targetMovie = movieSession.data.showDates[targetShowDateIndex].movies.first(where: { (movie) -> Bool in
			movie.titleAlt.contains(self.targetMovieName)
		}) else { return nil }
		
		guard let targetScreen = targetMovie.screens.first(where: { (screen) -> Bool in
			!screen.screenName.contains("IMAX")
		}) else { return nil }
		
		let timeOffsets = targetScreen.sessions.map { (session) -> Double? in
			guard let date = session.showtime.date else { return nil }
			return abs(targetDate.timeIntervalSince(date))
		}
		
		guard !timeOffsets.isEmpty else { return nil }
		var targetIndex: Int = 0
		var smallestTimeOffset: Double = 86400.0
		for (idx, offset) in timeOffsets.enumerated() {
			guard let offset = offset else { continue }
			guard offset < smallestTimeOffset else { continue }
			targetIndex = idx
			smallestTimeOffset = offset
		}
		
		let session = targetScreen.sessions[targetIndex]
		return session
	}
}
