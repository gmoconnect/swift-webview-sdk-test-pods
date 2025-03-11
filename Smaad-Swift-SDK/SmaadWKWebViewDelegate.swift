//
//  SmaadWKWebViewDelegate.swift
//  Smaad-Swift-SDK
//
//  Created by 川村拓也 on 2024/04/05.
//

import Foundation
import WebKit

public protocol SmaadWKWebViewDelegate: AnyObject {
    // WebViewが新しいページのロードを開始した時に呼ばれる
    func webViewDidStartLoading(_ url: String)
    // リダイレクトされるページのURL
    func webViewDidRedirectUrlLoading(_ url: String)
    // WebViewがページのロードを完了した時に呼ばれる
    func webViewDidFinishLoading(_ url: String)
    // WebViewのナビゲーション中にエラーが発生した時に呼ばれる
    func webViewDidFailProvisionalError(_ description: String, failingUrl: String)
    
    // 閉じるボタンが押された時に呼ばれる
    func onClosedWebView()
}
