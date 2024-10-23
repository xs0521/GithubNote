//
//  GitHubLoginView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/13.
//

import SwiftUI
import AuthenticationServices

fileprivate let clientID = "Ov23liFKH5Ro2ZweAEoZ"
fileprivate let clientSecret = "dc7b96ec1d9bc95f99e68648ad9f7614beac961e"
fileprivate let redirectURI = "githubnote://callback"

struct GitHubLoginView: View {
    
    @State private var isLoading: Bool = false
    
    var loginCallBack: CommonCallBack
    
    var body: some View {
        VStack {
            Image("app_logo")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(8)
                .padding(.bottom, 100)
            ZStack {
                Button(action: {
                    startGitHubLogin()
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Login with GitHub")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
                if isLoading {
                    ProgressView()
                        .controlSize(.mini)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .frame(width: 800, height: 400)
        .padding()
    }
    
    private func startGitHubLogin() {
        
        let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientID)&scope=read:user,repo,write:discussion&redirect_uri=\(redirectURI)")!
        
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "githubnote") { callbackURL, error in
            guard error == nil, let callbackURL = callbackURL else {
                print("Login failed")
                return
            }
            
            // Parse the callback URL for the authorization code
            if let urlComponents = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
               let queryItems = urlComponents.queryItems,
               let code = queryItems.first(where: { $0.name == "code" })?.value {
                // Exchange code for access token
                exchangeCodeForAccessToken(code: code)
            }
        }
        
        GitHubLoginManager.shared.controller = GitHubLoginViewController()
        session.presentationContextProvider = GitHubLoginManager.shared.controller
        session.start()
    }
    
    private func exchangeCodeForAccessToken(code: String) {
        
        isLoading = true
        
        let tokenURL = URL(string: "https://github.com/login/oauth/access_token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        let body = "client_id=\(clientID)&client_secret=\(clientSecret)&code=\(code)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let tokenResponse = try? JSONDecoder().decode(GitHubTokenResponse.self, from: data)
                {
                let accessToken = tokenResponse.accessToken
                fetchGitHubUserProfile(accessToken: accessToken)
            }
        }.resume()
    }
    
    private func fetchGitHubUserProfile(accessToken: String) {
        let profileURL = URL(string: "https://api.github.com/user")!
        var request = URLRequest(url: profileURL)
        request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            isLoading = false
            
            UserManager.shared.save(data)
            AppUserDefaults.accessToken = accessToken
            LaunchApp.shared.loginSetup()
            loginCallBack()
            
//            if let data = data,
//               let userResponse = try? JSONDecoder().decode(UserModel.self, from: data) {
//                DispatchQueue.main.async {
//                    UserDefaults.save(value: userResponse.id, key: AccountType.userID.key)
//                    UserDefaults.save(value: userResponse.login, key: AccountType.owner.key)
//                    UserDefaults.save(value: accessToken, key: AccountType.token.key)
//                    LaunchApp.shared.loginSetup()
//                    loginCallBack()
//                }
//            }
        }.resume()
    }
}

struct GitHubTokenResponse: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

class GitHubLoginManager {
    var controller: GitHubLoginViewController?
    static let shared = GitHubLoginManager()
}

class GitHubLoginViewController: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if MOBILE
        return UIApplication.shared.windows.first ?? UIWindow()
        #else
        return NSApplication.shared.windows.first ?? NSWindow()
        #endif
    }
}

//struct GitHubLoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        GitHubLoginView()
//    }
//}
