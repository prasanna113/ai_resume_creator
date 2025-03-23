//
//  APIService.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 20/03/25.
//

import Foundation

struct APIService {
    static let baseURL = "http://192.168.1.63:8000" // Replace with your backend URL
    
    // Check if User Exists
    static func checkUserExists(email: String, completion: @escaping (Bool) -> Void) {
        let queryParams = "email=\(email)"
        let urlString = "\(baseURL)/user/exists/?" + queryParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error checking user existence: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = data else {
                completion(false)
                return
            }

            if let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let exists = responseJSON["exists"] as? Bool {
                completion(exists)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    // User Registration
    static func register(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/user/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success("User registered successfully!"))
        }.resume()
    }
    
    // User Login
    static func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/user/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "username=\(email)&password=\(password)".data(using: .utf8)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            if let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = responseJSON["access_token"] as? String {
                UserDefaults.standard.set(token, forKey: "jwtToken")
                completion(.success(token))
            } else {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
            }
        }.resume()
    }
    
    // Generate Resume
    static func generateResume(fullName: String, experience: String, skills: String, jobTitle: String, jobDescription: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        // ✅ Encode query parameters into the URL
        let queryParams = "full_name=\(fullName)&experience=\(experience)&skills=\(skills)&job_title=\(jobTitle)&job_description=\(jobDescription)"
        let urlString = "\(baseURL)/resume/?" + queryParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            if let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let resumeText = responseJSON["resume"] as? String {
                completion(.success(resumeText))
            } else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to generate resume"])))
            }
        }.resume()
    }
    
    // Generate Cover Letter with Query Parameters
    static func generateCoverLetter(fullName: String, experience: String, jobTitle: String, jobDescription: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let queryParams = "full_name=\(fullName)&experience=\(experience)&job_title=\(jobTitle)&job_description=\(jobDescription)"
        let urlString = "\(baseURL)/cover_letter/?" + queryParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            if let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let coverLetterText = responseJSON["cover_letter"] as? String {
                completion(.success(coverLetterText))
            } else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to generate cover letter"])))
            }
        }.resume()
    }
    
    // ✅ Validate Email Activation Code
    static func validateEmail(email: String, code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "\(baseURL)/user/activate"  // ✅ Ensure this matches FastAPI
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // ✅ Keep POST method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")  // ✅ Set JSON header

        let body: [String: Any] = ["email": email, "code": code]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No response data"])))
                return
            }

            if let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = responseJSON["message"] as? String {
                completion(.success(message))
            } else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to validate email"])))
            }
        }.resume()
    }
}
