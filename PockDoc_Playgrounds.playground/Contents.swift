//: Playground - noun: a place where people can play

import UIKit

let appname = "PockDoc"
var user = "Bob"
var greeting = "Hello"
print(greeting + user + " to " + appname)

var anything: Any = "joe"
anything = 4


for i in 1...5 {
    print("smile")
}


let food = "candy"
switch food {
    case "meat":
        let comment: String = "meaty!"
    case "candy":
        let comment: String = "sweet!"
    default:
        let comment: String = "BORING!"
}