//
//  main.swift
//  FirebirdTest
//
//  Created by Stefc on 09.06.15.
//  Copyright (c) 2015 Stefc. All rights reserved.
//

import Foundation


let version = FirebirdConnection.clientVersion
print("Hello,\(version.name) (\(version.major).\(version.minor)) World!")

let dbExample = "/Library/Frameworks/Firebird.framework/Resources/examples/empbuild/employee.fdb"
let username = "SYSDBA"
let password = "masterkey"

let d = FirebirdConnection(database: dbExample, username: username, password: password)




