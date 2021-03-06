//
//  MemeViewController.swift
//  MemeIt
//
//  Created by Luis Puentes on 12/29/17.
//  Copyright © 2017 LuisPuentes. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: - Properties
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMemeTextAttributesAndDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This will only enable the camera if the device has one
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // This will only enable the share button if the user selected an image
        shareButton.isEnabled = imagePickerView.image != nil
        
        subscribeToKeyboardWillShowNotifications()
        subscribeToKeyboardWillHideNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardWillShowNotifications()
        unsubscribeToKeyboardWillHideNotifications()
    }
    
    // Saving the meme as a model object
    func save() {
        
        guard let topText = topTextField.text, let bottomText = bottomTextField.text, let image = imagePickerView.image else { return }
        
        let _ = Meme(topText: topText, bottomText: bottomText, originalImage: image, memedImage: generatedMemedImage())
    }
    
    // Taking the memedImage and saving both the image and text
    func generatedMemedImage() -> UIImage {
        // Making sure the toolBar does not show when the memeImage is captured
        toolBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // Once the memeImage is captured, the toolBar can be visible again
        toolBar.isHidden = false
        
        return memedImage
    }
    
    // MARK: Text Attributes & Setting the textfield delegates
    func setMemeTextAttributesAndDelegate() {
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        let memeTextAttributes: [String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.white,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue", size: 25)!,
            NSAttributedStringKey.strokeWidth.rawValue: 10]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
    }
    
    // MARK: - NSNotification Methods
    func subscribeToKeyboardWillShowNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func unsubscribeFromKeyboardWillShowNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func subscribeToKeyboardWillHideNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardWillHideNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // Adjusting the views frame when the keyboard appears
    @objc func keyboardWillShow(_ notification: Notification) {
        // This ensures that the view does not move if it's the topTextField that's being edited
        if topTextField.isEditing {
            return
        }
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // This ensures that the view does not move if it's the topTextField that's being edited
        if topTextField.isEditing {
            return
        }
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: - Text Field Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if topTextField == textField {
            topTextField.text = ""
        }
        
        if bottomTextField == textField {
            bottomTextField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        if topTextField.text == "" {
            topTextField.text = "TOP"
        }
        
        if bottomTextField.text == "" {
            bottomTextField.text = "BOTTOM"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - ImagePicker Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: IBActions
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let image = generatedMemedImage()
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view // This ensures that iPads won't crash
        self.present(activityController, animated: true) {
            // Create the Meme Model Object
            self.save()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        imagePickerView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareButton.isEnabled = false
    }
}
