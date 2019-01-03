//
//  GPXParser.swift
//  GPXKit
//
//  Created by Vincent on 2/11/18.
//  

import UIKit

open class GPXParser: NSObject {

    // MARK: Instance
    
    public func parseGPXAt(url: URL) -> GPXRoot? {
        do {
            let data = try Data(contentsOf: url)
            return self.parseGPXWith(data: data)
        }
        catch {
            print(error)
        }
        return nil
    }
    
    public func parseGPXAt(path: String) -> GPXRoot? {
        
        let url = URL(fileURLWithPath: path)
        return GPXParser().parseGPXAt(url: url)
    }
    
    public func parseGPXWith(string: String) -> GPXRoot? {
        
        let xml = try? TBXML(xmlString: string, error: ())

        if xml?.rootXMLElement != nil {
            return GPXRoot(XMLElement: xml!.rootXMLElement, parent: nil)
        }
        
        return nil
    }
    
    public func parseGPXWith(data: Data) -> GPXRoot? {
        
        let xml = try? TBXML(xmlData: data, error: ())
        
        if xml?.rootXMLElement != nil {
            return GPXRoot(XMLElement: xml?.rootXMLElement, parent: nil)
        }
        
        return nil
    }
    
}
