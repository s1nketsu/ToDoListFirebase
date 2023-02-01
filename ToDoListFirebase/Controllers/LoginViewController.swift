//
//  LoginViewController.swift
//  ToDoListFirebase
//
//  Created by Полищук Александр on 29.01.2023.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    let segueID = "tasksSegue"
    var reference: DatabaseReference!
    
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextFIeld: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reference = Database.database(url: API.databaseUrl).reference(withPath: "users")
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        warningLabel.alpha = 0
        addTapToCloseKeyboard()
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueID)!, sender: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextFIeld.text = ""
    }
    
    @objc func kbDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        var kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        kbFrameSize = self.view.convert(kbFrameSize, from: nil)
        
        var contentInset: UIEdgeInsets = (self.view as! UIScrollView).contentInset
        contentInset.bottom = kbFrameSize.size.height + 20
        (self.view as! UIScrollView).contentInset = contentInset
    }
    
    @objc func kbDidHide() {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        (self.view as! UIScrollView).contentInset = contentInset
    }
    
    private func addTapToCloseKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func closeKeyboard() {
        view.endEditing(true)
    }
    
    private func displayWarningLabel(with text: String, color: UIColor) {
        warningLabel.text = text
        warningLabel.textColor = color
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
            self?.warningLabel.alpha = 1
        } completion: { [weak self] _ in
            self?.warningLabel.alpha = 0
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextFIeld.text, email != "", password != "" else {
            displayWarningLabel(with: "Info is incorrect", color: .systemRed)
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if error != nil {
                self?.displayWarningLabel(with: "Check your email and password", color: .systemRed)
            }
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueID)!, sender: nil)
                return
            }
            
            self?.displayWarningLabel(with: "No such user", color: .systemRed)
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextFIeld.text, email != "", password != "" else {
            displayWarningLabel(with: "Info is incorrect", color: .systemRed)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            guard error == nil, user != nil else {
                print(error!.localizedDescription)
                return
            }
            
            let userReference = self?.reference.child((user?.user.uid)!)
            userReference?.setValue(["email": user?.user.email])
        }
    }
}

