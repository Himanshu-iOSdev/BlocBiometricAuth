//
//  ViewController.swift
//  blockcert
//
//  Created by Himanshu Kesharwani on 18/01/21.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
  var isUnlocked: Bool = false
  
  @IBOutlet var keyLabel: UILabel!
  let appName = Bundle.main.infoDictionary!["app_name"] as? String ?? ""
      let appIdentifierPrefix =
        Bundle.main.infoDictionary!["AppIdentifierPrefix"] as? String ?? ""
      let service = Bundle.main.bundleIdentifier ?? "test"
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  @IBAction func onBtnClick(_ sender: Any) {
}
  
  
  
  @IBAction func showKeyBtn(_ sender: UIButton) {
    if isUnlocked {
      loadInfo()
    } else {
      authenticationWithTouchID() //Function Call
    }
  }
  
  
  
  @IBAction func saveKeyBtn(_ sender: UIButton) {
    if isUnlocked {
      let key = "Test\((arc4random_uniform(10)))"
      print("Key = \(key)")
      addPrivateKey(key: key)
    } else {
      authenticationWithTouchID() //Function Call
    }
  }
  
  func ShowAlert(message: String) {
    let alertController = UIAlertController(title: "Biometric Auth", message: message, preferredStyle:UIAlertController.Style.alert)

    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
    { action -> Void in
      // Put your code here
    })
    self.present(alertController, animated: true, completion: nil)
  }
  
  
  


}

extension ViewController {
    
    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"

        var authError: NSError?
        let reasonString = "To access the secure data"
      DispatchQueue.main.async {
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                  DispatchQueue.main.async {
                    self.ShowAlert(message: "Biometric Auth Worked")
                    self.isUnlocked = true
                  }
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                  
                    print("Error")
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                  self.ShowAlert(message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print("Error 2: ", self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
          self.ShowAlert(message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))

        }
      }

       
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
                case LAError.biometryNotAvailable.rawValue:
                    message = "Authentication could not start because the device does not support biometric authentication."
                
                case LAError.biometryLockout.rawValue:
                    message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
                case LAError.biometryNotEnrolled.rawValue:
                    message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
                default:
                    message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
                case LAError.touchIDLockout.rawValue:
                    message = "Too many failed attempts."
                
                case LAError.touchIDNotAvailable.rawValue:
                    message = "TouchID is not available on the device"
                
                case LAError.touchIDNotEnrolled.rawValue:
                    message = "TouchID is not enrolled on the device"
                
                default:
                    message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"

        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
}

extension ViewController {
  
  func loadInfo(userId: String? = nil) {
    let accessGroup = appIdentifierPrefix + "com.blockcerts.front-office"
    print("accessGrouploadInfo = \(accessGroup)")
    let keychain = A0SimpleKeychain(service: service, accessGroup: accessGroup)
    guard let data = keychain.data(forKey: "keychain-for-\(service)") else {
      print("Empty data")
      return }
    guard let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? String else {
      print("Empty ArrayKeys ")
      return }

    print("Keys = \(array)")
    keyLabel.text = array
  }

  func addPrivateKey(key: String) {
    //privateKeys.append(key)
    let accessGroup = appIdentifierPrefix + "com.blockcerts.front-office"
    print("accessGroupaddPrivateKey = \(accessGroup)")
    let data = NSKeyedArchiver.archivedData(withRootObject: key)
    let keychain = A0SimpleKeychain(service: service, accessGroup:  accessGroup)
    keychain.setData(data, forKey: "keychain-for-\(service)")
  }

}


