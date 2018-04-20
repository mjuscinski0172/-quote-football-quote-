//
//  ListViewController.swift
//  FakeRugby
//
//  Created by Jimmy Rodriguez on 3/14/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import UIKit
import CloudKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var studentArray = [Student]()
    var filteredArray = [Student]()
    var alphabeticalStudentArray = [Student]()
    let database = CKContainer.default().publicCloudDatabase
    
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .orange
        tableView.separatorColor = UIColor.orange
        
        resultsController.tableView.backgroundColor = .orange
        resultsController.tableView.separatorColor = .orange
        
        searchController = UISearchController(searchResultsController: resultsController)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.brown.darker(by: 30)
        self.navigationController?.navigationBar.tintColor = .white

    }
    
    override func viewDidAppear(_ animated: Bool) {
        studentArray = []
        filteredArray = []
        createStudentArray()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            let student = alphabeticalStudentArray[indexPath.row]
            cell.backgroundColor = UIColor.brown.darker(by: 20)
            cell.textLabel?.text = "                           " + "\(student.lastName), \(student.firstName)"
            cell.textLabel?.textColor = .white
            
            let label = self.fancyFunctionName(cell: cell)
            label.text = "\(student.checkedInOrOut)".uppercased()
            if student.checkedInOrOut == "In" {
                label.textColor = UIColor.green
            }
            if student.checkedInOrOut == "Out" {
                label.textColor = .red
            }
            cell.addSubview(label)
            
            return cell
        }
        else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "newCell")
            let student = filteredArray[indexPath.row]
            cell.backgroundColor = UIColor.brown.darker(by: 20)
            cell.textLabel?.text = "                         " + "\(student.lastName), \(student.firstName)"
            cell.textLabel?.textColor = .white
            
            let label = self.fancyFunctionName(cell: cell)
            label.text = "\(student.checkedInOrOut)".uppercased()
            if student.checkedInOrOut == "In" {
                label.textColor = UIColor.green
            }
            if student.checkedInOrOut == "Out" {
                label.textColor = .red
            }
            cell.addSubview(label)
            
            return cell
        }
    }
    
    func fancyFunctionName(cell: UITableViewCell) -> UILabel {
        if cell.subviews.count < 2 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 42))
            label.textAlignment = .center
            label.textColor = .white
            label.layer.addBorder(edge: UIRectEdge.right, color: UIColor.orange, thickness: 0.5)
            return label
        }
        else {
            return cell.subviews[2] as! UILabel
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultsController.tableView {
            return filteredArray.count
        } else{
            return alphabeticalStudentArray.count
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredArray = alphabeticalStudentArray.filter({ (studentArray:Student) -> Bool in
            let fullName = studentArray.firstName + " " + studentArray.lastName
            
            if (studentArray.lastName.lowercased().contains(searchController.searchBar.text!.lowercased()) || studentArray.firstName.lowercased().contains(searchController.searchBar.text!.lowercased()) || fullName.lowercased().contains(searchController.searchBar.text!.lowercased())){
                return true
            } else{
                return false
            }
        })
        resultsController.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resultsController.dismiss(animated: true, completion: nil)
    }
    
    func createStudentArray() {
        studentArray.removeAll()
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Students", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            for student in records! {
                let firstName = student.object(forKey: "firstName") as! String
                let lastName = student.object(forKey: "lastName") as! String
                let altIDNumber = student.object(forKey: "altIDNumber") as! String
                let idNumber = student.object(forKey: "idNumber") as! String
                let checkedInOrOut = student.object(forKey: "checkedInOrOut") as! String
                let checkInTime = student.object(forKey: "checkInTime") as! String
                let checkOutTime = student.object(forKey: "checkOutTime") as! String
                let studentParentPhone = student.object(forKey: "studentParentPhone") as! String
                let studentParentCell = student.object(forKey: "studentParentCell") as! String
                let studentParentName = student.object(forKey: "studentParentName") as! String
                
                let newStudent = Student(firstName: firstName, lastName: lastName, altIDNumber: altIDNumber, idNumber: idNumber, checkedInOrOut: checkedInOrOut, checkInTime: checkInTime, checkOutTime: checkOutTime, studentParentPhone: studentParentPhone, studentParentCell: studentParentCell, studentParentName: studentParentName)
                self.studentArray.append(newStudent)
                
                self.alphabeticalStudentArray = self.studentArray.sorted(by: { $0.lastName < $1.lastName })
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! DetailsViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            nvc.selectedStudent = alphabeticalStudentArray[indexPath.row]
            nvc.database = database
        }
        else {
            let indexPath = resultsController.tableView.indexPathForSelectedRow!
            nvc.selectedStudent = filteredArray[indexPath.row]
            nvc.database = database
        }
    }
}
