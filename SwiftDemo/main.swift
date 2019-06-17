//
//  main.swift
//  SwiftDemo
//
//  Created by gang.zhou on 2019/6/15.
//  Copyright © 2019 gang.zhou. All rights reserved.
//

import Foundation

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
                    print(String(data: data, encoding: .utf8)!)
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

for i in 1...1{
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


extension MyUrlSessionsDelegate:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        do {
            try FileManager.default.moveItem(at: location
                , to:URL.init(fileURLWithPath: "/Users/gang.zhou/Projects/ios/SwiftDemo/SwiftDemo/download"))
            print(location.absoluteString)
            try FileManager.default.removeItem(at: location)
        } catch {
            
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("\(bytesWritten) \(totalBytesWritten) \(totalBytesExpectedToWrite) \(Date().timeIntervalSince1970 * 1000)")
    }
}

let myUrlSessionDelegate = MyUrlSessionsDelegate()

let myURLSession = URLSession.init(configuration: .default, delegate: myUrlSessionDelegate, delegateQueue: nil)
myURLSession.downloadTask(with: URL.init(string: "https://www.charlesproxy.com/assets/release/4.2.8/charles-proxy-4.2.8.dmg")!).resume()



Thread.sleep(forTimeInterval: 1000)

