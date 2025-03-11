//
//  SmaadWKWebView.swift
//  Smaad-Swift-SDK
//
//  Created by 川村拓也 on 2024/04/05.
//


import WebKit

open class SmaadWKWebView: WKWebView, WKScriptMessageHandler, WKNavigationDelegate {
    // デリゲートプロパティの追加
    public weak var smaadDelegate: SmaadWKWebViewDelegate?
    
    private let smaadWebviewScript = """
    var SmaadWebViewSDK = {
         open: function(url) {
             window.webkit.messageHandlers.\(Constants.smaadMessageHandler).postMessage(url);
         }
    };
    """
    
    public func initializeWebView(_ zoneId: Int, userParameter: String) {
        let baseUrl = "https://offerwall.stg.smaad.net/wall/"
        let urlString = "\(baseUrl)\(zoneId)?u=\(userParameter)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        self.load(request)
    }
    
    
    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self // NavigationDelegateを自分自身に設定
        initialSmaadWebView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        translatesAutoresizingMaskIntoConstraints = false
        initialSmaadWebView()
    }
    
    private func initialSmaadWebView(){
        addMessageHandler()
        updateUserAgent()
    }
    
    internal func addMessageHandler() {
        configuration.userContentController.add(self, name: Constants.smaadMessageHandler)
        configuration.userContentController.addUserScript(
            WKUserScript(source: smaadWebviewScript,
                         injectionTime: WKUserScriptInjectionTime.atDocumentStart,
                         forMainFrameOnly: false))
        // webViewClosed メッセージハンドラの追加
        configuration.userContentController.removeScriptMessageHandler(forName: "webViewClosed")
        configuration.userContentController.add(self, name: "webViewClosed")
        configuration.userContentController.removeScriptMessageHandler(forName: "launchURL")
        configuration.userContentController.add(self, name: "launchURL")
        
    }
    
    internal func updateUserAgent() {
        evaluateJavaScript(Constants.navigatorUserAgent) {(result, error) in
            if let userAgent = result as? String {
                self.customUserAgent = userAgent + Constants.customUserAgent
            }
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "webViewClosed" {
            smaadDelegate?.onClosedWebView()
        }
        else if message.name == "launchURL"{
            if let urlString = message.body as? String,
                let url = URL(string: urlString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    // webViewDidStartLoading
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let url = webView.url?.absoluteString ?? ""
        smaadDelegate?.webViewDidStartLoading(url)
    }
    
    // webViewDidRedirectUrlLoading
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        let url = webView.url?.absoluteString ?? ""
        smaadDelegate?.webViewDidRedirectUrlLoading(url)
    }

    // webViewDidFinishLoading
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let url = webView.url?.absoluteString ?? ""
        smaadDelegate?.webViewDidFinishLoading(url)
    }
    
    // webViewDidFrailProvisionalError
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        smaadDelegate?.webViewDidFailProvisionalError(error.localizedDescription, failingUrl: webView.url?.absoluteString ?? "")
    }
}
