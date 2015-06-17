//
//  FbConnection.swift
//  FirebirdTest
//
//  Created by Stefc on 10.06.15.
//  Copyright (c) 2015 Stefc. All rights reserved.
//

import Foundation

func msgToString(status : UnsafeMutablePointer<UnsafePointer<CLong>>) -> String? {
	
	var buffer = [CChar](count: 1024, repeatedValue: 0)
	
	let r = fb_interpret(&buffer, 20, status)
	if r == 0 {
		return String.fromCString(buffer)
	}
	return nil
}

func removeZero( value : String) -> [CChar] {
	var cstring = value.cStringUsingEncoding(NSASCIIStringEncoding)!
	cstring.removeAtIndex(count(cstring)-1)
	return cstring
}


class FirebirdConnection {
	
	private var fHandle : UnsafeMutablePointer<isc_db_handle> = nil
	private var fStatus = [CLong](count: 20, repeatedValue: 0)
	
	
	/// Determine Version of the client
	static var clientVersion : (name: String, major: Int32, minor: Int32) {
		get {
			var data = [Int8](count: 100, repeatedValue: 0)
			isc_get_client_version(&data)
			return (
				name: NSString(bytes: data, length: data.count, encoding: NSUTF8StringEncoding) as! String,
				major: isc_get_client_major_version(),
				minor: isc_get_client_minor_version())
		}
	}
	
	init(database: String, username: String, password: String) {
		
		
	/*	dpb := chr(isc_dpb_version1);
		dpb := dpb + chr(isc_dpb_user_name) + chr(Length(username)) + username;
		dpb := dpb + chr(isc_dpb_password) + chr(Length(password)) + password;
		
	*/
		let user = removeZero(username)
		let passw = removeZero(password)
		
		
		var dbp = [Int8(isc_dpb_version1), Int8(isc_dpb_user_name), Int8(count(user))] + user +
					[Int8(isc_dpb_password), Int8(count(passw))] + passw
		
		var db = removeZero(database)
		
		
		
		var buffer = [CChar](count: 1024, repeatedValue: 0)
		var pBuffer : UnsafeMutablePointer<CChar> = UnsafeMutablePointer<CChar>(buffer)
		

		let ret = isc_attach_database(&fStatus, CShort(count(db)), &db, fHandle, CShort(count(dbp)), &dbp)
		// 
		
		//let r = fb_interpret(&buffer, 20, UnsafeMutablePointer<UnsafePointer<CLong>>(fStatus))

		println(ret)
		
	}
	
	
}