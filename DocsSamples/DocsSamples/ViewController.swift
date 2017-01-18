//
//  ViewController.swift
//  DocsSamples
//
//  Created by MP on 1/17/17.
//  Copyright © 2017 BackendlessOrganization. All rights reserved.
//

import UIKit

// declare a class - make sure it is declare in a separate .swift file
class Person : NSObject {
    var name : String?
    var age : Int = 0
}



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        savePerson();
        //savePersonAsMap();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func savePersonAsMap()
    {
// create a data object using an object map
let person = [
    "name": "Joe",
    "age": 25
    ] as [String : Any]

// Now save the object using either blocking or non-blocking API

// *************** blocking API ***********************
Types.tryblock({ () -> Void in
    let result = Backendless.sharedInstance().data.ofTable("Person").save(person)
    print("\(result)")
},
               catchblock: { (exception) -> Void in
                print("Server reported an error: \(exception as! Fault)")
})

// *************** non-blocking API ***********************
Backendless.sharedInstance().data.ofTable("Person").save( person,
      response: { (result : [String:Any]?) -> Void in
        print("\(result)")
},
      error: { ( fault : Fault?) -> () in
        print("Server reported an error: \(fault)")
})
    }
// ********************************************************************************************
// ********************************************************************************************
// ********************************************************************************************
    
    func savePerson()
    {
// Create a data object with the class declared above
let person = Person()
person.name = "Joe"
person.age = 25

// Now save the object using either blocking or non-blocking API

// ************ blocking API ***********************
Types.tryblock({ () -> Void in
    let result = Backendless.sharedInstance().data.of(Person.ofClass()).save(person)
    print("\(result)")
},
   catchblock: { (exception) -> Void in
   print("Server reported an error: \(exception as! Fault)")
})

// ************ non-blocking API ***********************
Backendless.sharedInstance().data.of(Person.ofClass()).save(
    person,
    response: { (result : (Any?)) -> Void  in
        let person = result as! Person;
        print("\(person.name)")
        print("\(result)")
},
    error: { ( fault : Fault?) -> () in
        print("Server reported an error: \(fault)")
});
    }


}

