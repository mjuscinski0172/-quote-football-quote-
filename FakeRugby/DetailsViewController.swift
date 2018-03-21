//
//  DetailsViewController.swift
//  FakeRugby
//
//  Created by Jimmy Rodriguez on 3/20/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import UIKit
import CloudKit
import SafariServices

class DetailsViewController: UIViewController {
    
    var superSecretPassword = "57bw32Gc"
    
    var selectedStudent: Student!
    var database: CKDatabase!
    //    var detailsStudentArray = [Student]()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var timeInLabel: UILabel!
    @IBOutlet weak var timeOutLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeInTitleLabel: UILabel!
    @IBOutlet weak var timeOutTitleLabel: UILabel!
    @IBOutlet weak var parentNameLabel: UILabel!
    @IBOutlet weak var parentPhoneNumberLabel: UILabel!
    @IBOutlet weak var statusTitlesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = selectedStudent.firstName + " " + selectedStudent.lastName
        parentNameLabel.text = selectedStudent.studentParentName
        parentPhoneNumberLabel.text = selectedStudent.studentParentPhone
        idLabel.text = selectedStudent.idNumber
        if selectedStudent.checkedInOrOut == "Purchased"{
            timeInLabel.alpha = 0
            timeOutLabel.alpha = 0
            timeInTitleLabel.alpha = 0
//            timeOutTitleLabel.alpha = 0
            statusLabel.text = "Purchased Tickets"
            
        }
        else if selectedStudent.checkedInOrOut == "In" {
            timeInLabel.alpha = 1
            timeInLabel.text = selectedStudent.checkInTime
            timeInTitleLabel.alpha = 1
//            timeOutTitleLabel.alpha = 0
            timeOutLabel.alpha = 0
            statusLabel.text = "In Dance"
        }
        else {
            timeInLabel.alpha = 1
            timeOutTitleLabel.alpha = 1
            timeOutLabel.alpha = 1
            timeOutTitleLabel.alpha = 1
            timeInLabel.text = selectedStudent.checkInTime
            timeOutLabel.text = selectedStudent.checkOutTime
            statusLabel.text = "Checked Out"
        }
    }
    
    
    @IBAction func toInfiniteCampus(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string: "https://ic.d214.org")!)
        self.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func removeStudent(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete this", message: "Please input passwrd", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Insert Password"
        }
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            let passTextField = alert.textFields![0]
            if passTextField.text == self.superSecretPassword {
                
                let predicate = NSPredicate(value: true)
                let query = CKQuery(recordType: "Students", predicate: predicate)
                self.database.perform(query, inZoneWith: nil) { (records, error) in
                    for student in records! {
                        if student.object(forKey: "firstName") as! String == self.selectedStudent.firstName  {
                            self.database.delete(withRecordID: student.recordID, completionHandler: { (record, error) in
                                if error != nil {
                                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                                else {
                                    Thread.sleep(forTimeInterval: 1.0)
                                    
                                    let alert = UIAlertController(title: "Student Deleted", message: nil, preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            })
                        }
                    }
                }
            }
            else {
                let failureAlert = UIAlertController(title: "Password Incorrect", message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                failureAlert.addAction(okAction)
                self.present(failureAlert, animated: true, completion: nil)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
