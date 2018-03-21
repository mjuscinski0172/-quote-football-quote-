//
//  ScanViewController.swift
//  FakeRugby
//
//  Created by Jimmy Rodriguez on 3/1/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var database =  CKContainer.default().publicCloudDatabase
    let place = CKRecord(recordType: "Students")
    var studentArray: NSArray!
    var altId = ""
    var pulledStudentArray = [Student]()
    var studentRecordExists = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
        }
        catch {
            return
        }
        
        if (session.canAddInput(videoInput!)) {
            session.addInput(videoInput!)
        } else {
            scanningNotPossible()
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.code39]
        } else {
            scanningNotPossible()
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        session.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
        super.viewWillAppear(animated)
        runSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    func getJSON(altID: String) {
        let urlString = "https://api.myjson.com/bins/16ljdv"
        let url = URL(string: urlString)!
        URLSession.shared.dataTask(with: url, completionHandler: { (myData, response, error) in
            if let JSONObject = try? JSONSerialization.jsonObject(with: myData!, options: .allowFragments) as! NSDictionary {
                self.studentArray = JSONObject.object(forKey: altID) as! NSArray
                let studentDictionary = self.studentArray.firstObject as! NSDictionary
                let firstName = studentDictionary.object(forKey: "First") as! NSString
                let lastName = studentDictionary.object(forKey: "Last") as! NSString
                let ID = studentDictionary.object(forKey: "ID") as! NSInteger
                self.chicken(altID: altID, ID: ID as Int, firstName: firstName as String, lastName: lastName as String)
            }
        }).resume()
    }
    
    func chicken(altID: String, ID: Int, firstName: String, lastName: String) {
        let predicate =  NSPredicate(format: "altIDNumber = '\(altID)'")
        let query = CKQuery(recordType: "Students", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let myRecords = records {
                if let student = myRecords.first {
                    if student.object(forKey: "checkedInOrOut") as! String == "In" {
                        let alert = UIAlertController(title: "Check out this student?", message: "\(lastName), \(firstName)\nID: \(ID)", preferredStyle: .alert)
                        let checkOutButton = UIAlertAction(title: "Yes, check out", style: .default, handler: { (action) in
                            //Gets time information from the calendar
                            let date = Date()
                            let calendar = Calendar.current
                            let hour = calendar.component(.hour, from: date)
                            let minutes = calendar.component(.minute, from: date)
                            var correctedMinutes = "\(minutes)"
                            //If minutes is a single digit number, add a 0 in front to make it look better
                            if minutes < 10 {
                                correctedMinutes = "0\(minutes)"
                            }
                            else if minutes >= 10{
                                correctedMinutes = "\(minutes)"
                            }
                            let timeOf = "\(hour):\(correctedMinutes)"
                            //Sets student as out with timestamp
                            student.setObject(timeOf as CKRecordValue, forKey: "checkOutTime")
                            student.setObject("Out" as CKRecordValue, forKey: "checkedInOrOut")
                            self.database.save(student, completionHandler: { (record, error) in
                                if error != nil {
                                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        self.runSession()
                                    })
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                                else {
                                    let alert = UIAlertController(title: "Checked Out", message: "This student has been checked out of the game", preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        self.runSession()
                                    })
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            })
                        })
                        let noAction = UIAlertAction(title: "No, the student is not leaving", style: .default, handler: { (action) in
                            self.runSession()
                        })
                        alert.addAction(noAction)
                        alert.addAction(checkOutButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        var alert = UIAlertController(title: "Error", message: "This student has been checked out already", preferredStyle: .alert)
                        var okButton = UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                            self.runSession()
                        })
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    //Gets time information from the calendar
                    let date = Date()
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minutes = calendar.component(.minute, from: date)
                    var correctedMinutes = "\(minutes)"
                    //If minutes is a single digit number, add a 0 in front to make it look better
                    if minutes < 10 {
                        correctedMinutes = "0\(minutes)"
                    }
                    else if minutes >= 10{
                        correctedMinutes = "\(minutes)"
                    }
                    let timeOf = "\(hour):\(correctedMinutes)"
                    //Sets the information of the student on CloudKit
                    let place = CKRecord(recordType: "Students")
                    place.setObject(firstName as CKRecordValue, forKey: "firstName")
                    place.setObject(lastName as CKRecordValue, forKey: "lastName")
                    place.setObject(String(ID) as CKRecordValue, forKey: "idNumber")
                    place.setObject(String(altID) as CKRecordValue, forKey: "altIDNumber")
                    place.setObject("In" as CKRecordValue, forKey: "checkedInOrOut")
                    place.setObject(timeOf as CKRecordValue, forKey: "checkInTime")
                    place.setObject("" as CKRecordValue, forKey: "checkOutTime")
                    place.setObject("Not implemented yet" as CKRecordValue, forKey: "studentParentPhone")
                    place.setObject("Not implemented yet" as CKRecordValue, forKey: "studentParentName")
                    //Saves student and checks for error
                    self.database.save(place) { (record, error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            let alert = UIAlertController(title: "Checked In", message: "Student \(firstName) \(lastName) has been accepted into the game", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                self.runSession()
                            })
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopSession()
        if let barcodeData = metadataObjects.first {
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject
            
            if let readableCode = barcodeReadable{
                self.altId = readableCode.stringValue!
                getJSON(altID: altId)
            }
        }
    }
    
    func runSession() {
        if (session?.isRunning == false) {
            session.startRunning()
        }
    }
    
    func stopSession() {
        if (session?.isRunning == true) {
            session.stopRunning()
        }
    }
    
    func scanningNotPossible() {
        let alert = UIAlertController(title: "This device can't scan.", message: "How did you mess this up? It was only supposed to be sent to camera-equipped iPads!", preferredStyle: .alert)
        let closeButton = UIAlertAction(title: "Yeah, I really screwed this up", style: .destructive, handler: nil)
        alert.addAction(closeButton)
        present(alert, animated: true, completion: nil)
    }
}
