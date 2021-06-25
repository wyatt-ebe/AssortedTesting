//
//  CardCollectionTestViewController.swift
//  AssortedTesting
//
//  Created by Wyatt Eberspacher on 6/24/21.
//

import UIKit
import PureUI
import SystemExtensions

// Content URLs hosted on standalone Github repo
enum CardMedia: CaseIterable {
  case FirstCard
  case SecondCard
  case ThirdCard
  
  private static var images = [CardMedia : UIImage?]()
  
  // Use completion bool to prevent accidently thread conflict if background update not complete
  private static var preloadComplete: Bool = false
  
  static func preloadImages() {
    DispatchQueue.global().async {
      for card in CardMedia.allCases {
        images[card] = card.image
      }
      CardMedia.preloadComplete = true
    }
  }
  
  var image: UIImage? {
    if CardMedia.preloadComplete,
       let preloadedImage = CardMedia.images[self] {
      return preloadedImage
    } else {
      switch self {
      case .FirstCard:
        return videoUrl?.getThumbnail()
      case .SecondCard:
        return nil
      case .ThirdCard:
        return UIImage.fromUrlString("https://github.com/wyattTopo/PublicAssets/blob/2360456fc1912540d2cca7c69e11fd0f6b8643da/jcPortrait.jpg?raw=true")
      }
    }
  }
  
  var videoUrl: URL? {
    switch self {
    case .FirstCard:
      return URL(string: "https://github.com/wyattTopo/PublicAssets/blob/6b0b16e17c49c4a42dc188e0af38eee96d08cc06/sheepVideo.mp4?raw=true")
    case .SecondCard:
      return nil
    case .ThirdCard:
      return nil
    }
  }
}

class CardCollectionTestViewController: UIViewController {
  let firstCard = Card(title: "First Title",
                       subtitle: "This is the first subtitle!",
                       image: CardMedia.FirstCard.image,
                       video: CardMedia.FirstCard.videoUrl)
  let secondCard = Card(title: "Second Title",
                        subtitle: "This is the second subtitle!",
                        image: CardMedia.SecondCard.image,
                        video: CardMedia.SecondCard.videoUrl)
  let thirdCard = Card(title: "Third Title",
                        subtitle: "This is the third subtitle!",
                        image: CardMedia.ThirdCard.image,
                        video: CardMedia.ThirdCard.videoUrl)
  
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
