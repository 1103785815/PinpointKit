//
//  MIMEType.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// An enumeration of MIME types used in PinpointKit.
enum MIMEType: String {
    
    /// The MIME type used to represent a Portable Network Graphics image.
    case PNG = "image/png"
    
    /// The MIME type used to represent a JavaScript Object Notation data.
    case JSON = "application/json"
    
    /// The file extension associated with the MIME type including the leading `.`.
    var fileExtension: String {
        switch self {
        case PNG:
            return ".png"
        case .JSON:
            return ".json"
        }
    }
}
