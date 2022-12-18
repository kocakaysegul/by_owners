//
//  RegisterVC.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 15.10.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

    //Outlets
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var requestButtonOutlet: UIButton!
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func requestBtnPressed(_ sender: Any) {
        
    }
    @IBAction func registerBtnPressed(_ sender: Any) { // Email register button
        if emailTF.text != "" && nameTF.text != "" && lastNameTF.text != "" && passwordTF.text != "" {
            FUser.registerUserWith(email: emailTF.text!, password: passwordTF.text!, firstName: nameTF.text!, lastName: lastNameTF.text!, completion:  { (error) in
                if error != nil {
                    print("Error registering user with email: \(error?.localizedDescription)")
                    return
                }
                self.goToApp()
            })
        }
    }
    @IBAction func closeBtnPressed(_ sender: Any) {
        goToApp()
    }
    
    func goToApp() {
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
    


}
