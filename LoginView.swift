//
//  LoginView.swift
//  PermitManager
//
//  Created by macbook on 01/08/25.
//
import SwiftUI
import Combine
import Foundation

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Site Inspector")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Permit Management System")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.headline)
                        TextField("Enter username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.never)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        SecureField("Enter password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button(action: login) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Demo Credentials:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Username: inspector1, supervisor1, or admin1")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Password: demo123")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Login")
            .alert("Login Failed", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text("Invalid username or password")
            }
        }
    }
    
    private func login() {
        if !authManager.login(username: username, password: password) {
            showError = true
        }
    }
}
