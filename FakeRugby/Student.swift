//
//  Student.swift
//  FakeRugby
//
//  Created by Jimmy Rodriguez on 3/5/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import Foundation

class Student {
    var firstName: String
    var lastName: String
    var altIDNumber: String
    var idNumber: String
    var checkedInOrOut: String
    var checkInTime: String
    var checkOutTime: String
    var studentParentPhone: String
    var studentParentName: String
    
    init(firstName f: String, lastName l: String, altIDNumber a: String, idNumber i: String, checkedInOrOut c: String, checkInTime t: String, checkOutTime o: String, studentParentPhone s: String, studentParentName sn: String) {
        firstName = f
        lastName = l
        altIDNumber = a
        idNumber = i
        checkedInOrOut = c
        checkInTime = t
        checkOutTime = o
        studentParentPhone = s
        studentParentName = sn
    }
}

