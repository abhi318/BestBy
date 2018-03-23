import UIKit
import FirebaseDatabase

class SpacesCollectionViewController: UICollectionViewController {
    
    var ref: DatabaseReference!
    var sema: DispatchSemaphore = DispatchSemaphore(value: 0)
    var done:  Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        self.title = "Spaces"
        //print(currentUser.shared.allSpaces.count)
        self.collectionView?.backgroundColor = UIColor(red: 1.0, green: 0.78, blue: 0.67, alpha: 1.0)
        self.collectionView?.frame = CGRect(
            x: (self.collectionView?.frame.minX)!,
            y: (self.collectionView?.frame.minY)!+70,
            width: (self.collectionView?.frame.width)!,
            height: (self.collectionView?.frame.height)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView?.reloadData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return currentUser.shared.allSpaces.count
        }
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.section == 1) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewList", for: indexPath) as! newSpaceClicked

            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SpacesCell
        let ratio = 1-Double(indexPath.row)/Double(currentUser.shared.allSpaces.count)
        
        cell.contentView.backgroundColor = UIColor(red: 1.0, green: 0.78 + 0.12 * CGFloat(ratio), blue: 0.67, alpha: 1.0)
        cell.collectionOfFoods?.backgroundColor = UIColor(named:"clear")
        
        var foodListAtIndex:FoodList?
        if(indexPath.item == 0) {
            foodListAtIndex = currentUser.shared.allSpaces[currentUser.shared.allFoodListID!]
        }
        else {
            foodListAtIndex = currentUser.shared.allSpaces[currentUser.shared.otherFoodListIDs[indexPath.item-1]]
        }
        cell.listName?.text = foodListAtIndex?.name
        cell.currentList = foodListAtIndex
        cell.collectionOfFoods?.reloadData()
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewList", for: indexPath) as! newSpaceClicked
            
            cell.label.isHidden = true
            cell.newSpaceText?.isHidden = false
            cell.newSpaceText?.isUserInteractionEnabled = true
            
            return
        }
        
        let layout = collectionViewLayout as! SpacesLayout
        let offset = layout.dragOffset * CGFloat(indexPath.item)
        if collectionView.contentOffset.y != offset {
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }
        
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
    
//    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        if(indexPath.item == 0) {
//            return false
//        }
//        return true
//    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = currentUser.shared.otherFoodListIDs[sourceIndexPath.item - 1]
        currentUser.shared.otherFoodListIDs.remove(at: sourceIndexPath.item - 1)
        currentUser.shared.otherFoodListIDs.insert(temp, at:destinationIndexPath.item - 1)
    }
}

class newSpaceClicked : UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var newSpaceText: UITextField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.newSpaceText?.backgroundColor = UIColor(named:"clear")
        self.newSpaceText?.delegate = self
        
    }
}

extension newSpaceClicked: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newSpaceText {
            let listRef = Database.database().reference().child("Users/\(currentUser.shared.ID!)/Spaces").childByAutoId()
            Database.database().reference().child("Users/\(currentUser.shared.ID!)/Spaces/\(listRef.key)").setValue(textField.text)
            
            currentUser.shared.otherFoodListIDs.append(listRef.key)
            
            currentUser.shared.allSpaces[listRef.key] = FoodList()
            currentUser.shared.allSpaces[listRef.key]!.name = textField.text
            
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}

class SpacesCell : UICollectionViewCell{
    
    @IBOutlet weak var listName:UILabel?
    @IBOutlet weak var collectionOfFoods:UICollectionView?
    
    var currentList:FoodList?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionOfFoods?.dataSource = self
        self.collectionOfFoods?.delegate = self
        self.collectionOfFoods?.isScrollEnabled = false
    }
    
}


extension SpacesCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(currentList == nil) {
            index
            return 0
        }
        return ((currentList!.contents.count < 18) ? currentList!.contents.count : 18)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCell", for: indexPath) as! FoodPreviewCell
        
        if collectionView == collectionOfFoods {
            if (FoodData.food_data[((currentList?.contents[indexPath.item])?.name)!] == nil) {
                cell.img.image = UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal)
            } else {
                cell.img.image = FoodData.food_data[((currentList?.contents[indexPath.item])?.name)!]!.2
            }
            
            let foodItem = currentList?.contents[indexPath.item]

            let daysLeft = ((foodItem?.timestamp)! - Int(Date().timeIntervalSinceReferenceDate)) / 86400
            
            var ratio = (CGFloat(daysLeft)/40.0)
            if ratio > 1 {
                ratio = 1
            }
            
            cell.backgroundColor = UIColor(named:"white")
            cell.ratio = ratio
        }
            
        return cell
    }
    
}

class FoodPreviewCell : UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    
    var overlay:UIView?
    var ratio: CGFloat = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        overlay = UIView(frame: CGRect(x: -5, y: -5, width: img.frame.size.width + 10, height: img.frame.size.height + 10))
        overlay?.layer.cornerRadius = CGFloat(roundf(Float((overlay?.frame.size.width)! / 2.0)))
        img.addSubview(overlay!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlay?.backgroundColor = UIColor(hue: ratio/3, saturation: 1.0, brightness: 1.0, alpha: 0.3)
    }
    
}




