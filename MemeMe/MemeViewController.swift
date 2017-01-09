//
//  ViewController.swift
//  MemeMe
//
//  Created by Luke Van In on 2017/01/01.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Allow the user to create a new meme, either from a blank canvas, or by using the contents of another meme. Once 
//  created, the meme can be shared and saved.
//

import UIKit

class MemeViewController: UIViewController, UIBarPositioningDelegate {
    
    
    //
    // MARK: Properties
    //
    
    var defaultMeme: Meme?
    
    let memes = Memes.shared
    
    let defaultTopText = "Top Text"
    let defaultBottomText = "Bottom Text"
    
    lazy var topTextFieldDelegate: MemeTextFieldDelegate = { [unowned self] in
        let delegate = MemeTextFieldDelegate(defaultText: self.defaultTopText)
        delegate.onEditing = self.onTextFieldEdit
        return delegate
    }()
    
    lazy var bottomTextFieldDelegate: MemeTextFieldDelegate = { [unowned self] in
        let delegate = MemeTextFieldDelegate(defaultText: self.defaultBottomText)
        delegate.onEditing = self.onTextFieldEdit
        return delegate
    }()
    
    // Amount to shift the image to accomodate the keyboard.
    var contentInset: CGFloat = 0 {
        didSet {
            updateLayout(animated: true)
        }
    }
    
    // Stipulate that the content inset needs to be applied. Content inset is only applied if editing the bottom 
    // textfield in landscape mode.
    var contentInsetRequired: Bool = false {
        didSet {
            updateLayout(animated: true)
        }
    }

    
    
    //
    // MARK: Interface builder outlets
    //
    
    
    
    @IBOutlet weak var shareButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var cameraButtonItem: UIBarButtonItem!
    @IBOutlet weak var albumButtonItem: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageAspectConstraint: NSLayoutConstraint!
    
    // Using strong references to constraints since the constraint can be disabled at runtime, which would result in the 
    // constraint being deallocated.
    @IBOutlet var offsetConstraint: NSLayoutConstraint!
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    
    
    
    //
    // MARK: Actions
    //

    
    
    //
    //  Camera or album toolbar button item tapped. Import a new image from the camera or photo library.
    //
    //  In version 1.0 of the app this was implemented as two separate actions, one for camera, and one for library.
    //  These were combined into a into a single action on the recommendation of the reviewer.
    //
    //  Comparing the two approaches, I personally prefer using separate actions since it is more descriptive, less 
    //  error prone (ie easy to make a mistake with the tag IDs), and doesn't create any more or less duplication. 
    //  A combined action selector as used here would still be useful in certain circumstances, where several buttons 
    //  with similar actions are used (as in the PitchPerfect app).
    //
    @IBAction func onImportAction(_ sender: UIBarButtonItem) {
        resignResponders()
        
        switch sender.tag {
        case 500:
            importImage(from: .camera)
        case 501:
            importImage(from: .photoLibrary)
        default:
            break
        }
    }
    
    //
    //  Share meme.
    //
    @IBAction func onShareAction(_ sender: Any) {
        resignResponders()
        exportImage()
    }
    
    //
    //  Reset meme to default state.
    //
    @IBAction func onClearAction(_ sender: Any) {
        showDismissConfirmationIfNeeded() { [weak self] in
            self?.performSegue(withIdentifier: "dismiss", sender: nil)
        }
    }
    
    
    
    //
    // MARK: View life cycle
    //
    
    
    
