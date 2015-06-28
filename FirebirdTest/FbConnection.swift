//
//  FbConnection.swift
//  FirebirdTest
//
//  Created by Stefc on 10.06.15.
//  Copyright (c) 2015 Stefc. All rights reserved.
//

import Foundation

func msgToString(status : UnsafeMutablePointer<UnsafePointer<CLong>>) -> String? {
	
	var buffer = [CChar](count: 100, repeatedValue: 0)
	
	// let r = isc_interprete(&buffer, status)
	let r = fb_interpret(&buffer, CUnsignedInt(40), status)
	if r != 0 {
		return String.fromCString(buffer)
	}
	else
	{
		print(" fb_interpret returns : \(r)")
	}
	return nil
}

func removeZero( value : String) -> [CChar] {
	var cstring = value.cStringUsingEncoding(NSASCIIStringEncoding)!
	cstring.removeAtIndex(cstring.count-1)
	return cstring
}


class FirebirdConnection {
	
	private var fHandle : CUnsignedInt = 0
	private var fStatus = [CLong](count: 20, repeatedValue: 0)
	private var fDialect : Int = -1
	
	
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
		
		// determine the dialect from the database
		func getDbDialect() -> Int {
			
			var dbp  = [CChar](count: 2, repeatedValue: 0)
			dbp[0] = CChar(isc_info_db_SQL_dialect)
			dbp[1] = CChar(isc_info_end)
			
			var data = [CChar](count: 39, repeatedValue: 0)
			
			var result = -1
			
			let ret = isc_database_info(&fStatus, &fHandle, CShort(dbp.count), &dbp, CShort(data.count), &data)
			if ret != 0 {
				return -1
			}
			
			var p : UnsafePointer<CUnsignedChar> = UnsafePointer<CUnsignedChar>(data)
			while (p != nil) && (p[0] != CUnsignedChar(isc_info_end)) {
				if p[0] == CUnsignedChar(isc_info_db_SQL_dialect) {
					p = p.successor()
					let len = Int(isc_portable_integer(p, CShort(2)))
					p = p.successor().successor()
					result = Int(isc_portable_integer(p, CShort(len)))
					for _ in 1...len { p = p.successor() }
				}
				else
				{
					p = p.successor()
				}
			}
			
			return result
		}
		
	/*	dpb := chr(isc_dpb_version1);
		dpb := dpb + chr(isc_dpb_user_name) + chr(Length(username)) + username;
		dpb := dpb + chr(isc_dpb_password) + chr(Length(password)) + password;
		
	*/
		let user = removeZero(username)
		let passw = removeZero(password)
		
		var dbp = [Int8(isc_dpb_version1), Int8(isc_dpb_user_name), Int8(user.count)] + user +
					[Int8(isc_dpb_password), Int8(passw.count)] + passw
		
		var db = removeZero(database)
		/*
		isc_attach_database(<#UnsafeMutablePointer<ISC_STATUS>#>, <#Int16#>, <#UnsafePointer<ISC_SCHAR>#>, <#UnsafeMutablePointer<isc_db_handle>#>, <#Int16#>, <#UnsafePointer<ISC_SCHAR>#>)
*/
		let ret = isc_attach_database(&fStatus, CShort(db.count), &db, &fHandle, CShort(dbp.count), &dbp)
		if ret != 0 {
			if (fStatus[0] == 1) && (fStatus[1] != 0) {
				let p = UnsafeMutablePointer<UnsafePointer<CLong>>(fStatus)
				print(msgToString(p))
			}
		}
		
		fDialect = getDbDialect()
		print( "Dialect : \(fDialect)")
		
	}
	
	
}