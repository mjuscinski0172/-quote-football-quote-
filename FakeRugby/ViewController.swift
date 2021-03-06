//
//  ViewController.swift
//  FakeRugby
//
//  Created by Michal Juscinski on 3/1/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {
    
    var resetAllPassword = "57bw32Gc"
    var studentArray = [CKRecord]()
    var database = CKContainer.default().publicCloudDatabase
    var timer = Timer()

    @IBOutlet weak var deleteAllButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.internetTest()
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (t) in
            self.internetTest()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true

    }
    
    @IBAction func OnDeleteAllStudentsPressed(_ sender: Any) {
        //Creates an alert for the user to input the password before deleting all students
        let passwordAlert = UIAlertController(title: "Delete all students?", message: "If you would like to delete all students from the database, please insert your password", preferredStyle: .alert)
        passwordAlert.addTextField { (textField) in
            textField.placeholder = "Password"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { (action) in
            //Check if password is correct
            let passwordTextField = passwordAlert.textFields![0]
            if passwordTextField.text == self.resetAllPassword {
                self.createConfirmationAlert(goodOrBad: true)
            }
            else {
                self.createConfirmationAlert(goodOrBad: false)
            }
        }
        //Adds all buttons and presents alert on which password is inputted
        passwordAlert.addAction(cancelAction)
        passwordAlert.addAction(confirmAction)
        present(passwordAlert, animated: true, completion: nil)
    }
    
    func createConfirmationAlert (goodOrBad: Bool){
        if goodOrBad ==  true {
            //Double-checks with user
            let areYouPositive = UIAlertController(title: "Are you sure?", message: "All student records will be deleted", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.createStudentArray()
                //Displays an alert to give user confirmation that all students have been deleted
                let thanks = UIAlertController(title: "All student records have been deleted", message: "", preferredStyle: .alert)
                let thanksButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
                thanks.addAction(thanksButton)
                self.present(thanks, animated: true, completion: nil)
            })
            let cancelAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            //Adds all buttons and presents alert to double-check
            areYouPositive.addAction(OKAction)
            areYouPositive.addAction(cancelAction2)
            self.present(areYouPositive, animated: true, completion: nil)
        }
        else {
            //If password is incorrect, tell the user
            let youDunGoofedAlert = UIAlertController(title: "Password Incorrect", message: "The password you entered was incorrect.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            //Adds all buttons and presents alert about incorrect password
            youDunGoofedAlert.addAction(OKAction)
            self.present(youDunGoofedAlert, animated: true, completion: nil)
        }
        
    }
    
    func createStudentArray() {
        //Clears local studentArray and queries CloudKit
        studentArray.removeAll()
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Students", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            //Fills studentArray with all records
            for student in records! {
                self.studentArray.append(student)
            }
            //Goes through studentArray and deletes each student
            DispatchQueue.main.async {
                for student in self.studentArray {
                    self.database.delete(withRecordID: student.recordID, completionHandler: { (id, error) in
                        //Displays an alert if there is an error
                        if error != nil {
                            let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }
    
    func internetTest() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "JSONUrl", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            if records?.count == 0 {
                //If we cannot pull the JSON URL from CloudKit, there is probably no internet so tell the user
                let alert = UIAlertController(title: "Error: No Internet Connection", message: "Please connect to the Internet and try again", preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.internetTest()
                })
                alert.addAction(retryAction)
                self.present(alert, animated: true, completion: nil)
            }
            else if error != nil{
                //Creates an alert to inform the user of the error if there is one
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.internetTest()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

