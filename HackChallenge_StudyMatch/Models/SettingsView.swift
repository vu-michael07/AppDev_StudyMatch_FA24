//
//  SettingsView.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class SettingsView: UIViewController {
    
    // MARK: - Properties (Data)
    private var currentUser: User?
    private var groups: [Group] = []
    private let onUpdate: (User, [Group]) -> Void
    
    // MARK: - Properties (Views)
    private let userNameLabel = UILabel()
    private let netIDLabel = UILabel()
    
    private let netIDTextField = UITextField()
    private let findUserButton = UIButton(type: .system)
    private var nameTextField: UITextField?
    private var createUserButton: UIButton?
    private let deleteUserButton = UIButton(type: .system)
    
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
        fetchGroups()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserDetails()
        displayUserInfo()
    }
    
    // MARK: - Setup Views
    private func setupView() {
        let stackView = createProfileStackView()
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        styleButton(deleteUserButton, title: "Delete User")
        deleteUserButton.backgroundColor = .red
        deleteUserButton.addTarget(self, action: #selector(deleteUser), for: .touchUpInside)
        
        view.addSubview(deleteUserButton)
        deleteUserButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            deleteUserButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            deleteUserButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteUserButton.widthAnchor.constraint(equalToConstant: 180),
            deleteUserButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createProfileStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        
        let labelsStack = createProfileLabelsStackView()
        stackView.addArrangedSubview(labelsStack)
        
        netIDTextField.placeholder = "Enter your NetID"
        netIDTextField.borderStyle = .roundedRect
        netIDTextField.autocapitalizationType = .none
        
        styleButton(findUserButton, title: "Find or Create")
        findUserButton.addTarget(self, action: #selector(findOrCreateUser), for: .touchUpInside)
        
        let netIDStack = UIStackView(arrangedSubviews: [netIDTextField, findUserButton])
        netIDStack.axis = .horizontal
        netIDStack.spacing = 8
        
        stackView.addArrangedSubview(netIDStack)
        return stackView
    }
    
    private func createProfileLabelsStackView() -> UIStackView {
        let labelsStack = UIStackView()
        labelsStack.axis = .horizontal
        labelsStack.spacing = 16
        labelsStack.distribution = .fillEqually
        
        let leftColumn = UIStackView()
        leftColumn.axis = .vertical
        leftColumn.spacing = 8
        
        let rightColumn = UIStackView()
        rightColumn.axis = .vertical
        rightColumn.spacing = 8
        
        ["Username:", "NetID:"].forEach { label in
            let lbl = UILabel()
            lbl.text = label
            lbl.font = .systemFont(ofSize: 16, weight: .bold)
            leftColumn.addArrangedSubview(lbl)
        }
        
        rightColumn.addArrangedSubview(userNameLabel)
        rightColumn.addArrangedSubview(netIDLabel)
        
        labelsStack.addArrangedSubview(leftColumn)
        labelsStack.addArrangedSubview(rightColumn)
        return labelsStack
    }
    
    private func setupNameInputField() {
        guard nameTextField == nil, createUserButton == nil else { return }
        
        let nameTextField = UITextField()
        nameTextField.placeholder = "Enter your name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.autocapitalizationType = .none
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
    
    // MARK: - Fetch Data from API
    private func fetchGroups() {
        APIService.shared.fetch("/groups/", responseType: [Group].self) { result in
            DispatchQueue.main.async {
                if case let .success(fetchedGroups) = result {
                    self.groups = fetchedGroups
                    self.displayUserInfo()
                }
            }
        }
    }

    private func fetchUserDetails() {
        guard let currentUserID = UserSessionManager.shared.currentUser?.id else { return }
        
        APIService.shared.fetch("/users/\(currentUserID)", responseType: User.self) { result in
            DispatchQueue.main.async {
                if case let .success(fetchedUser) = result {
                    self.currentUser = fetchedUser
                    UserSessionManager.shared.setCurrentUser(fetchedUser)
                    self.displayUserInfo()
                }
            }
        }
    }
    
    // MARK: - Display User Info
    private func displayUserInfo() {
        guard let user = currentUser else {
            userNameLabel.text = "N/A"
            netIDLabel.text = "N/A"
            return
        }
        userNameLabel.text = user.name
        netIDLabel.text = user.netid
    }
    
    // MARK: - Actions
    @objc private func findOrCreateUser() {
        guard let netID = netIDTextField.text, !netID.isEmpty else {
            showAlert(title: "Error", message: "NetID cannot be empty.")
            return
        }
        
        APIService.shared.fetch("/users/", responseType: UserResponse.self) { result in
            DispatchQueue.main.async {
                if case let .success(response) = result,
                   let foundUser = response.users.first(where: { $0.netid == netID }) {
                    
                    self.currentUser = foundUser
                    UserSessionManager.shared.setCurrentUser(foundUser)
                    self.onUpdate(foundUser, self.groups)
                    self.displayUserInfo()
                } else {
                    self.setupNameInputField()
                }
            }
        }
    }

    @objc private func deleteUser() {
        guard let currentUserID = currentUser?.id else { return }
        
        APIService.shared.delete("/users/\(currentUserID)/") { result in
            DispatchQueue.main.async {
                if case .success = result {
                    self.currentUser = nil
                    UserSessionManager.shared.clearCurrentUser()
                    self.displayUserInfo()
                }
            }
        }
    }

    @objc private func createUser() {
        guard let name = nameTextField?.text, !name.isEmpty, let netID = netIDTextField.text, !netID.isEmpty else { return }
        
        let newUser = User(id: 0, name: name, netid: netID)
        APIService.shared.create("/users/", payload: newUser, responseType: User.self) { result in
            DispatchQueue.main.async {
                if case let .success(createdUser) = result {
                    self.currentUser = createdUser
                    UserSessionManager.shared.setCurrentUser(createdUser)
                    self.onUpdate(createdUser, self.groups)
                    self.displayUserInfo()
                }
            }
        }
    }

    // MARK: - Utility
    private func styleButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
