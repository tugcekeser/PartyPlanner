import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

// Mark:- Enum
enum AuthenticationType: String {
    case PartyPlanner = "PartyPlanner"
    case Google =  "Google"
    case Facebook = "Facebook"
    //  case Twitter
}

// Mark:- User Class
class User: NSObject {
    
    let fireBaseRef = FIRDatabase.database().reference(withPath: "user")
    
    var name: String
    var email: String?
    var phone: String?
    var imageUrl: String?
    var authType: String?
    var uid: String  // email id without any special characters. For "user.1@user.com" uid = "user1usercom
    var ref: FIRDatabaseReference?
    var key: String?
    
    static var logout: Notification = Notification(name: Notification.Name(rawValue: "UserLogOut"))
    
    
    override init(){
        //"Populate the user properties later"
        name = ""
        uid = ""
    }
    
    
    init(name: String,
         email: String?, phone: String? = nil,
         imageUrl: String?, authType: String? = AuthenticationType.PartyPlanner.rawValue,
         uid: String, ref: FIRDatabaseReference? = nil) {
        self.name = name
        self.email = email
        self.phone = phone
        self.imageUrl = imageUrl
        self.authType = authType
        self.uid = uid
        self.ref = ref ?? nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        ref = snapshot.ref
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        name = snapshotValue["name"] as! String
        email = snapshotValue["email"] as? String
        phone = snapshotValue["phone"] as? String
        imageUrl = snapshotValue["imageUrl"] as? String
        authType = snapshotValue["authType"] as? String
        uid = snapshotValue["uid"] as! String
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "email": email,
            "phone": phone,
            "imageUrl": imageUrl,
            "uid": uid,
            "authType": authType
        ]
    }
    
    static var _currentUser: User?
    
    static var currentUser : User? {
        get {
            
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                //        defaults.removeObject(forKey: "currentUserData")
                
                let userData = defaults.object(forKey: "currentUserData") as? Data
                if userData != nil {
                    let dictionary: [String:String] = try!
                        JSONSerialization.jsonObject(with: userData!, options: []) as! [String : String]
                    
                    print(dictionary)
                    _currentUser = User()
                    for (key,value) in dictionary{
                        switch key {
                        case "name":
                            _currentUser?.name = value
                        case "email":
                            _currentUser?.email = value
                        case "imageUrl":
                            _currentUser?.imageUrl = value
                        case "uid":
                            _currentUser?.uid = value
                        case "authType":
                            _currentUser?.authType = value
                        case "phone":
                            _currentUser?.phone = value
                        case "ref":
                            _currentUser?.ref = (value as? FIRDatabaseReference)
                        default:
                            _currentUser?.key = value
                        }
                    }
                }
                //                defaults.removeObject(forKey: "currentUserData")
                print("current user", _currentUser?.imageUrl)
            }
            return _currentUser
        }
        
        
        set(user) {
            
            let defaults = UserDefaults.standard
            
            if user != nil {
                var userDictionary: [String:String] = ["name": (user?.name)!, "email": (user?.email)!, "uid": (user?.uid)!, "authType": (user?.authType!)!]
                
                if user?.imageUrl != nil {
                    userDictionary["imageUrl"] = user?.imageUrl
                }
                if user?.phone != nil {
                    userDictionary["phone"] = user?.phone
                }
                if user?.ref != nil {
                    userDictionary["ref"] = String(describing: (user?.ref)!)
                }
                if user?.key != nil {
                    userDictionary["key"] = user?.key
                }
                
                let data = try! JSONSerialization.data(withJSONObject: userDictionary as Any, options: [])
                defaults.set(data, forKey: "currentUserData")
            }
            else {
                print("removing current user")
                defaults.removeObject(forKey: "currentUserData")
                
            }
            defaults.synchronize()
        }
    }
    
    func signout(){
        do {
            let user = FIRAuth.auth()?.currentUser
            user?.delete { error in
                if error != nil {
                    print("Error while deleting a user", error?.localizedDescription as Any)
                } else {
                    print(user as Any, " : has been deleted")
                }
            }
            try FIRAuth.auth()?.signOut()
            switch (User.currentUser?.authType)!  {
            case "Google":
                GIDSignIn.sharedInstance().signOut()
            case "Facebook":
                FBSDKLoginManager().logOut()
            default:
                break
            }
        } catch let signoutEror as NSError {
            print("Error in signout the user: ", signoutEror)
            return
        }
        //    UserApi.sharedInstance.removeUser(user: User.currentUser!)
        User.currentUser = nil
        NotificationCenter.default.post(User.logout)
    }
}
