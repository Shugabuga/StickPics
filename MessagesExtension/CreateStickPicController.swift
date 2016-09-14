//
//  CreateStickPicController.swift
//  StickPics
//
//  Created by Dylan Wight on 8/20/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import Foundation

import UIKit
import Messages

class CreateStickPicController: UIViewController {
    
    static let storyboardIdentifier = "CreateStickPicController"
    
    
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "backgroundTile"))
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var leftUnderFingerView: UIImageView! {
        didSet {
            leftUnderFingerView.layer.cornerRadius = min(leftUnderFingerView.frame.height, leftUnderFingerView.frame.width) / 2.0
            leftUnderFingerView.clipsToBounds = true
            leftUnderFingerView.layer.borderWidth = 2.0
            leftUnderFingerView.layer.borderColor = UIColor.black.cgColor
            leftUnderFingerView.alpha = 0.0
            leftUnderFingerView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "backgroundTile"))
        }
    }
    
    var brushSize: CGFloat {
        return (CGFloat(sizeSlider.value) * CGFloat(sizeSlider.value))
    }
    
    var lastPoint: CGPoint?
    
    var actualSize: CGSize {
        return CGSize(width: imageView.frame.width * 2.0, height: imageView.frame.height * 2.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let drag = UILongPressGestureRecognizer(target: self, action: #selector(CreateStickPicController.handleDrag(_:)))
        drag.minimumPressDuration = 0.0
        drag.delegate = self
        imageView.addGestureRecognizer(drag)
    }
    
    @IBAction func save(_ sender: UIButton) {
        if let image = imageView.image {
            if let data = UIImagePNGRepresentation(image) {
                
                let id = NSUUID().uuidString
                let url = URL(fileURLWithPath: getDocumentsDirectory().appendingPathComponent("\(id).png"))
                
                StickPicHistory.load().addStickPicURL(url: url)
                
                do {
                    try data.write(to: url)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var sizeSlider: UISlider! {
        didSet {
            sizeSlider.minimumValue = 2.0
            sizeSlider.maximumValue = 10.0
            sizeSlider.value = 5.5
        }
    }
    
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }


    func handleDrag(_ sender: UILongPressGestureRecognizer) {
        
        
        let point = sender.location(in: imageView)
        
        setUnderFingerView(point)
        
        switch sender.state {
        case .began:
            lastPoint = point
        case .changed:
            let currentPoint = sender.location(in: imageView)
            
            UIGraphicsBeginImageContext(imageView.frame.size)
            imageView.image?.draw(at: CGPoint.zero)
            
            let context = UIGraphicsGetCurrentContext()!
            
            context.setLineCap(.round)
            context.setLineWidth(brushSize)
            context.setBlendMode(.clear)
            
            context.setStrokeColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            context.beginPath()
            
            if let lastPoint = lastPoint {
                context.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            }
            context.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))

            context.strokePath()
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            lastPoint = currentPoint
            
        case .ended:
            hideUnderFingerView()
        default:
            break
        }
        
        
    }
}


extension CreateStickPicController {
    
    public func hideUnderFingerView() {
        UIView.animate(withDuration: 0.5,delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.leftUnderFingerView.alpha = 0.0
            }, completion: nil)
    }
    
    
    public func showUnderFingerView() {
        UIView.animate(withDuration: 0.5,delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.leftUnderFingerView.alpha = 1.0
            }, completion: nil)
    }
    
    public func setUnderFingerView(_ position: CGPoint) {
        
        let underFingerSize: CGSize
        
        let maxUnderFinger: CGFloat = 400.0
        let minUnderFinger: CGFloat = 200.0
        
        let ceilingSize: CGFloat = 80.0
        let baseSize: CGFloat = 10.0
        
        if (brushSize > ceilingSize) {
            underFingerSize = CGSize(width: maxUnderFinger, height: maxUnderFinger)
        } else if (brushSize < baseSize){
            underFingerSize = CGSize(width: minUnderFinger, height: minUnderFinger)
        } else {
            let underFinger = ((brushSize - baseSize) / ceilingSize) * (maxUnderFinger - minUnderFinger) + minUnderFinger
            underFingerSize = CGSize(width: underFinger, height: underFinger)
        }
        
        
        leftUnderFingerView.frame = CGRect(x: position.x - (leftUnderFingerView.frame.width/2.0), y: position.y - 30.0 - leftUnderFingerView.frame.height, width: leftUnderFingerView.frame.width, height: leftUnderFingerView.frame.height)
        leftUnderFingerView.image = imageView.image?.cropToSquare(position, cropSize: underFingerSize)
        
        showUnderFingerView()
    }
}


extension CreateStickPicController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UIGraphicsBeginImageContext(imageView.frame.size)
            pickedImage.draw(in: imageView.frame)
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension CreateStickPicController: UIGestureRecognizerDelegate {
    
}


extension UIImage {
    func cropToSquare(_ center: CGPoint, cropSize: CGSize) -> UIImage {
        var cropCenter = center
        // fixes cropping distorion on edges
        if (center.x < cropSize.width/2) {
            cropCenter.x = cropSize.width/2
        } else if (center.x > self.size.width - cropSize.width/2){
            cropCenter.x = self.size.width - cropSize.width/2
        }
        if (center.y < cropSize.height/2) {
            cropCenter.y = cropSize.height/2
        } else if (center.y > self.size.height - cropSize.height/2){
            cropCenter.y = self.size.height - cropSize.height/2
        }
        
        let posX = cropCenter.x - cropSize.width / 2
        let posY = cropCenter.y - cropSize.height / 2
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropSize.width, height: cropSize.height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = self.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef)
        
        return image
    }
}

