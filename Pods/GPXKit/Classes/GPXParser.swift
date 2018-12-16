//
//  GPXParser.swift
//  GPXKit
//
//  Created by Vincent on 2/11/18.
//  

import UIKit

open class GPXParser: NSObject {

    // MARK: Instance
    
    func parseGPXAt(url: URL) -> GPXRoot? {
        do {
            let data = try Data(contentsOf: url)
            return self.parseGPXWith(data: data)
        }
        catch {
            print(error)
        }
        return nil
    }
    
    func parseGPXAt(path: String) -> GPXRoot? {
        
        let url = URL(fileURLWithPath: path)
        return GPXParser().parseGPXAt(url: url)
    }
    
    func parseGPXWith(string: String) -> GPXRoot? {
        
        let xml = try? TBXML(xmlString: string, error: ())

        if xml?.rootXMLElement != nil {
            return GPXRoot(XMLElement: xml!.rootXMLElement, parent: nil)
        }
        
        return nil
    }
    
    func parseGPXWith(data: Data) -> GPXRoot? {
        let xml = try? TBXML(xmlData: data, error: ())
        
        if xml?.rootXMLElement != nil {
            return GPXRoot(XMLElement: xml?.rootXMLElement, parent: nil)
        }
        
        return nil
    }
    
}
