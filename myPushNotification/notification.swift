//
//  File.swift
//  myPushNotification
//
//  Created by Anand Mukut Tirkey on 18/02/17.
//  Copyright © 2017 Anand Mukut Tirkey. All rights reserved.
//

import Foundation
class notifiacation{
    var code : Int?
    var label : String?
    var detail : String?
    init(code : Int,label : String?,detail : String?) {
        self.code = code
        self.detail = detail
        self.label = label
    }
    
}
