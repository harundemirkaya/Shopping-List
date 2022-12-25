//
//  DetailsViewController.swift
//  CoreDataExample
//
//  Created by Harun Demirkaya on 22.12.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var txtFieldSize: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtFieldPrice: UITextField!
    var productID: UUID?
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(productID != nil){
            btnSave.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
            fetchRequest.returnsObjectsAsFaults = false
            let uuidString = productID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString!)
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            txtFieldName.text = name
                        }
                        if let size = result.value(forKey: "size") as? String{
                            txtFieldSize.text = size
                        }
                        if let price = result.value(forKey: "price") as? Int{
                            txtFieldPrice.text = String(price)
                        }
                        if let image = result.value(forKey: "image") as? Data{
                            let uiImage = UIImage(data: image)
                            imgView.image = uiImage
                        }
                        
                    }
                }
            } catch{
                print("Error")
            }
        }
        else{
            btnSave.isHidden = false
            btnSave.isEnabled = false
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imgView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imgView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        shopping.setValue(txtFieldName.text, forKey: "name")
        shopping.setValue(txtFieldSize.text, forKey: "size")
        shopping.setValue(UUID(), forKey: "id")
        
        if let price = Int(txtFieldPrice.text!){
            shopping.setValue(price, forKey: "price")
        }
        
        let image = imgView.image?.jpegData(compressionQuality: 0.5)
        shopping.setValue(image, forKey: "image")
        
        do{
            try context.save()
        } catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgView.image = info[.editedImage] as? UIImage
        btnSave.isEnabled = true
        picker.dismiss(animated: true)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
   
    
    
}
