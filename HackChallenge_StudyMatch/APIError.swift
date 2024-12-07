//
//  APIError.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/7/24.
//


import Foundation

enum APIError: LocalizedError {
    case badURL
    case requestFailed
    case decodingError
    case encodingError
    case missingData
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "The URL provided was invalid."
        case .requestFailed:
            return "The request failed. Please check your internet connection."
        case .decodingError:
            return "Failed to decode the server response."
        case .encodingError:
            return "Failed to encode the request payload."
        case .missingData:
            return "No data received from the server."
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)."
        }
    }
}


class APIService {
    static let shared = APIService()
    var currentUser: User?
    private let baseURL = "http://35.221.42.253"
    
    private init() {}
    
    // Generic Fetch Request
    func fetch<T: Decodable>(_ endpoint: String, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed))
                print("Network Error:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.missingData))
                return
            }
            
            // Print Raw Response for Debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response:", rawResponse)
            } else {
                print("Failed to convert data to string.")
            }
            
            // Inside APIService fetch method
            print("Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid Data")

            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError))
                print("Decoding Error:", error.localizedDescription)
            }
        }.resume()
    }



}

// MARK: - POST, PUT, DELETE Requests
extension APIService {
    
    func create<T: Decodable>(_ endpoint: String, payload: Encodable, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(payload)
            request.httpBody = jsonData
        } catch {
            completion(.failure(.encodingError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed))
                print("Network Error:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.missingData))
                return
            }
            
            // Debug the raw response
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response:", rawResponse)
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError))
                print("Decoding Error:", error.localizedDescription)
            }
        }.resume()
    }
    
    
    // Generic PUT Request
    func update<T: Decodable>(_ endpoint: String, payload: Encodable, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(payload)
            request.httpBody = jsonData
        } catch {
            completion(.failure(.encodingError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed))
                print("Network Error:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.missingData))
                return
            }
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response:", rawResponse)
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError))
                print("Decoding Error:", error.localizedDescription)
            }
        }.resume()
    }
    
    func sendRequest<T: Decodable>(
        endpoint: String,
        method: String,
        body: Data?,
        responseType: T.Type,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.badURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed))
                print("Request Error:", error.localizedDescription)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.failure(.httpError(statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(.missingData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding Error:", error.localizedDescription)
                completion(.failure(.decodingError))
            }
        }.resume()
    }

    
    
    // Generic Delete Request (DELETE)
    // MARK: - DELETE Request
    func delete(_ endpoint: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(.requestFailed))
                print("Network Error:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(()))
            } else {
                completion(.failure(.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)))
            }
        }.resume()
    }
}
