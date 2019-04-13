//
//  TaskStateView.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/12.
//  Copyright © 2019 Wayne. All rights reserved.
//

import UIKit

class TaskStateView: UIView {
	
	private struct Layout {
		static let margins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
	}
	
	var tasks: [Task]
	
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.addSubview(stackview)
		stackview.snp.makeConstraints { (maker) in
			maker.edges.equalToSuperview()
			maker.width.equalTo(scrollView.snp.width)
		}
		return scrollView
	}()
	
	private lazy var stackview: UIStackView = {
		let stackview = UIStackView()
		stackview.alignment = .fill
		stackview.distribution = .fillProportionally
		stackview.axis = .vertical
		stackview.spacing = 10
		stackview.isLayoutMarginsRelativeArrangement = true
		stackview.layoutMargins = Layout.margins
		return stackview
	}()
	
	init(with tasks: [Task]) {
		self.tasks = tasks
		super.init(frame: .zero)
		initialize()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func initialize() {
		addSubview(scrollView)
		scrollView.snp.makeConstraints { (maker) in
			maker.edges.equalToSuperview()
		}
		
		for task in tasks {
			if let multipleTask = task as? MultipleTask {
				let taskView = MultipleTaskView(with: multipleTask)
				stackview.addArrangedSubview(taskView)
			} else {
				let taskView = TaskView(with: task)
				stackview.addArrangedSubview(taskView)
			}
		}
	}
}

extension TaskStateView {
	
	class TaskView: UIView {
		
		private struct Layout {
			static let margins = UIEdgeInsets(top: 24, left: 12, bottom: 24, right: 12)
		}
		
		private weak var task: Task!
		
		private lazy var stackview: UIStackView = {
			let stackview = UIStackView(arrangedSubviews: [checkboxImageView, taskLabel])
			stackview.alignment = .fill
			stackview.distribution = .fillProportionally
			stackview.axis = .horizontal
			stackview.spacing = 10
			return stackview
		}()
		
		private lazy var checkboxImageView: UIImageView = {
			let imageView = UIImageView(image: UIImage(named: "check.box.empty")?.templateRendered)
			imageView.tintColor = task.textColors[task.state]
			return imageView
		}()
		
		private lazy var taskLabel: UILabel = {
			let label = UILabel()
			label.text = task.task
			label.textColor = task.textColors[task.state]
			label.font = .defaultDisplayFont(ofSize: 16)
			label.textAlignment = .center
			return label
		}()
		
		init(with task: Task) {
			self.task = task
			super.init(frame: .zero)
			initialize(with: task)
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func initialize(with task: Task) {
			backgroundColor = task.stateColors[task.state]
			layer.cornerRadius = 4.0
			applyShadow(style: .light)
			
			addSubview(stackview)
			stackview.snp.makeConstraints { (maker) in
				maker.center.equalToSuperview()
				maker.top.greaterThanOrEqualToSuperview().inset(Layout.margins.top).priority(999)
				maker.bottom.greaterThanOrEqualToSuperview().inset(Layout.margins.bottom).priority(999)
			}
			
			task.stateChangeHandler = { [weak self] state in
				guard let self = self else { return }
				DispatchQueue.main.async {
					UIView.transition(with: self.taskLabel, duration: 0.25, options: .curveEaseInOut, animations: {
						self.taskLabel.textColor = task.textColors[task.state]
					}, completion: nil)
					
					UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
						self.backgroundColor = task.stateColors[task.state]
						self.checkboxImageView.tintColor = task.textColors[task.state]
						self.checkboxImageView.image = self.image(for: task)
					}, completion: nil)
				}
			}
		}
		
