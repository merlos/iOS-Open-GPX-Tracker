//
//  String+DiskCache.swift
//  MapCache
//
//  Created by merlos on 02/06/2019.
//
//  Based on String+Haneke.swift
//  Haneke
//  https://github.com/Haneke/HanekeSwift/blob/master/Haneke/String%2BHaneke.swift
//
//

import Foundation

extension String {
    
    func escapedFilename() -> String {
        return [ "\0":"%00", ":":"%3A", "/":"%2F" ]
            .reduce(self.components(separatedBy: "%").joined(separator: "%25")) {
                str, m in str.components(separatedBy: m.0).joined(separator: m.1)
        }
    }
    
    func toMD5() -> String {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return self
        }
        
        let MD5Calculator = MD5(Array(data))
        let MD5Data = MD5Calculator.calculate()
        let resultBytes = UnsafeMutablePointer<CUnsignedChar>(mutating: MD5Data)
        let resultEnumerator = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: MD5Data.count)
        let MD5String = NSMutableString()
        for c in resultEnumerator {
            MD5String.appendFormat("%02x", c)
        }
        return MD5String as String
    }
    
    func MD5Filename() -> String {
        let MD5String = self.toMD5()
        
        // NSString.pathExtension alone could return a query string, which can lead to very long filenames.
        let pathExtension = URL(string: self)?.pathExtension ?? (self as NSString).pathExtension
        
        if pathExtension.count > 0 {
            return (MD5String as NSString).appendingPathExtension(pathExtension) ?? MD5String
        } else {
            return MD5String
        }
    }
    
}
