//
//  main.swift
//  SwiftDemo
//
//  Created by gang.zhou on 2019/6/15.
//  Copyright © 2019 gang.zhou. All rights reserved.
//

import Foundation
import SQLite3
print("Hello, World!")

let dispatchQueue = DispatchQueue.init(label: "MyDispathQueue"
    ,attributes:DispatchQueue.Attributes.concurrent)
print(dispatchQueue.label)

func encodedPostParams(params:[String:String]) -> Data {
    var eParams:String = ""
    for (key,value) in params {
        eParams.append(key)
        eParams.append("=")
        eParams.append(value)
        eParams.append("&")
    }
    eParams.removeLast()
    return eParams.data(using: .utf8)!
}

struct BaseResponse:Decodable {
    var result:Int8?
    var description:String?
    var systemTime:Int64?
}


/**
    发送网络请求
 */
func doPost(_ postUrl:String,params:[String:String]?){
    var request = URLRequest.init(url: (URL.init(string: postUrl))!)
    request.httpMethod = "POST"
    if let params = params {
        request.httpBody = encodedPostParams(params: params)
    }
    request.addValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
    let task = URLSession.shared.dataTask(with: request, completionHandler: {data,response,error in
        if let error = error {
            print("request error \(postUrl) \(error.localizedDescription)")
            return
        } else if let response = response , response is HTTPURLResponse {
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                print("\(httpResponse.statusCode)")
                print(Thread.current)
            } else {
                if let data = data,0 < data.count {
                    print(try! JSONDecoder().decode(BaseResponse.self, from: data))
                    print(Thread.current)
                } else {
                    print("返回为NULL")
                }
            }
        }
    })
    task.resume()
}

let dispathGroup = DispatchGroup.init();

for i in 0...10{
    dispatchQueue.async(group:dispathGroup) {
        print("This is \(Thread.current) \(i)")
    }
}



dispathGroup.notify(queue: dispatchQueue, work: DispatchWorkItem(){
    print("Notify Finish \(Thread.current)")
})


dispathGroup.wait()

let name:String = "Hello Swift!"


if name.count > 0 {
    print(name)
}

for _ in 1...1 {
doPost("https://www.mytian.com.cn/myt_market/userAction_login.do"
    , params: ["user.phone":"18307207411","user.password":"123456"
        ,"deviceType":"android","app_channel":"mytian","client_version":"93"])
}

let operationQueue = OperationQueue.init()

print(operationQueue.maxConcurrentOperationCount)
for i in 1...1 {
    operationQueue.addOperation {
        print("\(i)")
        sleep(3)
    }
}

operationQueue.waitUntilAllOperationsAreFinished()

print(Thread.current)



struct MyStudent{
    var name:String?
}

var student = MyStudent()
student.name = "W"
print("student name \(student.name!)")

var student1 = student
student1.name = "H"
print("\(student.name!)")
print("student name \(student1.name!)")

extension Int {
    func sayMe(){
        print("sayMe:\(self)")
    }
}

let w = 10

print(w.sayMe())




class MyUrlSessionsDelegate:NSObject{
    
}


struct Persons:Decodable,Encodable{
    var sex:Int8?
    var age:Int8?
    var name:String?
}

var persons = Persons()
persons.name = "gang.zhou"
persons.age = 10
persons.sex = 1

print(Date().timeIntervalSince1970)
print("Persons : \(String.init(data: (try! JSONEncoder().encode(persons)), encoding: .utf8)!)")
print(Date().timeIntervalSince1970)

extension MyUrlSessionsDelegate:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        do {
            try FileManager.default.moveItem(at: location
                , to:URL.init(fileURLWithPath: "/Users/gang.zhou/Projects/ios/SwiftDemo/SwiftDemo/download"))
            try FileManager.default.removeItem(at: location)
        } catch _ as NSError{
            print("处理文件失败")
            do {
                try FileManager.default.removeItem(at: location)
            } catch _ as NSError{
                print("删除文件失败")
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("\(bytesWritten) \(totalBytesWritten) \(totalBytesExpectedToWrite) \(Date().timeIntervalSince1970 * 1000)")
    }
}