		private func image(for task: Task) -> UIImage? {
			switch task.state {
			case .success:
				return UIImage(named: "check.box.checked")?.templateRendered
			default:
				return UIImage(named: "check.box.empty")?.templateRendered
			}
		}
	}
	
	class MultipleTaskView: UIView {
		
		private struct Layout {
			static let margins = UIEdgeInsets(top: 24, left: 12, bottom: 24, right: 12)
		}
		
		private weak var tasks: MultipleTask!
		
		private lazy var stackview: UIStackView = {
			let stackview = UIStackView()
			stackview.alignment = .fill
			stackview.distribution = .fillEqually
			stackview.axis = .horizontal
			stackview.spacing = 8.0
			return stackview
		}()
		
		init(with tasks: MultipleTask) {
			self.tasks = tasks
			super.init(frame: .zero)
			initialize(with: tasks)
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func initialize(with tasks: MultipleTask) {
			addSubview(stackview)
			stackview.snp.makeConstraints { (maker) in
				maker.edges.equalToSuperview()
			}
			
			for task in tasks.subtasks {
				let taskView = TaskView(with: task)
				stackview.addArrangedSubview(taskView)
			}
		}
	}
}

extension TaskStateView {
	
	class Task {
		let task: String
		var state: State {
			didSet {
				guard state != oldValue else { return }
				stateChangeHandler?(state)
			}
		}
		let stateColors: [State: UIColor]
		let textColors: [State: UIColor]
		var stateChangeHandler: ((State) -> Void)?
		
		init(task: String, state: State, stateColors: [State: UIColor], textColors: [State: UIColor]) {
			self.task = task
			self.state = state
			self.stateColors = stateColors
			self.textColors = textColors
		}
	}
	
	class MultipleTask: Task {
		var subtasks: [Task] = []
		
		override var state: TaskStateView.Task.State {
			didSet { subtasks.forEach { $0.state = state } }
		}
	}
}

extension TaskStateView.Task {
	
	enum State: String, Hashable {
		case waiting
		case running
		case success
		case failed
		
		var hashValue: Int {
			return rawValue.hashValue
		}
	}
}

extension TaskStateView.Task {
	
	static let defaultColors: [State: UIColor] = [
		.waiting: .white,
		.running: UIColor.cobinhood.blueGrey,
		.success: UIColor.cobinhood.green,
		.failed: UIColor.cobinhood.red
	]
	
	static let defaultTextColors: [State: UIColor] = [
		.waiting: .black,
		.running: .black,
		.success: .white,
		.failed: .white
	]
	
	static func waiting(task: String) -> TaskStateView.Task {
		return TaskStateView.Task(task: task, state: .waiting, stateColors: defaultColors, textColors: defaultTextColors)
	}
	
	static func running(task: String) -> TaskStateView.Task {
		return TaskStateView.Task(task: task, state: .running, stateColors: defaultColors, textColors: defaultTextColors)
	}
	
	static func success(task: String) -> TaskStateView.Task {
		return TaskStateView.Task(task: task, state: .success, stateColors: defaultColors, textColors: defaultTextColors)
	}
	
	static func failed(task: String) -> TaskStateView.Task {
		return TaskStateView.Task(task: task, state: .failed, stateColors: defaultColors, textColors: defaultTextColors)
	}
}

extension TaskStateView.MultipleTask {
	
	static func waiting(tasks: [TaskStateView.Task]) -> TaskStateView.MultipleTask {
		let multipleTask = TaskStateView.MultipleTask(task: "", state: .waiting, stateColors: defaultColors, textColors: defaultTextColors)
		multipleTask.subtasks = tasks
		return multipleTask
	}
	
	static func running(tasks: [TaskStateView.Task]) -> TaskStateView.MultipleTask {
		let multipleTask = TaskStateView.MultipleTask(task: "", state: .running, stateColors: defaultColors, textColors: defaultTextColors)
		multipleTask.subtasks = tasks
		return multipleTask
	}
	
	static func success(tasks: [TaskStateView.Task]) -> TaskStateView.MultipleTask {
		let multipleTask = TaskStateView.MultipleTask(task: "", state: .success, stateColors: defaultColors, textColors: defaultTextColors)
		multipleTask.subtasks = tasks
		return multipleTask
	}
	
	static func failed(tasks: [TaskStateView.Task]) -> TaskStateView.MultipleTask {
		let multipleTask = TaskStateView.MultipleTask(task: "", state: .failed, stateColors: defaultColors, textColors: defaultTextColors)
		multipleTask.subtasks = tasks
		return multipleTask
	}
}
