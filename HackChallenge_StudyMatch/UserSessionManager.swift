//
//  UserSessionManager.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/7/24.
//


// UserSessionManager.swift

import Foundation

final class UserSessionManager {
    static let shared = UserSessionManager()
    
    private(set) var currentUser: User?
    
    private init() {}
    
    func setCurrentUser(_ user: User) {
        currentUser = user
    }
    
    func clearCurrentUser() {
        currentUser = nil
    }
}
