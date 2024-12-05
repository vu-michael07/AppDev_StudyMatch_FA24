//
//  GroupDetailViewController.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class GroupDetailViewController: UIViewController {
    
    // MARK: - Properties (views)
    
    private let scrollView = UIScrollView()
    private let groupRatingLabel = UILabel()
    private let groupRatingTextField = UITextField()
    private let groupRateButton = UIButton(type: .system)
    private let peopleStackView = UIStackView()
    private let tasksStackView = UIStackView()
    
    // MARK: - Properties (data)
    
    private var group: Group
    
    // MARK: - Init
    
    init(group: Group) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = group.name
        setupScrollView()
        setupGroupRating()
        setupPeopleSection()
        setupTasksSection()
    }
    
    // MARK: - Setup Views
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        contentView.addSubview(groupRatingLabel)
        contentView.addSubview(groupRatingTextField)
        contentView.addSubview(groupRateButton)
        contentView.addSubview(peopleStackView)
        contentView.addSubview(tasksStackView)
        
        groupRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        groupRatingTextField.translatesAutoresizingMaskIntoConstraints = false
        groupRateButton.translatesAutoresizingMaskIntoConstraints = false
        peopleStackView.translatesAutoresizingMaskIntoConstraints = false
        tasksStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            groupRatingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            groupRatingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            groupRatingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            groupRatingTextField.topAnchor.constraint(equalTo: groupRatingLabel.bottomAnchor, constant: 8),
            groupRatingTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            groupRatingTextField.widthAnchor.constraint(equalToConstant: 100),
            groupRatingTextField.heightAnchor.constraint(equalToConstant: 40),
            
            groupRateButton.centerYAnchor.constraint(equalTo: groupRatingTextField.centerYAnchor),
            groupRateButton.leadingAnchor.constraint(equalTo: groupRatingTextField.trailingAnchor, constant: 8),
            groupRateButton.widthAnchor.constraint(equalToConstant: 80),
            groupRateButton.heightAnchor.constraint(equalToConstant: 40),
            
            peopleStackView.topAnchor.constraint(equalTo: groupRatingTextField.bottomAnchor, constant: 16),
            peopleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            peopleStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tasksStackView.topAnchor.constraint(equalTo: peopleStackView.bottomAnchor, constant: 32),
            tasksStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tasksStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tasksStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupGroupRating() {
        let averageRating = group.rates.isEmpty ? "N/A" : String(format: "%.2f", Double(group.rates.map { $0.stars }.reduce(0, +)) / Double(group.rates.count))
        groupRatingLabel.text = "Average Group Rating: \(averageRating)"
        groupRatingLabel.font = .boldSystemFont(ofSize: 20)
        groupRatingLabel.textAlignment = .center
        
        groupRatingTextField.placeholder = "Rate 0-10"
        groupRatingTextField.borderStyle = .roundedRect
        groupRatingTextField.keyboardType = .numberPad
        
        groupRateButton.setTitle("Rate", for: .normal)
        groupRateButton.backgroundColor = .red
        groupRateButton.setTitleColor(.white, for: .normal)
        groupRateButton.layer.cornerRadius = 5
        groupRateButton.addTarget(self, action: #selector(rateGroup), for: .touchUpInside)
    }
    
    private func setupPeopleSection() {
        peopleStackView.axis = .vertical
        peopleStackView.spacing = 16
        
        let peopleLabel = UILabel()
        peopleLabel.text = "People"
        peopleLabel.font = .boldSystemFont(ofSize: 20)
        peopleLabel.textAlignment = .center
        
        peopleStackView.addArrangedSubview(peopleLabel)
        
        for user in group.users {
            let personView = PersonView(user: user, groups: MockData.groups)
            peopleStackView.addArrangedSubview(personView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let updatedGroup = MockData.groups.first(where: { $0.id == group.id }) {
            self.group = updatedGroup
        }
        
        setupGroupRating()
        setupPeopleSection()
    }
    
    private func setupTasksSection() {
        tasksStackView.axis = .vertical
        tasksStackView.spacing = 16
        
        let tasksLabel = UILabel()
        tasksLabel.text = "Tasks"
        tasksLabel.font = .boldSystemFont(ofSize: 20)
        tasksLabel.textAlignment = .center
        
        tasksStackView.addArrangedSubview(tasksLabel)
        
        for task in group.tasks {
            let taskView = TaskView(task: task)
            tasksStackView.addArrangedSubview(taskView)
        }
    }
    
    // MARK: - Actions
    
    @objc private func rateGroup() {
        guard let text = groupRatingTextField.text,
              let rating = Int(text), rating >= 0, rating <= 10 else {
            groupRateButton.setTitle("Failed", for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.groupRateButton.setTitle("Rate", for: .normal)
            }
            return
        }
        
        if let groupIndex = MockData.groups.firstIndex(where: { $0.id == group.id }) {
            let newRate = Rate(id: MockData.rates.count + 1, stars: rating, users: [], groups: [MockData.groups[groupIndex]])
            MockData.groups[groupIndex].rates.append(newRate)
            MockData.rates.append(newRate)
            
            group = MockData.groups[groupIndex]
        }
        
        groupRatingTextField.text = ""
        groupRateButton.setTitle("Success", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.groupRateButton.setTitle("Rate", for: .normal)
        }
        
        setupGroupRating()
    }
}

