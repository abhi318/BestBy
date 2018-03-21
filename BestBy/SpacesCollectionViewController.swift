import UIKit
import FirebaseDatabase

class SpacesCollectionViewController: UICollectionViewController {
    
    var ref: DatabaseReference!
    
//    @IBAction func addNewList(_ sender: Any) {
//        let alert = UIAlertController(title: "New List", message: "Give it a name", preferredStyle: .alert)
//        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
//            guard let textField = alert.textFields?.first,
//                let text = textField.text else { return }
//
//            let listRef = self.ref.child("AllFoodLists").childByAutoId()
//
//            self.ref.child("FoodListInfo/\(listRef.key)/name").setValue(text)
//            self.ref.child("FoodListInfo/\(listRef.key)/sharedWith/\(currentUser.shared.ID!)").setValue(true)
//            self.ref.child("Users/\(currentUser.shared.ID!)/UserFoodListIDs/\(listRef.key)").setValue(true)
//            //self.ref.child("AllFoodLists/\(listRef.key)").setValue(true)
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel",
//                                         style: .default)
//
//        alert.addTextField()
//
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        self.title = "Spaces"
        print(currentUser.shared.allSpaces.count)
        if(currentUser.shared.allSpaces.count == 1) {
            observeUsersFoodLists()
        }
    }
    
    func observeUsersFoodLists() {
        ref.child("Users/\(currentUser.shared.ID!)/UserFoodListIDs").observe(.childAdded, with: { (snapshot) in
            let newFoodListID = snapshot.key
            self.getListData(listID: newFoodListID)
        })
    }
    
    func getListData(listID: String) {
        ref.child("FoodListInfo/\(listID)").observeSingleEvent(of: .value, with: { (snapshot) in
            let listInfo = snapshot.value as! [String: Any]
            let name = listInfo["name"] as! String
            let listItem = FoodList(id:snapshot.key, n: name, shared:[])
            listItem.sharedWith = Array((listInfo["sharedWith"] as! [String:Bool]).keys)
        
            
            currentUser.shared.allSpaces[listID] = (listItem)
            
            DispatchQueue.main.async{
                self.collectionView?.reloadData()
            }
        })
        
        ref.child("AllFoodLists/\(listID)").observe(.childAdded, with: { snapshot in
            let itemInfo = snapshot.value as! [String:Any]
            let newFoodItem = FoodItem(id: snapshot.key, n: itemInfo["name"] as! String, t: itemInfo["timestamp"] as! Int)
            
            currentUser.shared.allSpaces[listID]?.contents.append(newFoodItem)
            
            currentUser.shared.allSpaces[listID]!.contents.sort() {
                $0.timestamp < $1.timestamp
            }
            
            DispatchQueue.main.async{
                self.collectionView?.reloadData()
            }
        })
        
        ref.child("AllFoodLists/\(listID)").observe(.childRemoved, with: { (snapshot) in
            let itemInfo = snapshot.value as! [String:Any]
            currentUser.shared.allSpaces[listID]?.contents = (currentUser.shared.allSpaces[listID]?.contents.filter {$0.ID != snapshot.key})!
            currentUser.shared.allSpaces[listID]!.contents.sort() {
                $0.timestamp < $1.timestamp
            }
            
            DispatchQueue.main.async{
                self.collectionView?.reloadData()
            }
        })
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentUser.shared.allSpaces.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SpacesCell
        cell.contentView.backgroundColor = UIColor(named:"white")
        cell.collectionOfFoods?.backgroundColor = UIColor(named:"clear")
        
        var foodListAtIndex:FoodList?
        if(indexPath.item == 0) {
            foodListAtIndex = currentUser.shared.allSpaces[currentUser.shared.allFoodListID!]
        }
        else {
            foodListAtIndex = currentUser.shared.allSpaces[Array(currentUser.shared.allSpaces.keys)[indexPath.item]]
        }
        cell.listName?.text = foodListAtIndex?.name
        cell.currentList = foodListAtIndex
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let presenter = navigationController?.childViewControllers[0] as? AllFoodViewController {
            var keyAtIndex:String?
            if (indexPath.item == 0){
                keyAtIndex = currentUser.shared.allFoodListID
            }
            else {
                keyAtIndex = Array(currentUser.shared.allSpaces.keys)[indexPath.item]
            }
            presenter.currentListID = currentUser.shared.allSpaces[keyAtIndex!]?.ID
            presenter.currentListName = currentUser.shared.allSpaces[keyAtIndex!]?.name
        }
        _ = navigationController?.popViewController(animated: true)
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
        self.collectionOfFoods?.reloadData()
    }
}

extension SpacesCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (currentUser.shared.allSpaces[(currentList?.ID)!]?.contents.count)!
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCell", for: indexPath) as! FoodPreviewCell
        
        cell.img.image = FoodData.food_data[((currentList?.contents[indexPath.item])?.name)!]!.2
        
        let foodItem = currentUser.shared.allSpaces[(currentList?.ID)!]?.contents[indexPath.item]

        let daysLeft = ((foodItem?.timestamp)! - Int(Date().timeIntervalSinceReferenceDate)) / 86400
        
        var ratio = (CGFloat(daysLeft)/40.0)
        if ratio > 1 {
            ratio = 1
        }
        
        let overlay: UIView = UIView(frame: CGRect(x: -5, y: -5, width: cell.img.frame.size.width + 10, height: cell.img.frame.size.height + 10))
        overlay.backgroundColor = UIColor(hue: ratio/3, saturation: 1.0, brightness: 1.0, alpha: 0.1)
        overlay.layer.cornerRadius = CGFloat(roundf(Float(overlay.frame.size.width / 2.0)))
        cell.img.addSubview(overlay)
        //cell.img.sendSubview(toBack: overlay)
        
        return cell
    }
}

class FoodPreviewCell : UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}




