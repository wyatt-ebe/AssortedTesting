//
//  CardCollectionTestViewController.swift
//  AssortedTesting
//
//  Created by Wyatt Eberspacher on 6/24/21.
//

import UIKit
import PureUI
import SystemExtensions

class CardCollectionTestViewController: UIViewController {
  let firstCard = Card(title: "First Title",
                       subtitle: "This is the first subtitle!",
                       image: nil,
                       video: nil)
  let secondCard = Card(title: "Second Title",
                        subtitle: "This is the second subtitle!",
                        image: nil,
                        video: nil)
  let thirdCard = Card(title: "Third Title",
                        subtitle: "This is the third subtitle!",
                        image: nil,
                        video: nil)
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.attributedText = NSAttributedString(string: "CARD COLLECTION",
                                              font: .larsseitMedium,
                                              color: .lightGray,
                                              kern: 1)
    return label
  }()
  
  lazy var lastCardLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.attributedText = NSAttributedString(string: "LAST CARD",
                                              font: .larsseitMedium,
                                              color: .systemRed)
    label.alpha = 0
    return label
  }()
  
  private lazy var collectionViewController: CardCollectionViewController = {
    let collectionViewController = CardCollectionViewController(cards: [firstCard, secondCard, thirdCard],
                                                                reuseId: "TestCards",
                                                                textColor: .white,
                                                                titleFont: .larsseitLarge,
                                                                subtitleFont: .larsseitSmall)
    collectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
    return collectionViewController
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set up navigation bar
    navigationController?.navigationBar.backgroundColor = .systemGray
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                       target: self,
                                                       action: #selector(closeView))
    view.backgroundColor = .darkGray
    
    view.addSubview(titleLabel)
    NSLayoutConstraint.activate([
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 97),
    ])
    
    collectionViewController.delegate = self
    addChild(collectionViewController)
    view.addSubview(collectionViewController.view)
    NSLayoutConstraint.activate([
      collectionViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionViewController.view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
    ])
    
    view.addSubview(lastCardLabel)
    NSLayoutConstraint.activate([
      lastCardLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      lastCardLabel.topAnchor.constraint(equalTo: collectionViewController.view.bottomAnchor, constant: 16),
    ])
  }
  
  @objc
  private func closeView() {
    presentingViewController?.dismiss(animated: true)
  }
}

extension CardCollectionTestViewController: CardCollectionViewControllerDelegate {
  // Any actions that require knowing chard changed/is final card
  func didSelectNewCard(isFinalCard: Bool) {
    hideShowAnimated(view: lastCardLabel,
                     show: isFinalCard)
  }
  
  func hideShowAnimated(view: UIView, show: Bool) {
    UIView.transition(with: view,
                      duration: 0.2,
                      options: [],
                      animations: {
                        view.alpha = show ? 1 : 0
                      },
                      completion: { _ in
                        view.isUserInteractionEnabled = show
                      })
  }
}