    override var prefersStatusBarHidden: Bool {
        // Hide status bar to provide more visual space for editing.
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        configureButtons()
        updateButtons()
        resetContent()
        if let meme = defaultMeme {
            setMeme(meme)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLayout()
        observeKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unobserveKeyboardNotifications()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Adjust the layout when the device is rotated.
        coordinator.animate(alongsideTransition: { _ in
            self.updateLayout()
        }, completion: nil)
    }

    
    
    //
    // MARK: User interface
    //
    
    
    
    //
    //  Called when the editing state of a text field changes - when editing begins in a textfield, or when it editing
    //  ends.
    //
    //  If the bottom text field is being edited, then content inset is enabled, to push the view upwards and keep the
    //  textfield visible.
    //
    private func onTextFieldEdit(_ textField: UITextField) {
        // If the bottom text field is being edited then apply the content inset for the keyboard. See updateLayout() functions.
        if bottomTextField.isFirstResponder {
            contentInsetRequired = true
        }
        else {
            contentInsetRequired = false
        }
        updateButtons()
    }

    //
    //  Update the UI layout, optionally animated.
    //
    private func updateLayout(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.5) { [unowned self] in
                self.updateLayout()
            }
        }
        else {
            updateLayout()
        }
    }
    
    //
    //  Adjusts the UI layout to compensate for the screen size according to the orientation of the device, and keyboard 
    //  visibility.
    //
    private func updateLayout() {
        
        if contentInsetRequired && (contentInset > 0) {
            // Editing bottom textfield.
            // Shift content to accomodate keyboard.
            centerConstraint.isActive = false
            offsetConstraint.isActive = true
            offsetConstraint.constant = contentInset
        }
        else {
            // Editing top textfield.
            // Leave content aligned to center.
            centerConstraint.isActive = true
            offsetConstraint.isActive = false
        }

        view.layoutIfNeeded()
    }
    
    //
    //  Determine if the device is in landscape mode.
    //
    private func isLandscape() -> Bool {
        let size = view.bounds.size
        return size.width > size.height
    }

    //
    //  Enable buttons depending on feature availability.
    //  E.g. Camera is unavailable on simulator, and so the camera button is disabled.
    //
    private func configureButtons() {
        cameraButtonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        albumButtonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    //
    //  Apply default text attributes (stroke and colour), and setup text field delegates for editing.
    //
    private func configureTextFields() {
        configureTextField(textField: topTextField, withDelegate: topTextFieldDelegate)
        configureTextField(textField: bottomTextField, withDelegate: bottomTextFieldDelegate)
    }
    
    //
    //  Set the font style, and delegate for a text field. 
    //  The font is set to "Impact", size 40 points, white, with a black border.
    //  A custom delegate is assigned to the text field, to control the appearance of the default placeholder text.
    //
    private func configureTextField(textField: UITextField, withDelegate delegate: MemeTextFieldDelegate) {
        let memeTextAttributes : [String : Any] = [
                NSForegroundColorAttributeName: UIColor.white,
                NSStrokeColorAttributeName: UIColor.black,
                NSStrokeWidthAttributeName: -3.0,
                NSFontAttributeName: UIFont(name: "Impact", size: 40)!
            ]
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = delegate
    }
    
    //
    //  Resigns the current first responder and dismiss the keyboard.
    //
    private func resignResponders() {
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
    }
    
    
    
    //
    // MARK: Meme creation
    //
    
    
    
    //
    //  Remove any existing edits and set the content to a default state (ie create a new meme).
    //
    private func resetContent() {
        memeImageView.image = nil
        topTextField.text = defaultTopText
        bottomTextField.text = defaultBottomText
        setImageConstraintWithAspectRatio(1.0)
        resignResponders()
        updateButtons()
    }
    
    //
    //  Update the view using a completed meme. Sets the image, and top and bottom textfields. Used when copying an 
    //  existing meme to create a derived copy.
    //
    private func setMeme(_ meme: Meme) {
        setMemeImage(meme.originalImage)
        topTextField.text = meme.topText
        bottomTextField.text = meme.bottomText
    }
    
    //
    //  Updates the view with a new image.  The image is constrained to maintain its aspect ratio while fitting inside
    //  the displayable area.
    //
    fileprivate func setMemeImage(_ image: UIImage) {
        memeImageView.image = image
        
        let size = image.size
        let aspect = size.width / size.height
        setImageConstraintWithAspectRatio(aspect)
        updateButtons()
    }
    
    //
    //  Applies an aspect ratio constraint to the image.
    //
    //  Using an explicit constraint allows the text labels can be constrained to the image, which ensures that the text
    //  always overlap the image content area correctly, independently of the size or aspect ratio of the image, and the
    //  orientation of the device.
    //
    //  Using contentMode = .aspectFill or .aspectFit as suggested in the courseware prevents the text fields from
    //  being constrained to the image, with the result that the text fields can appear outside the image. In the 
    //  demonstration videos, the app is shown being rotated into landscape mode to force the labels to align correctly.
    //  This is not necessary using th explicit constraint.
    //
    //
    fileprivate func setImageConstraintWithAspectRatio(_ aspect: CGFloat) {
        if let constraint = imageAspectConstraint {
            memeImageView.removeConstraint(constraint)
        }
        imageAspectConstraint = memeImageView.widthAnchor.constraint(equalTo: memeImageView.heightAnchor, multiplier: aspect)
        if let constraint = imageAspectConstraint {
            memeImageView.addConstraint(constraint)
        }
    }

    //
    //  Updates the enabled/disabled state for the share and cancel buttons.
    //
    func updateButtons() {
        updateShareButton()
    }
    
    //
    //  Enable share button if enough content is provided to create a meme. Disable the button if the meme is 
    //  incomplete.
    //
    private func updateShareButton() {
        if isCompleted() {
            shareButtonItem.isEnabled = true
        }
        else {
            shareButtonItem.isEnabled = false
        }
    }
    
    //
    //  Determine if the meme is in a complete state. 
    //  An image must be provided, and both text fields must contain text.
    //
    private func isCompleted() -> Bool {
        if getTopText() == nil {
            return false
        }
        
        if getBottomText() == nil {
            return false
        }
        
        if memeImageView.image == nil {
            return false
        }
        
        return true
    }
    
    //
    //  Determine if any edits have been made (either to a new meme, or a derived meme).
    //  An image is provided, or either of the text fields contains text.
    //
    private func hasChanges() -> Bool {
        
        if let meme = defaultMeme {
            // Current meme is derived from an existing meme. 
            // Check if any fields are different to the derived meme.
            
            if getTopText() != meme.topText {
                return true
            }
            
            if getBottomText() != meme.bottomText {
                return true
            }
            
            if memeImageView.image != meme.originalImage {
                return true
            }
        }
        else {
            // Meme was created anew.
            // Check if any data has been provided so far.
            
            if getTopText() != nil {
                return true
            }
            
            if getBottomText() != nil {
                return true
            }
            
            if memeImageView.image != nil {
                return true
            }
        }
        
        return false
    }
    
    
    
    //
    // MARK: Image import.
    //
    
    
    
    //
    //  Show an image picker to import an image.
    //
    private func importImage(from source : UIImagePickerControllerSourceType) {
        let viewController = UIImagePickerController()
        viewController.sourceType = source
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    
    
    //
    // MARK: Meme export and sharing.
    //
    
    
    
    //
    //  Export the current meme image using an activity controller.
    //
    private func exportImage() {
        guard let image = captureMemeImage() else {
            return
        }
        showExportViewController(image: image, from: shareButtonItem)
    }
    
    //
    //  Show an activity controller to export the image. 
    //  Save the meme on completion, or show an error.
    //
    private func showExportViewController(image: UIImage, from sender: UIBarButtonItem) {
        let viewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        viewController.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, activityError in
            if let error = activityError {
                // An error occurred. Show an alert.
                self?.showAlert(for: error)
            }
            else if completed {
                // The activity controller completed without an error, save the meme.
                self?.saveMeme(image)
                self?.performSegue(withIdentifier: "dismiss", sender: nil)
            }
            else {
                // ... The activity controller was cancelled
            }
        }
        if let presentationController = viewController.popoverPresentationController {
            presentationController.barButtonItem = sender
        }
        present(viewController, animated: true, completion: nil)
    }
    
    //
    //  Composes a flattened meme image from the composer view.
    //
    //  TODO: Create an offscreen view with larger dimensions in order to obtain a higher fidelity result.
    //
    private func captureMemeImage() -> UIImage? {
        guard let sourceView = imageContainerView else {
            return nil
        }
        let viewArea = sourceView.bounds
        UIGraphicsBeginImageContext(viewArea.size)
        sourceView.drawHierarchy(in: viewArea, afterScreenUpdates: true)
        let outputImage : UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }
    
    //
    //  "Save" the meme image. 
    //  Create an instance of a Meme model from the current state if possible. 
    //  The model is passed to the view controller's delegate (to handle persistence etc).
    //
    private func saveMeme(_ image: UIImage) {
        // Create meme object and pass to delegate.
        guard let meme = makeMeme(image: image) else {
            return
        }
        memes.add(meme: meme)
    }
    
    
    
    //
    // MARK: Meme model creation.
    //
    
    
    
    
    //
    //  Create a meme model from the current editor's state if possible.
    //
    private func makeMeme(image: UIImage) -> Meme? {
        guard let topText = getTopText() else {
            return nil
        }
        
        guard let bottomText = getBottomText() else {
            return nil
        }
        
        guard let originalImage = memeImageView.image else {
            return nil
        }
        
        return Meme(
            topText: topText,
            bottomText: bottomText,
            originalImage: originalImage,
            memedImage: image
        )
    }
    
    //
    //  Get the text entered in the top text field. 
    //  If the text field contains the default placeholder text then return nothing.
    //
    private func getTopText() -> String? {
        guard let text = topTextField.text, text != defaultTopText, !text.isEmpty else {
            return nil
        }
        return text
    }

    //
    //  Get the text entered in the top text field.
    //  If the text field contains the default placeholder text then return nothing.
    //
    private func getBottomText() -> String? {
        guard let text = bottomTextField.text, text != defaultBottomText, !text.isEmpty else {
            return nil
        }
        return text
    }
    
    
    
    //
    // MARK: UI alerts
    //
    
    
    
    //
    //  Show an error alert.
    //
    private func showAlert(for error: Error) {
        print("Cannot save meme > \(error)")
        let title = "Oops, something went wrong."
        let message = "The meme could not be saved."
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    //
    //  Shows a prompt to confirm dismissing the view controller. The prompt is only shown if changes have been made to
    //  the meme. If no changes have been made, then the prompt is not shown and the view is dismissed without
    //  prompting.
    //
    //  The user is prompted to discard any changes they may have made, or continue editing and complete the meme.
    //
    private func showDismissConfirmationIfNeeded(completion: @escaping () -> Void) {
        
        if !hasChanges() {
            // No content added - dismiss without confirmation.
            completion()
            return
        }
        
        // User has made changes. Prompt to discard changes.
        let title = "Your changes have not been saved"
        let message = "Do you want to discard your changes?"
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(
            UIAlertAction(
                title: "Discard Changes",
                style: .destructive,
                handler: { (action) in
                    completion()
            })
        )
        controller.addAction(
            UIAlertAction(
                title: "Continue Editing",
                style: .cancel,
                handler: nil
            )
        )
        present(controller, animated: true, completion: nil)
    }
}

//
//  Keyboard control.
//
extension MemeViewController {
    
    //
    //  Observe notifications for when keyboard appears and disappears.
    //
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: .UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: .UIKeyboardWillHide,
            object: nil
        )
    }
    
    //
    //  Remove keyboard notification observers.
    //
    fileprivate func unobserveKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: .UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .UIKeyboardWillHide,
            object: nil
        )
    }
    
    //
    //  Handle keyboard appearance notification. Calculate space used by keyboard, to allow the UI to adjust.
    //
    func keyboardWillShow(_ notification: Notification) {
        guard let frame = getFrameForKeyboardNotification(notification) else {
            return
        }
        
        // Calculate the space required to by the keyboard. See updateLayout() functions.
        contentInset = frame.height
    }
    
    //
    //  Handle keyboard disappearance notification.
    //
    func keyboardWillHide(_ notification: Notification) {
        // Keyboard is hidden, no content inset is required. See updateLayout() functions.
        contentInset = 0
    }
    
    //
    //  Utility function to calculate the display frame for the keyboard from a notification.
    //
    private func getFrameForKeyboardNotification(_ notification: Notification) -> CGRect? {
        let frameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        return frameValue?.cgRectValue
    }
}

//
//  UIScrollView delegate functions.
//
extension MemeViewController: UIScrollViewDelegate {
 
    //
    //  Required to enable zooming in the scroll view.
    //
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //  Use the image view as the content to zoom for the scroll view.
        return memeImageView
    }
}

//
//  UIImagePickerController delegate functions.
//
extension MemeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //
    //  User cancelled picker. Just dismiss the picker.
    //
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker cancelled")
        dismiss(animated: true, completion: nil)
    }

    //
    //  Handle image picked by the user.
    //      - Set the image on the view.
    //      - Calculate the minimum and maximum zoom scale, and zoom to the minimum size.
    //      - Configure the share/cancel buttons.
    //      - Dismiss the picker.
    //
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            dismiss(animated: true, completion: nil)
        }
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return;
        }
        print("picked image: \(image)")
        setMemeImage(image)
    }
}

