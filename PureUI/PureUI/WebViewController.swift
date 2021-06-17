//
//  WebViewController.swift
//  PureUI
//
//  Created by Wyatt Eberspacher on 6/17/21.
//

import WebKit

// Allow parent to store current web view for restoration as needed
// TODO: Extend to storing configuration/cache data
public protocol WebViewControllerDelegate: AnyObject {
  func storeWebView(_ webVC: WKWebView)
}

// Container for presenting WKWebView via navigation controller
public class WebViewController: UIViewController {
  private let url: URL
  private let webView: WKWebView
  private var observation: NSKeyValueObservation?
  
  public weak var delegate: WebViewControllerDelegate?
  
  /// Indicator view that observes page load progress for the user
  private lazy var progressView: UIProgressView = {
    let progressView = UIProgressView(progressViewStyle: .default)
    progressView.translatesAutoresizingMaskIntoConstraints = false
    return progressView
  }()
  
  public init(url: URL,
       webView: WKWebView = WKWebView()) {
    self.url = url
    self.webView = webView
    super.init(nibName: nil, bundle: nil)
  }
  
  public init(url: URL,
       configuration: WKWebViewConfiguration) {
    self.url = url
    self.webView = WKWebView(frame: .zero, configuration: configuration)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set up navigation bar
    navigationController?.navigationBar.backgroundColor = .systemGray
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                       target: self,
                                                       action: #selector(closeView))
    // Set up webView properties
    webView.allowsBackForwardNavigationGestures = true
    
    // Set up primary webView
    webView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(webView)
    NSLayoutConstraint.activate([
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
   
    // Set up view layout
    view.addSubview(progressView)
    NSLayoutConstraint.activate([
      progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      progressView.heightAnchor.constraint(equalToConstant: 2),
    ])
    
    // Initalize obersvation progress
    observeProgress()
    
    // Load base page
    let request = URLRequest(url: url)
    webView.load(request)
  }
  
  private func observeProgress() {
    observation = webView.observe(\.estimatedProgress, options: .new) { [weak self] (webView, change) in
      guard let self = self else { return }
      
      let estimatedProgress = Float(webView.estimatedProgress)
      let isInProgress = estimatedProgress < 1
      
      self.progressView.progress = estimatedProgress
      if isInProgress {
        self.progressView.alpha = 1.0
        self.progressView.isHidden = false
      } else {
        // Hide after completing, but leave the observation running
        UIView.animate(withDuration: 0.2,
                       animations: { self.progressView.alpha = 0 },
                       completion: { _ in
                        self.progressView.isHidden = true
                       })
      }
    }
  }
  
  @objc
  private func closeView() {
    delegate?.storeWebView(webView)
    presentingViewController?.dismiss(animated: true)
  }
}
