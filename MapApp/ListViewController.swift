//
//  ListViewController.swift
//  MapApp
//
//  Created by Tuba Nur YAŞA on 3.04.2022.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var listTableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var choisenPlaceName = ""
    var choisenPlaceId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        listTableView.dataSource = self
        listTableView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlace))
        
        getData()
    }
    
    func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(request)
            
            if results.count > 0 {
                nameArray.removeAll(keepingCapacity: false)
                idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                }
                listTableView.reloadData()
            }
        }catch{
            
        }
    }
    
    @objc func addPlace(){
        choisenPlaceName = ""
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choisenPlaceName = nameArray[indexPath.row]
        choisenPlaceId = idArray[indexPath.row]
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC" {
            let destinationVC = segue.destination as! MapViewController
            destinationVC.choisenName = choisenPlaceName
            destinationVC.choisenId = choisenPlaceId
        }
    }
}
