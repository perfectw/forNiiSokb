//
//  RSStructure.swift
//  forNiiSokb
//
//  Created by Roman Spirichkin on 02/02/16.
//  Copyright © 2016 rs. All rights reserved.
//

import UIKit

class Message {
    let title, urlImage : String
    var image : UIImage! = nil
    var isImageDataBroken : Bool = false
    var refreshID = 0
    init(title:  String, urlImage: String) {
        self.title = title;
        self.urlImage = urlImage;
    }
}
var messages : [Message] = []
var GlobalRefreshID = 0 // very hardcode (protect from writing image to nonexistent messages[i]; after refresh)
