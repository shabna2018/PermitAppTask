//
//  AuthenticationManager.swift
//  PermitManager
//
//  Created by macbook on 01/08/25.
//

import SwiftUI
import Combine
import Foundation
import KeychainAccess

class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var loginErrorMessage: String?
    
    private let keychain = Keychain(service: "com.yourcompany.PermitManager")
    
    func login(username: String, password: String) {
        guard let url = URL(string: "https://test.deltafour.co/api/v1/auth/signin/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "password": password,
            "deviceId": "test",
            "appVersion": "125",
            "web": false
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to serialize login data: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.loginErrorMessage = "Login failed: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.loginErrorMessage = "Invalid server response"
                    return
                }
                
                guard httpResponse.statusCode == 200, let data = data else {
                    self.loginErrorMessage = "Login failed. Status code: \(httpResponse.statusCode)"
                    return
                }
                
                do {
                    let rawJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print("🔵 Server JSON response:", rawJSON ?? [:])
                    
                    if let token = rawJSON?["accessToken"] as? String,
                       let tokenType = rawJSON?["tokenType"] as? String {
                        let bearerToken = "\(tokenType) \(token)"
                        self.saveToken(bearerToken)
                        self.currentUser = User(username: username, role: .admin)
                        self.isAuthenticated = true
                        self.loginErrorMessage = nil
                        print("✅ Logged in. Saved token: \(bearerToken)")
                    } else {
                        self.loginErrorMessage = "Invalid response from server"
                    }
                    
                } catch {
                    self.loginErrorMessage = "Failed to parse response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func logout() {
        deleteToken()
        currentUser = nil
        isAuthenticated = false
    }
    
    func saveToken(_ token: String) {
        do {
            try keychain.set(token, key: "authToken")
        } catch {
            print("Error saving token to keychain: \(error)")
        }
    }
    
    func getToken() -> String? {
        do {
            return try keychain.get("authToken")
        } catch {
            print("Error reading token from keychain: \(error)")
            return nil
        }
    }
    
    func deleteToken() {
        do {
            try keychain.remove("authToken")
        } catch {
            print("Error deleting token from keychain: \(error)")
        }
    }
}
