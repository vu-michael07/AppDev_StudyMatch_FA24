//
//  SceneDelegate.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//


import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

        // Check if there is a current user
        if let currentUser = UserSessionManager.shared.currentUser {
            // If user exists, proceed to HomeViewController
            let homeVC = HomeViewController()
            let navController = UINavigationController(rootViewController: homeVC)
            window?.rootViewController = navController
        } else {
            // No user, force profile creation in SettingsView
            presentSettingsView()
        }
        
        window?.makeKeyAndVisible()
    }

    private func presentSettingsView() {
        let settingsVC = SettingsView(currentUser: nil, groups: []) { [weak self] updatedUser, updatedGroups in
            UserSessionManager.shared.setCurrentUser(updatedUser)
            self?.transitionToHomeViewController()
        }
        let navController = UINavigationController(rootViewController: settingsVC)
        window?.rootViewController = navController
    }
    
    private func transitionToHomeViewController() {
        let homeVC = HomeViewController()
        let navController = UINavigationController(rootViewController: homeVC)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }

    // Default scene lifecycle methods
    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}

