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
	if r != 0 {
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
		
		
		func getDbDialect() -> Int {
			
			var dbp  = [CChar](count: 2, repeatedValue: 0)
			dbp[0] = CChar(62/*isc_info_db_sql_dialect*/)
			dbp[1] = CChar(isc_info_end)
			
			var data = [Int8](count: 39, repeatedValue: 0)
			
			var result = -1
			
			/*
			isc_database_info(<#UnsafeMutablePointer<ISC_STATUS>#>, <#UnsafeMutablePointer<isc_db_handle>#>, <#Int16#>, <#UnsafePointer<ISC_SCHAR>#>, <#Int16#>, <#UnsafeMutablePointer<ISC_SCHAR>#>)
			*/
			let ret = isc_database_info(&fStatus, &fHandle, CShort(count(dbp)), &dbp,
				CShort(count(data)), &data)
			if ret != 0 {
				println("GetDBDialect")
				return -1
			}
			
			/*x := 0;
			while x < 40 do
			case ResBuf[x] of
			isc_info_db_sql_dialect :
			begin
			//Inc(x);
			Len := isc_portable_integer(@ResBuf[x+1], 2);
			Result := isc_portable_integer(@ResBuf[x+3], Len);
			Inc(x, Len+3);
			end;
			isc_info_end : Break;
			else inc(x);
			end;
			end;
			*/
			return result
		}
		
	/*	dpb := chr(isc_dpb_version1);
		dpb := dpb + chr(isc_dpb_user_name) + chr(Length(username)) + username;
		dpb := dpb + chr(isc_dpb_password) + chr(Length(password)) + password;
		
	*/
		let user = removeZero(username)
		let passw = removeZero(password)
		
		var dbp = [Int8(isc_dpb_version1), Int8(isc_dpb_user_name), Int8(count(user))] + user +
					[Int8(isc_dpb_password), Int8(count(passw))] + passw
		
		var db = removeZero(database)
		/*
		isc_attach_database(<#UnsafeMutablePointer<ISC_STATUS>#>, <#Int16#>, <#UnsafePointer<ISC_SCHAR>#>, <#UnsafeMutablePointer<isc_db_handle>#>, <#Int16#>, <#UnsafePointer<ISC_SCHAR>#>)
*/
		let ret = isc_attach_database(&fStatus, CShort(count(db)), &db, &fHandle, CShort(count(dbp)), &dbp)
		if ret != 0 {
			if (fStatus[0] == 1) && (fStatus[1] != 0) {
				println(msgToString(UnsafeMutablePointer<UnsafePointer<CLong>>(fStatus)))
			}
		}
		
		fDialect = getDbDialect()
		
	}
	
	
}