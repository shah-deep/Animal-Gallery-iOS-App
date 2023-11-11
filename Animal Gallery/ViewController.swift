//
//  ViewController.swift
//  Animal Gallery
//
//  Created by D on 11/5/23.
//

import UIKit

class ViewController: UIViewController {

    var gallery = [#imageLiteral(resourceName: "3-32479_animals-hd-wallpaper-funny-cute-animals-wallpapers-cute.jpg"),#imageLiteral(resourceName: "30881.jpg"),#imageLiteral(resourceName: "343178.jpg"),#imageLiteral(resourceName: "392887.jpg"),#imageLiteral(resourceName: "610828-bigthumbnail.jpg"),#imageLiteral(resourceName: "907729-free-cute-animal-backgrounds-1920x1200-tablet.jpg"),#imageLiteral(resourceName: "corgi_header_image.jpg"),#imageLiteral(resourceName: "free-wallpaper-16.jpg"),#imageLiteral(resourceName: "OlwQ9A.jpg"),#imageLiteral(resourceName: "wild-animal-wallpapers-desktop-images-free-wallpapers-cute-animals-wallpaper-of-animals-large-animal-photos-animality-1440x900.jpg")]
    
    @IBOutlet weak var trashImageView: UIImageView!
    
    var nextIndex = 0
    var currentPicture: UIImageView?
    let originalSize: CGFloat = 300
    var activeSize: CGFloat {
        return originalSize + 10
    }
    var isActive = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showNextPicture()
    }
    
    func showNextPicture() {
        guard gallery.count > 0 else { return }
        
        if let newPicture = createPicture() {
            currentPicture = newPicture
            showPicture(newPicture)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
            newPicture.addGestureRecognizer(tap)
            
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
            swipe.direction = .up
            newPicture.addGestureRecognizer(swipe)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
            pan.delegate = self
            newPicture.addGestureRecognizer(pan)
            
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleBtn(_:)))
            trashImageView.isUserInteractionEnabled = true
            trashImageView.addGestureRecognizer(tap2)
            
        } else {
            nextIndex = 0
            showNextPicture()
        }
    }
    
    @objc func handleTap() {
        isActive = !isActive
        
        if isActive {
            activateCurrentPicture()
        } else {
            deactivateCurrentPicture()
        }
    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        guard !isActive else { return }
        hidePicture()
        showNextPicture()
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let view = self.currentPicture, isActive else { return }
        
        switch sender.state {
            case .began, .changed:
                processPictureMovement(sender: sender, view: view)
                break
            case .ended:
                if(view.frame.intersects(trashImageView.frame)) {
                    deletePicture(imageView: view)
                }
                break
            default:
                break
        }
    }
    
    @objc func handleBtn(_ sender: UITapGestureRecognizer) {
        guard let view = self.currentPicture else { return }
        deletePicture(imageView: view)
    }
    
    func processPictureMovement(sender: UIPanGestureRecognizer, view: UIImageView) {
        let translation = sender.translation(in: view)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        sender.setTranslation(.zero, in: view)
        if view.frame.intersects(trashImageView.frame) {
            view.layer.borderColor = UIColor.red.cgColor
        } else {
            view.layer.borderColor = UIColor.green.cgColor
        }
    }

    func createPicture() -> UIImageView? {
        guard nextIndex < gallery.count else {
            return nil
        }
        let imageView = UIImageView(image: gallery[nextIndex])
        imageView.frame = CGRect(x: self.view.frame.width, y: self.view.center.y - (originalSize/2), width: originalSize, height: originalSize)
        imageView.isUserInteractionEnabled = true
        
        // Shadow
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowRadius = 10
        
        // Frame
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        
        nextIndex += 1
        return imageView
    }
    
    func deletePicture(imageView: UIImageView) {
        self.gallery.remove(at: self.nextIndex-1)
        self.nextIndex -= 1
        if (self.nextIndex < 0) {
            self.nextIndex = gallery.count - 1
        }
        self.isActive = false
        
        UIView.animate(withDuration: 0.4) {
            imageView.alpha = 0
        } completion: { (_) in
            imageView.removeFromSuperview()
        }
        
        showNextPicture()
    }
    
    func activateCurrentPicture() {
        UIView.animate(withDuration: 0.3) {
            self.currentPicture?.frame.size = CGSize(width: self.activeSize, height: self.activeSize)
            self.currentPicture?.layer.shadowOpacity = 0.5
            self.currentPicture?.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    func deactivateCurrentPicture() {
        UIView.animate(withDuration: 0.3) {
            self.currentPicture?.frame.size = CGSize(width: self.originalSize, height: self.originalSize)
            self.currentPicture?.layer.shadowOpacity = 0
            self.currentPicture?.layer.borderColor = UIColor.darkGray.cgColor
        }
    }
    
    func showPicture(_ imageView: UIImageView) {
        self.view.addSubview(imageView)
        
        UIView.animate(withDuration: 0.4) {
            imageView.center = self.view.center
        }
    }
    
    func hidePicture() {
        let lastPic = self.currentPicture
        UIView.animate(withDuration: 0.4) {
            self.currentPicture?.frame.origin.y = -self.originalSize
        } completion: { (_) in
            lastPic?.removeFromSuperview()
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