let myUrlSessionDelegate = MyUrlSessionsDelegate()

let myURLSession = URLSession.init(configuration: .default, delegate: myUrlSessionDelegate, delegateQueue: nil)
myURLSession.downloadTask(with: URL.init(string: "http://www.baidu.com")!).resume()


enum MyError:Error{
    case Error1
    case Error2
    case Error3
}
func demoFunc(i : Int) throws ->Int {
    switch i {
    case 1:
        throw MyError.Error1
    case 2:
        throw MyError.Error2
    case 3:
        throw MyError.Error3
    default:
        return i
    }
}



for i in 1...9 {
    for j in 1...i {
        print("\(j) x \(i) = \(i * j)", terminator: "")
        
        if (i * j) < 10 {
            print(" ", terminator: "")
        }
        
        if i != j {
            print("  ", terminator: "")
        }
    }
    print("")
}

open class SqliteDatabase:NSObject {
    private override init() {
        super.init()
        self.openDB()
    }
    
    public static let instance:SqliteDatabase = SqliteDatabase()
    private static let DB_NAME:String = "demo.db"
    private static let DB_VERSION:Int32 = 2
    private var db:OpaquePointer? = nil
    
    private func openDB(){
        if SQLITE_OK == sqlite3_open("/Users/gang.zhou/Projects/ios/SwiftDemo/SwiftDemo/\(SqliteDatabase.DB_NAME)".cString(using: .utf8),&db) {
            print("Database \(SqliteDatabase.DB_NAME):\(SqliteDatabase.DB_VERSION) Open ok!")
            var ppStmt:OpaquePointer? = nil
            if SQLITE_OK == sqlite3_prepare_v2(db, "PRAGMA USER_VERSION".cString(using: .utf8)
                , -1, &ppStmt, nil) {
                if sqlite3_step(ppStmt) == SQLITE_ROW {
                    let userVersion = sqlite3_column_int(ppStmt, 0)
                    print("User Version \(userVersion)")
                    if 0 == userVersion {
                        onCreate()
                    } else if (userVersion < SqliteDatabase.DB_VERSION) {
                        onUpgrade(oldVersion: userVersion
                            , newVersion: SqliteDatabase.DB_VERSION)
                    }
                    if 0 == userVersion || userVersion < SqliteDatabase.DB_VERSION {
                        sqlite3_exec(db, "PRAGMA USER_VERSION= \(userVersion)".cString(using: .utf8), nil, nil, nil)
                    }
                }
                sqlite3_finalize(ppStmt)
            }
        }
    }
    
    
    private func onCreate() {
        print("onCreate")
    }
    
    private func onUpgrade(oldVersion:Int32,newVersion:Int32){
        print("onUpgrade")
    }
}

print(SqliteDatabase.instance)
print(SqliteDatabase.instance)
print(SqliteDatabase.instance)
print(SqliteDatabase.instance)

var db:OpaquePointer? = nil
if SQLITE_OK ==  sqlite3_open("/Users/gang.zhou/Projects/ios/SwiftDemo/SwiftDemo/demo.db".cString(using: .utf8)!
    , &db){
    print("Database open ok!")
    var err:UnsafeMutablePointer<Int8>? = nil
    if SQLITE_OK != sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Persons(_id INTEGER PRIMARY KEY,name TEXT)".cString(using: .utf8)!, nil, nil, &err) {
        print("exec Fail! Error:\(err!)")
    } else {
        for i in 0...1000 {
            sqlite3_exec(db, "INSERT INTO Persons(name) VALUES ('gang.zhou\(i)')".cString(using: .utf8), nil, nil, nil)
        }
    }
}








