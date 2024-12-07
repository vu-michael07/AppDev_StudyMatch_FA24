//
//  Group.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//


import Foundation

struct UserResponse: Codable {
    let users: [User]
}

struct User: Identifiable, Codable {
    let id: Int
    let name: String
    let netid: String
    var group_id: Int?
}




struct Task: Identifiable, Codable {
    let id: Int
    let task_name: String
    let task_description: String
    let due_date: String
    let group_id: Int
}

struct TaskCreationPayload: Encodable {
    let task_name: String
    let task_description: String
    let due_date: String
    let group_id: Int
}


struct GroupUpdatePayload: Codable {
    let group_id: Int?
}


struct GroupResponse: Codable {
    let groups: [Group]
}

struct Group: Identifiable, Codable {
    let id: Int
    let name: String
    var users: [User]
    var tasks: [Task]
}



struct PostResponse: Decodable {
    let posts: [Post]
}

struct Post: Identifiable, Codable {
    let id: Int
    let postName: String
    let postDescription: String
    let timestamp: String
    var comments: [Comment]

    enum CodingKeys: String, CodingKey {
        case id
        case postName = "post_name"
        case postDescription = "post_description"
        case timestamp, comments
    }
}




struct Comment: Identifiable, Codable {
    let id: Int
    let description: String
    let timestamp: String
    let postID: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case description = "comment_description"  
        case timestamp
        case postID = "post_id"
    }
}







