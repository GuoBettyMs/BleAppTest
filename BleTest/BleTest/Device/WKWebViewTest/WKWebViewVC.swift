//
//  WKWebViewVC.swift
//  IOSApp
//
//  Created by gbt on 2022/7/20.
//

import UIKit
import WebKit

class WKWebViewVC: UIViewController {

    var webView: WKWebView!
    var spinner: UIActivityIndicatorView!
    
    //自定义根视图,当整个页面时webView 或图片时推荐这么做
    //将WKWebView 故事版中的初始View 作为 webView变量，可以避免资源浪费
    override func loadView() {
        let config = WKWebViewConfiguration()
        
//        config.preferences.javaScriptEnabled = true     //是否支持javaScript
//        config.allowsAirPlayForMediaPlayback = true
//        config.allowsInlineMediaPlayback = false
//        config.allowsPictureInPictureMediaPlayback = true
//        config.dataDetectorTypes = [.all]       //【】代表不选中类型
        
        //可以接受web前端（js）传过来的数据--委托给self来接住传来的数据
//        config.userContentController.add(self, name: "user")
        //js代码：
//        <script type = "text/javascript">
//            function sendMessageToIOS(){
//                var users = {
//                    name: "lebus",
//                    age: 20
//                };
//                window.webkit.messageHandle.user.postMessage(users)           //固定写法，user表示 name: "user"
//            }
//        </script>
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true          //允许用户左右滑进行网页的后退前进
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSpinner()                 //配置加载小菊花

        //为了可以安全加载https 协议的网站，需要在Info 添加 key
//        webView.load(string: "https://www.google.com")
        webView.load(string: "https://www.baidu.com")

        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        
//        handleHTMLString()
//        handleHTMLFile()

        
//        webView.isLoading                   //正在加载
//        webView.reload()                    //刷新
//        webView.reloadFromOrigin()          //硬加载
//        webView.stopLoading()               //停止加载
//
//        webView.canGoBack
//        webView.goBack()                   //下一页
//        webView.canGoForward
//        webView.goForward()                   //上一页
//
//        webView.backForwardList         //用户访问历史
  
    }
    
    // MARK: 加载小菊花
    func setSpinner(){
        spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        spinner.layer.cornerRadius = 10
        spinner.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: webView.centerYAnchor).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 80).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    // MARK: 执行小段html代码
    func handleHTMLString(){
        let html = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
            <meta charset="UTF-8">
            <title>WebView</title>
            </head>
            <body>
            <div style="text-align: center;font-size: 80px;margin-top: 350px">WebView Test</div>
            </body>
            </html>
            """
        
        //baseURL 相当于HTML 的<base>标签，定义页面中所有链接的默认相对地址
        webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
    }
    
    // MARK: 执行大段html代码（主要是html）
    func handleHTMLFile(){
        let url = Bundle.main.url(forResource: "HomePage", withExtension: "html")!
        //allowingReadAccessTo-html 文件里面要用到的图片，css、js文件，通常放在一个文件夹里面拖进来
        //deletingLastPathComponent 返回父url
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
    
    // MARK: 执行js代码--也叫 Injecting JavaScript
    func handleJS(){
        webView.evaluateJavaScript("doucunment.body.offsetHeight"){ (result, error) in
            print(result)
        }
    }
    
    // MARK: 实时获取加载进度的值
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress){
            print(webView.estimatedProgress)                //输出网页加载进度
        }
    }
    
    // MARK: 截图
    func takeSnapShot(){
        let config = WKSnapshotConfiguration()
        config.rect = CGRect(x: 0, y: 0, width: 200, height: 200)
        webView.takeSnapshot(with: config){ (image, error) in
            guard let image = image else{
                return
            }
            print(image.size)
        }
    }
    
    // MARK: 读取cookie 的value 和删除cookie
    func handleCookie(){
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies{ cookies in
            //验证是否敏感词
            for cookie in cookies {
                if cookie.name == "auth"{
                    self.webView.configuration.websiteDataStore.httpCookieStore.delete(cookie)
                }else{
                    print(cookie.value)
                }
            }
        }
    }
    
    //class 销毁的时候一定要移除观察者
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
}

//extension WKWebViewVC: WKScriptMessageHandler{
//
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        //js对象（字符串、json等）会被自动序列化为swift 对象
//        if message.name == "user"{
//            print(message.body)
//        }
//    }
//}

extension WKWebViewVC: WKNavigationDelegate{
    
    //navigationAction 发送请求
    //1.决定要不要在当前webView 中加载网站（比如load里面是动态url时），————主要根据请求头等信息
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(#function)
        
        //跳转到外浏览器打开网页
//        if let url = navigationAction.request.url{
//            if url.host == "www.youtube.com"{
//                UIApplication.shared.open(url)
//                decisionHandler(.cancel)
//                return
//            }
//        }
        decisionHandler(.allow)
        
    }
    
    //2.向web服务器请求数据时调用（网页开始加载）
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
        spinner.startAnimating()
    }
    
    //navigationResponse 根据服务器的状态码（200、404、403等）来判断是否接收响应，成功接收响应再加载网页
    //3.在收到服务器的响应后，决定要不要在当前webView 中加载网站-- 主要根据响应头等信息
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(#function)
//        if let httpResponse = navigationResponse.response as? HTTPURLResponse,
//           httpResponse.statusCode == 200 {     //200：服务器成功接收请求，404：服务器未响应，403：服务器未授权
//            decisionHandler(.allow)
//        }else{
//            decisionHandler(.cancel)
//        }
        decisionHandler(.allow)
    }
    
    //4.开始从web服务器接收数据时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(#function)
    }
    
    //5.从web服务器接收完数据时调用（网络加载完成）
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(#function)
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        
        handleJS()
    }
    
    //网络加载失败时调用
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(#function)
        print(error)
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
}

//继承WKUIDelegate,主要用来把网站的三种弹窗转化为IOS原生的弹出框
extension WKWebViewVC: WKUIDelegate{
    //闭包： 被用来作为参数的函数
    //非逃逸闭包： -默认：外围函数执行完毕后被释放
    //逃逸闭包： -@escaping： 外围函数执行完毕后，它的引用仍旧被其他对象持有，不会被释放
    //逃逸闭包对内存管理有风险 -- 谨慎使用除非明确知道
    
    //【js】Alert 警告框
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {_ in
            completionHandler()         //若无该方法，点击确定按钮前，用户无法操作视图的其他功能
        }))
        present(alert, animated: true)
    }
    
    //【js】Confirm 确认框
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: {_ in
            completionHandler(false)         //若无该方法，点击确定按钮前，用户无法操作视图的其他功能
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {_ in
            completionHandler(true)         //若无该方法，点击确定按钮前，用户无法操作视图的其他功能
        }))
        present(alert, animated: true)
    }

    //【js】prompt 输入框
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField{ (textField) in
            textField.placeholder = defaultText
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {_ in
            completionHandler(alert.textFields?.first?.text)
        }))
        present(alert, animated: true)
    }
    
}
