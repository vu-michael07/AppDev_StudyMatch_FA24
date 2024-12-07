//
//  SettingsView.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class SettingsView: UIViewController {
    
    // MARK: - Properties (Data)
    private var currentUser: User? // Represents the currently logged-in user
    private var groups: [Group] = [] // All available groups
    private let onUpdate: (User, [Group]) -> Void // Callback to update data
    
    // MARK: - Properties (Views)
    private let userNameLabel = UILabel() // Displays the user's name
    private let netIDLabel = UILabel() // Displays the user's NetID
    private let groupsLabel = UILabel() // Displays the user's groups
    
    private let netIDTextField = UITextField() // TextField for NetID input
    private let findUserButton = UIButton(type: .system) // Button to find or create a user
    private var nameTextField: UITextField? // TextField for creating a new user
    private var createUserButton: UIButton? // Button to create the user
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
        fetchUserDetails() // Sync backend state
        displayUserInfo()  // Refresh UI
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
          
        // Delete User Button Setup
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
        
        // Left & Right columns for profile data
        let labelsStack = createProfileLabelsStackView()
        stackView.addArrangedSubview(labelsStack)
        
        // NetID entry section
        netIDTextField.placeholder = "Enter your NetID"
        netIDTextField.borderStyle = .roundedRect
        
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
        
        ["Username:", "NetID:", "Groups:"].forEach { label in
            let lbl = UILabel()
            lbl.text = label
            lbl.font = .systemFont(ofSize: 16, weight: .bold)
            leftColumn.addArrangedSubview(lbl)
        }
        
        rightColumn.addArrangedSubview(userNameLabel)
        rightColumn.addArrangedSubview(netIDLabel)
        rightColumn.addArrangedSubview(groupsLabel)
        
        labelsStack.addArrangedSubview(leftColumn)
        labelsStack.addArrangedSubview(rightColumn)
        return labelsStack
    }
    
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
    
    // MARK: - Fetch Data from API
    private func fetchGroups() {
        APIService.shared.fetch("/groups/", responseType: [Group].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedGroups):
                    self.groups = fetchedGroups
                    self.displayUserInfo() // Refresh the display
                case .failure(let error):
                    print("Error fetching groups:", error.localizedDescription)
                }
            }
        }
    }

    private func fetchUserDetails() {
        guard let currentUserID = UserSessionManager.shared.currentUser?.id else {
            print("No current user ID available.")
            return
        }
        
        APIService.shared.fetch("/users/\(currentUserID)", responseType: User.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUser):
                    self.currentUser = fetchedUser
                    UserSessionManager.shared.setCurrentUser(fetchedUser) // Track updated user
                    self.displayUserInfo()
                case .failure(let error):
                    print("Error fetching user details:", error.localizedDescription)
                }
            }
        }
    }

    
    // MARK: - Display User Info
    private func displayUserInfo() {
        guard let user = currentUser else {
            userNameLabel.text = "N/A"
            netIDLabel.text = "N/A"
            groupsLabel.text = "N/A"
            return
        }
        
        userNameLabel.text = user.name
        netIDLabel.text = user.netid
        
        let userGroups = groups.filter { $0.users.contains(where: { $0.id == user.id }) }
        groupsLabel.text = userGroups.isEmpty ? "None" : userGroups.map { $0.name }.joined(separator: ", ")
    }
    
    // MARK: - Actions
    @objc private func findOrCreateUser() {
        guard let netID = netIDTextField.text, !netID.isEmpty else {
            showAlert(title: "Error", message: "NetID cannot be empty.")
            return
        }
        
        // Correct API fetch using UserResponse
        APIService.shared.fetch("/users/", responseType: UserResponse.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let foundUser = response.users.first(where: { $0.netid == netID }) {
                        self.currentUser = foundUser
                        UserSessionManager.shared.setCurrentUser(foundUser) // Save the user session
                        self.onUpdate(foundUser, self.groups)
                        self.displayUserInfo()
                    } else {
                        self.setupNameInputField() // Show user creation UI
                    }
                case .failure(let error):
                    print("Error fetching users:", error.localizedDescription)
                }
            }
        }
    }

    @objc private func deleteUser() {
        guard let currentUserID = currentUser?.id else {
            showAlert(title: "Error", message: "No user to delete.")
            return
        }
        
        APIService.shared.delete("/users/\(currentUserID)/") { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("User deleted successfully.")
                    self.currentUser = nil
                    UserSessionManager.shared.clearCurrentUser()
                    self.displayUserInfo()
                case .failure(let error):
                    print("Error deleting user:", error.localizedDescription)
                    self.showAlert(title: "Error", message: "Failed to delete user.")
                }
            }
        }
    }

    @objc private func createUser() {
        guard let name = nameTextField?.text, !name.isEmpty,
              let netID = netIDTextField.text, !netID.isEmpty else {
            showAlert(title: "Error", message: "Both name and NetID are required.")
            return
        }
        
        let newUser = User(id: 0, name: name, netid: netID, group_id: nil)
        
        APIService.shared.create("/users/", payload: newUser as Encodable, responseType: User.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdUser):
                    self.currentUser = createdUser
                    UserSessionManager.shared.setCurrentUser(createdUser) // Track the user
                    self.onUpdate(createdUser, self.groups)
                    self.displayUserInfo()
                    
                    self.nameTextField?.removeFromSuperview()
                    self.createUserButton?.removeFromSuperview()
                    self.nameTextField = nil
                    self.createUserButton = nil
                case .failure(let error):
                    print("Error creating user:", error.localizedDescription)
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

