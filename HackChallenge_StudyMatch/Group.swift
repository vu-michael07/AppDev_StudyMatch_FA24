//
//  Group.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//


import Foundation

struct Group: Identifiable, Codable {
    let id: Int
    let name: String
    var users: [User]
    var rates: [Rate]
    let tasks: [Task]
}

struct User: Identifiable, Codable {
    let id: Int
    var name: String
    let netid: String
    let group_id: Int?
    var rates: [Rate]
}


struct Task: Identifiable, Codable {
    let id: Int
    let task_name: String
    let description: String
    let due_date: String
    let group_id: Int
}

struct Rate: Identifiable, Codable {
    let id: Int
    let stars: Int
    var users: [User]
    var groups: [Group]
}

struct Post: Identifiable, Codable {
    let id: Int
    let post_name: String
    let description: String
    let timestamp: String
    let comments: [Comment]
}

struct Comment: Identifiable, Codable {
    let id: Int
    let description: String
    let timestamp: String
    let post_id: Int
}



