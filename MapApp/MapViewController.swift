//
//  ViewController.swift
//  MapApp
//
//  Created by Tuba Nur YAŞA on 2.04.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    var locationManager = CLLocationManager()
    var choisenLatitude = Double()
    var choisenLongitude = Double()
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var noteTextField: UITextField!
    
    
    var choisenName = ""
    var choisenId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if choisenName != "" {
            if let uuidString = choisenId?.uuidString{
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0{
                        for result in results as! [NSManagedObject]{
                            if let name = result.value(forKey: "name") as? String{
                                annotationTitle = name
                            }
                            if let note = result.value(forKey: "note") as? String{
                                annotationSubtitle = note
                            }
                            if let latitude = result.value(forKey: "latitude") as? Double {
                                annotationLatitude = latitude
                            }
                            if let longitude = result.value(forKey: "longitude") as? Double{
                                annotationLongitude = longitude
                            }
                            
                            let annotation = MKPointAnnotation()
                            annotation.title = annotationTitle
                            annotation.subtitle = annotationSubtitle
                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                            annotation.coordinate = coordinate
                            
                            mapView.addAnnotation(annotation)
                            nameTextField.text = annotationTitle
                            noteTextField.text = annotationSubtitle
                        }
                    }
                }catch{
                    
                }
            }
        } else{
             
        }
    }

    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let touchLocation = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            
            choisenLatitude = touchCoordinate.latitude
            choisenLongitude = touchCoordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = nameTextField.text
            annotation.subtitle = noteTextField.text
            mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context)
        
        newPlace.setValue(nameTextField.text, forKey: "name")
        newPlace.setValue(noteTextField.text, forKey: "note")
        newPlace.setValue(choisenLatitude, forKey: "latitude")
        newPlace.setValue(choisenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
        }catch{
            print("error!")
        }
    }
}

