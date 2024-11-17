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
        HStack {
            VStack {
                Image("app_logo")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                    .padding(.bottom, 10)
                Text("WelCome")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.medium)
                    .padding(.bottom, 1)
                Text("Please log in with GitHub")
                    .foregroundColor(Color.init(hex: "4F4F4F"))
                    .font(.subheadline)
                    .padding(.bottom, 30)
                ZStack {
                    Button(action: {
                        startGitHubLogin()
                    }) {
                        HStack (spacing: 10) {
                            Image(systemName: "person.fill")
                            Text("Login with GitHub")
                                .font(.system(.body, design: .rounded))
                        }
                        .padding()
                        .frame(width: 268, height: 50)
                        .background(Color.init(hex: "333333"))
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack (alignment: .center, spacing: 20) {
                Text("Tips")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                item("square.stack.3d.up", leftText: "Repository", rightText: "Workspace")
                item("menucard", leftText: "Issues", rightText: "Notebook")
                item("note", leftText: "Comments", rightText: "Note")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.init(hex: "363636")
//                LinearGradient(
//                    gradient: Gradient(colors: 
//                                        [Color.init(hex: "666666"),
//                                         Color.init(hex: "444444"),
//                                         Color.init(hex: "333333")]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
            )
        }
        .frame(width: 800, height: 400)
    }
    
    func item(_ icon: String, leftText: String, rightText: String) -> some View {
        ZStack {
            HStack {
                ZStack {
                    Color.white
                        .frame(width: 40, height: 40)
                        .opacity(0.1)
                        .cornerRadius(3.0)
                    Image(systemName: icon)
                }
                Text(verbatim: leftText)
                Spacer()
            }
            HStack {
                Image(systemName: "arrow.right")
                Text(verbatim: rightText)
                Spacer()
            }
            .padding(.leading, 150)
        }
        .foregroundColor(.white)
        .padding(.leading, 80)
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
            } else {
                isLoading = false
                "#login# AccessToken error \(error.debugDescription)".logE()
            }
        }.resume()
    }
    
    private func fetchGitHubUserProfile(accessToken: String) {
        let profileURL = URL(string: "https://api.github.com/user")!
        var request = URLRequest(url: profileURL)
        request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            isLoading = false
            
            if error != nil {
                "#login# UserProfile error \(error.debugDescription)".logE()
                return
            }
            
            UserManager.shared.save(data)
            AppUserDefaults.accessToken = accessToken
            LaunchApp.shared.loginSetup()
            loginCallBack()
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

struct GitHubLoginView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubLoginView(loginCallBack: {
            
        })
    }
}
