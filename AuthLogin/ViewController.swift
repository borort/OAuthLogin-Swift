//
//  ViewController.swift
//  AuthLogin
//
//  Created by SORT, Borort on 2019/08/15.
//  Copyright © 2019 SORT, Borort. All rights reserved.
//

import UIKit

import OAuthSwift

class ViewController: UIViewController {
    
    
    var oauthswift: OAuthSwift?
    
    let consumerDataTwitter:[String:String] =
        ["consumerKey":"xxxxxxxxxxxxx",
            "consumerSecret":"xxxxxxxxxxxxxxxxxxxxxxxxxxx"]
    
    
    let consumerDataCustom:[String:String] =
        ["consumerKey":"<client_id>",
         "consumerSecret":"xxxxxxxxxxxxxxxxxxxxxxxxxxx"]


    @IBAction func twitterAuth(_ sender: UIButton) {
        
        doOAuthTwitter(consumerDataTwitter)
        
    }
    
    @IBAction func customAuth(_ sender: UIButton) {
        doOAuthCustom(consumerDataCustom)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: Twitter
    func doOAuthTwitter(_ serviceParameters: [String:String]){
        let oauthswift = OAuth1Swift(
            consumerKey:    serviceParameters["consumerKey"]!,
            consumerSecret: serviceParameters["consumerSecret"]!,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = getURLHandler()
        let _ = oauthswift.authorize(
        withCallbackURL: URL(string: "OAuthLogin://oauth-callback")!) { result in
            switch result {
            case .success(let (credential, _, _)):
                self.showTokenAlert(name: serviceParameters["name"], credential: credential)
                //self.testTwitter(oauthswift)
            case .failure(let error):
                print(error.description)
            }
        }
    }
    
    // MARK: Custom - Laravel Passport
    func doOAuthCustom(_ serviceParameters: [String:String]){
        let oauthswift = OAuth2Swift(
            consumerKey:    serviceParameters["consumerKey"]!,
            consumerSecret: serviceParameters["consumerSecret"]!,
            authorizeUrl:    "https://auth.borort.com/oauth/authorize",
            accessTokenUrl:  "https://auth.borort.com/oauth/token",
            responseType:   "code"
        )
        
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = getURLHandler()
        let state = generateState(withLength: 20)
        let _ = oauthswift.authorize(
        withCallbackURL: URL(string: "OAuthLogin://oauth-callback")!, scope: "", state: state) { result in
            switch result {
            case .success(let (credential, _, _)):
                self.showTokenAlert(name: serviceParameters["name"], credential: credential)
            case .failure(let error):
                print(error.localizedDescription, terminator: "")
            }
        }
    }
    
    
    
    
    func getURLHandler() -> OAuthSwiftURLHandlerType {
        if #available(iOS 9.0, *) {
            let handler = SafariURLHandler(viewController: self, oauthSwift: self.oauthswift!)
            handler.presentCompletion = {
                print("Safari presented")
            }
            handler.dismissCompletion = {
                print("Safari dismissed")
            }
            return handler
        }
        return OAuthSwiftOpenURLExternally.sharedInstance
    }
    
    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauthToken)"
        if !credential.oauthTokenSecret.isEmpty {
            message += "\n\noauth_token_secret:\(credential.oauthTokenSecret)"
        }
        self.showAlertView(title: name ?? "Service", message: message)
        
    }
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


}

