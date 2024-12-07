//
//  SettingsView.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class SettingsView: UIViewController {
    
    // MARK: - Properties (data)
    private var currentUser: User? // Represents the currently logged-in user
    private let groups: [Group] // All available groups
    private let onUpdate: (User, [Group]) -> Void // Callback to update data when changes occur
    
    // MARK: - Properties (views)
    private let userNameLabel = UILabel() // Displays the user's name
    private let netIDLabel = UILabel() // Displays the user's NetID
    private let groupsLabel = UILabel() // Displays the groups the user belongs to
    
    private let netIDTextField = UITextField() // Text field for entering the NetID
    private let findUserButton = UIButton(type: .system) // Button to find or create a user
    private var nameTextField: UITextField? // Text field for entering the name
    private var createUserButton: UIButton? // Button to create a new user
    
    // MARK: - Init
    init(currentUser: User?, groups: [Group], onUpdate: @escaping (User, [Group]) -> Void) {
        self.currentUser = currentUser
        self.groups = groups
        self.onUpdate = onUpdate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Profile"
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Sync the current user with the mock database
        if let updatedUser = MockData.users.first(where: { $0.id == MockData.currentUser.id }) {
            currentUser = updatedUser
        }
        
        // Refresh the UI
        displayUserInfo()
    }
    
    // MARK: - Setup Views
    
    private func setupView() {
        let stackView = UIStackView() // Profile information
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        
        // Substack for labels and data
        let labelsStack = UIStackView()
        labelsStack.axis = .horizontal
        labelsStack.spacing = 16
        labelsStack.distribution = .fillEqually
        
        let leftColumn = UIStackView()
        leftColumn.axis = .vertical
        leftColumn.spacing = 8
        leftColumn.alignment = .leading
        
        let rightColumn = UIStackView()
        rightColumn.axis = .vertical
        rightColumn.spacing = 8
        rightColumn.alignment = .leading
        
        // Left column labels
        let labels = ["Username:", "NetID:", "Groups:"]
        for label in labels {
            let lbl = UILabel()
            lbl.text = label
            lbl.font = .systemFont(ofSize: 16, weight: .bold)
            leftColumn.addArrangedSubview(lbl)
        }
        
        // Right column placeholders
        rightColumn.addArrangedSubview(userNameLabel)
        rightColumn.addArrangedSubview(netIDLabel)
        rightColumn.addArrangedSubview(groupsLabel)
        
        labelsStack.addArrangedSubview(leftColumn)
        labelsStack.addArrangedSubview(rightColumn)
        stackView.addArrangedSubview(labelsStack)
        
        // Add NetID input
        netIDTextField.placeholder = "Enter your NetID"
        netIDTextField.borderStyle = .roundedRect
        
        styleButton(findUserButton, title: "Find or Create")
        findUserButton.addTarget(self, action: #selector(findOrCreateUser), for: .touchUpInside)
        
        let netIDStack = UIStackView(arrangedSubviews: [netIDTextField, findUserButton])
        netIDStack.axis = .horizontal
        netIDStack.spacing = 8
        stackView.addArrangedSubview(netIDStack)
        
        // Add stack
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // "Create User"
    private func setupNameInputField() {
        guard nameTextField == nil, createUserButton == nil else { return }
        
        let nameTextField = UITextField()
        nameTextField.placeholder = "Enter your name"
        nameTextField.borderStyle = .roundedRect
        self.nameTextField = nameTextField
        
        let createUserButton = UIButton(type: .system)
        styleButton(createUserButton, title: "Create User")
        createUserButton.addTarget(self, action: #selector(createUser), for: .touchUpInside)
        self.createUserButton = createUserButton
        
        let nameStack = UIStackView(arrangedSubviews: [nameTextField, createUserButton])
        nameStack.axis = .horizontal
        nameStack.spacing = 8
        
        view.addSubview(nameStack)
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameStack.topAnchor.constraint(equalTo: netIDTextField.bottomAnchor, constant: 16),
            nameStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Display User Information
    
    // Population
    private func displayUserInfo() {
        guard let user = currentUser else {
            userNameLabel.text = "N/A"
            netIDLabel.text = "N/A"
            groupsLabel.text = "N/A"
            return
        }

        userNameLabel.text = user.name
        netIDLabel.text = user.netid

        // Groups
        let userGroups = MockData.groups.filter { $0.users.contains(where: { $0.id == user.id }) }
        groupsLabel.text = userGroups.isEmpty
            ? "None"
            : userGroups.map { $0.name }.joined(separator: ", ")
    }
    
    // MARK: - Actions
    
    // Creation or finding a user
    @objc private func findOrCreateUser() {
        guard let netID = netIDTextField.text, !netID.isEmpty else {
            showAlert(title: "Error", message: "NetID cannot be empty.")
            return
        }
        
        if let existingUser = MockData.users.first(where: { $0.netid == netID }) {
            currentUser = existingUser
            MockData.currentUser = existingUser // Sync
            onUpdate(existingUser, groups)
            displayUserInfo()
        } else {
            setupNameInputField()
        }
    }
    
    // Creation
    @objc private func createUser() {
        guard let name = nameTextField?.text, !name.isEmpty,
              let netID = netIDTextField.text, !netID.isEmpty else {
            showAlert(title: "Error", message: "Both name and NetID are required.")
            return
        }
        
        let newUser = User(
            id: MockData.users.count + 1,
            name: name,
            netid: netID,
            group_id: nil
        )
        
        MockData.users.append(newUser)
        currentUser = newUser
        MockData.currentUser = newUser // Sync
        onUpdate(newUser, groups)
        displayUserInfo()
        
        // Remove temporary UI
        nameTextField?.removeFromSuperview()
        createUserButton?.removeFromSuperview()
        nameTextField = nil
        createUserButton = nil
    }
    
    // MARK: - Utility
    
    // Button styling helper
    private func styleButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    // Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
