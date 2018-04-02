import UIKit

import FirebaseDatabase


//var gradient = [UIColor.white]
var gradient = [UIColor(red:0.75, green:0.9, blue:0.45, alpha:1.0),
                UIColor(red:0.56, green:0.83, blue:0.376, alpha:1.0),
                UIColor(red:0.376, green:0.765, blue:0.318, alpha:1.0),
                UIColor(red:0.192, green:0.698, blue:0.255,  alpha:1.0),
                UIColor(red:0, green:0.631, blue:0.196, alpha:1.0)]
class SpacesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newSpace: UIButton!
    @IBAction func newSpaceClicked(_ sender: Any) {
        newSpace.isHidden = true
        textField.isEnabled = true
        self.textField.becomeFirstResponder()
    }
    @IBOutlet weak var textField: UITextField!
    
    var startLocation: CGPoint = CGPoint.zero
    var ref: DatabaseReference!
    var sema: DispatchSemaphore = DispatchSemaphore(value: 0)
    var done:  Bool = false
    var spacesRef: DatabaseReference!
    var bottomBG: UIView?
    var topBG: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.title = "Spaces"
        self.navigationItem.hidesBackButton = true
        
        newSpace.isHidden = false
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView?.frame = CGRect(
            x: (self.collectionView?.frame.minX)!,
            y: (self.collectionView?.frame.minY)! + 63,
            width: (self.collectionView?.frame.width)!,
            height: (self.collectionView?.frame.height)!)
        
        self.collectionView?.backgroundColor = UIColor(named:"clear")

        textField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapOut = UITapGestureRecognizer(target: self, action: #selector(self.tapOutOfEditing))
        tapOut.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapOut)
    }

    @objc func tapOutOfEditing(sender: UIGestureRecognizer) {
        textField?.resignFirstResponder()
    }
    
    @objc func respondToSwipeGesture(sender: UIGestureRecognizer) {
        
        
        if (sender.state == UIGestureRecognizerState.began) {
            startLocation = sender.location(in: self.view);
        }
        else if (sender.state == UIGestureRecognizerState.ended) {
            let stopLocation = sender.location(in: self.view);
            let dx = stopLocation.x - startLocation.x;
            let dy = stopLocation.y - startLocation.y;
            let distance = sqrt(dx*dx + dy*dy );
            NSLog("Distance: %f", distance);
            
            if distance > 200 {
                let cell = sender.view as! SpacesCell
                let idx = self.collectionView.indexPath(for: cell)!
                if idx.item == 0 {return}
                
                currentUser.shared.allSpaces[cell.listID!] = nil
                currentUser.shared.otherFoodListIDs.remove(at: idx.item-1)
                
                Database.database().reference(withPath: "AllFoodLists/\(currentUser.shared.allFoodListID!)").observeSingleEvent(of: .value, with: { snapshot in
                    let allUsersFoods = snapshot.value as! [String: [String: Any]]
                    for (item, itemInfo) in allUsersFoods {
                        if (itemInfo["spaceID"] as! String) == cell.listID! {
                            let foodRef = Database.database().reference().child("AllFoodLists/\(currentUser.shared.allFoodListID!)/\(item)")
                            print ("food ref: \(foodRef)")
                            foodRef.updateChildValues(["spaceID" : currentUser.shared.allFoodListID!,
                                                       "spaceName" : "All"])
                        }
                    }
                })
                
                Database.database().reference(withPath: "Users/\(currentUser.shared.ID!)/Spaces").observeSingleEvent(of: .value, with: { snapshot in
                    let allUsersFoods = snapshot.value as! [String: String]
                    for (item, _) in allUsersFoods {
                        if item == cell.listID! {
                            Database.database().reference(withPath:  "Users/\(currentUser.shared.ID!)/Spaces/\(cell.listID!)").removeValue()
                        }
                    }
                })
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [],
                               animations: {
                                cell.transform = CGAffineTransform(translationX: -500, y: 0)
                },
                               completion: { finished in
                                self.collectionView.deleteItems(at: [idx])
                })
            }
        }
    }
    
    func textFieldShouldReturn(_ textF: UITextField) -> Bool {
        if textF == textField {
            let listRef = Database.database().reference().child("Users/\(currentUser.shared.ID!)/Spaces").childByAutoId()
            Database.database().reference().child("Users/\(currentUser.shared.ID!)/Spaces/\(listRef.key)").setValue(textField?.text)
             currentUser.shared.otherFoodListIDs.append(listRef.key)
            currentUser.shared.allSpaces[listRef.key] = FoodList()
            currentUser.shared.allSpaces[listRef.key]!.name = textField?.text
            
            self.reloadData()
            
            textField?.text = ""
            textField?.resignFirstResponder()
            
            return false
        }
        return true
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            newSpace.isHidden = true
            textField.isEnabled = true
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - newSpace.frame.height
            }
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            newSpace.isHidden = false
            textField.isEnabled = false
            textField.text = ""
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    func reloadData() {
        self.collectionView?.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return currentUser.shared.allSpaces.count
        }
        return 1
    }
    
    @objc func selectCellAt(_ sender: UIGestureRecognizer, idx: IndexPath) {
        self.collectionView.selectItem(at: idx, animated: true, scrollPosition: .centeredVertically)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SpacesCell
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        cell.addGestureRecognizer(swipeLeft)
        
        let ratio = 1 - Double(indexPath.row)/Double(currentUser.shared.allSpaces.count)
        
//        cell.layer.borderWidth = 1
//        
//        cell.layer.borderColor = UIColor(red: 0.75 * CGFloat(ratio), green: (0.9 - 0.631) * CGFloat(ratio) + 0.631, blue: (0.45 - 0.196) * CGFloat(ratio) + 0.196, alpha: 1.0).cgColor
        
        cell.collectionOfFoods?.backgroundColor = UIColor(named:"clear")
        
        var foodListAtIndex:FoodList?
        if(indexPath.item == 0) {
            cell.listID = currentUser.shared.allFoodListID!
            foodListAtIndex = currentUser.shared.allSpaces[currentUser.shared.allFoodListID!]
        }
        else {
            cell.listID = currentUser.shared.otherFoodListIDs[indexPath.item-1]
            foodListAtIndex = currentUser.shared.allSpaces[cell.listID!]
        }
        cell.listName?.text = foodListAtIndex?.name
        cell.currentList = foodListAtIndex
        cell.collectionOfFoods?.reloadData()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let presenter = navigationController?.childViewControllers[0] as? AllFoodViewController {
            var keyAtIndex:String?
            if (indexPath.item == 0){
                keyAtIndex = currentUser.shared.allFoodListID
            }
            else {
                keyAtIndex = currentUser.shared.otherFoodListIDs[indexPath.item-1]
            }
            presenter.currentListID = keyAtIndex
            presenter.currentListName = currentUser.shared.allSpaces[keyAtIndex!]?.name
        }

        self.navigationController?.isNavigationBarHidden = false
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if(indexPath.item == 0) {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = currentUser.shared.otherFoodListIDs[sourceIndexPath.item - 1]
        currentUser.shared.otherFoodListIDs.remove(at: sourceIndexPath.item - 1)
        currentUser.shared.otherFoodListIDs.insert(temp, at:destinationIndexPath.item - 1)
        
        DispatchQueue.main.async{
            self.collectionView?.reloadData()
        }
    }
}


