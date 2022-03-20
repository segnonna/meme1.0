//
//  ViewController.swift
//  ImagePickerNew
//
//  Created by Segnonna Hounsou on 20/03/2022.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var topTextField: UITextField!
    
    @IBOutlet var bottomTextField: UITextField!
    
    @IBOutlet var topToolBar: UIToolbar!
    
    @IBOutlet var bottomToolBar: UIToolbar!
    
    @IBOutlet var shareButton: UIBarButtonItem!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: 0.0
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        initialState()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topTextField.defaultTextAttributes = self.memeTextAttributes
        self.topTextField.textAlignment = NSTextAlignment.center
        self.topTextField.delegate = self
        
        self.bottomTextField.defaultTextAttributes = self.memeTextAttributes
        self.bottomTextField.textAlignment = NSTextAlignment.center
        self.bottomTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func pickImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            shareButton.isEnabled = true
            
            
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder{
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //subscribeToHideKeyboardNotifications()
        return true
    }
    
    
    @IBAction func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text ?? "", bottomText: bottomTextField.text ?? "", originalImage: imageView.image ?? UIImage(), memedImage: generateMemedImage())
        
        let vc = UIActivityViewController(activityItems:[meme], applicationActivities: nil)
        present(vc, animated: true)
        
        vc.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
                                            Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                self.dismiss(animated: true)
                return
            } else {
                print("cancel")
            }
            if let shareError = error {
                print("error while sharing: \(shareError.localizedDescription)")
            }
        }
        
    }
    
    
    @IBAction func cancel() {
        initialState()
    }
    
    func initialState(){
        imageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        self.cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        self.shareButton.isEnabled = false
    }
    func generateMemedImage() -> UIImage {
        self.topToolBar.isHidden = true
        self.bottomToolBar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.topToolBar.isHidden = false
        self.bottomToolBar.isHidden = false
        return memedImage
    }
    
}

struct Meme{
    let topText: String
    let bottomText:String
    let originalImage: UIImage
    let memedImage: UIImage
}

