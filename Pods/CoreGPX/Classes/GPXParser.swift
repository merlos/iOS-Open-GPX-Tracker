//
//  GPXParserII.swift
//  CoreGPX
//
//  Version 1 created on 2/11/18.
//  Version 2 created on 2/7/19.
//
//  XML Parser is referenced from GitHub, yahoojapan/SwiftyXMLParser.

import Foundation

 /**
 An event-driven parser (SAX parser), currently parses GPX v1.1 files only.
 
 This parser is already setted up, hence, does not require any handling, and will parse files directly as objects.
 To get the parsed data from a GPX file, simply initialize the parser, and get the `GPXRoot` from `parsedData()`.
 */
public final class GPXParser: NSObject {
    
    // MARK:- Private Declarations
    
    /// XML parser of current object
    private let parser: XMLParser
    
    /// Default base element
    private let documentRoot = GPXRawElement(name: "DocumentStart")
    
    /// Temporary stack of raw elements.
    private var stack = [GPXRawElement]()
    
    // MARK:- Error Checking Declarations
    
    private var parserError: Error?
    private var errorAtLine = Int()
    private var isErrorCheckEnabled = false
    private var shouldContinueAfterFirstError = false
    private var errorsOccurred = [Error]()
    
    // MARK:- Private Methods
    
    /// Resets stack
    private func stackReset() {
        stack = [GPXRawElement]()
        stack.append(documentRoot)
    }
    
    /// Common init setup
    private func didInit() {
        stackReset()
        parser.delegate = self
    }
    
    // MARK:- Initializers
    
    /// for parsing with `Data` type
    ///
    /// - Parameters:
    ///     - data: The input must be `Data` object containing GPX markup data, and should not be `nil`
    ///
    public init(withData data: Data) {
        self.parser = XMLParser(data: data)
        super.init()
        didInit()
    }
    
    /// for parsing with `InputStream` type
    ///
    /// - Parameters:
    ///     - stream: The input must be a input stream allowing GPX markup data to be parsed synchronously
    ///
    public init(withStream stream: InputStream) {
        self.parser = XMLParser(stream: stream)
        super.init()
        didInit()
    }
    
    /// for parsing with `URL` type
    ///
    /// - Parameters:
    ///     - url: The input must be a `URL`, which should point to a GPX file located at the URL given
    ///
    public init?(withURL url: URL) {
        guard let urlParser = XMLParser(contentsOf: url) else { return nil }
        self.parser = urlParser
        super.init()
        didInit()
    }
    
    /// for parsing with a string that contains full GPX markup
    ///
    /// - Parameters:
    ///     - string: The input `String` must contain full GPX markup, which is typically contained in a `.GPX` file
    ///
    public convenience init?(withRawString string: String?) {
        if let string = string {
            if let data = string.data(using: .utf8) {
                self.init(withData: data)
            }
            else { return nil }
        }
        else { return nil }
    }
    
    /// for parsing with a path to a GPX file
    ///
    /// - Parameters:
    ///     - path: The input path, with type `String`, must contain a path that points to a GPX file used to facilitate parsing.
    ///
    public convenience init?(withPath path: String) {
        do {
            let file = try String(contentsOfFile: path, encoding: .utf8)
            self.init(withRawString: file)
        }
        catch {
            print("CoreGPX: Failed parsing with path")
            return nil
        }
        
    }
    
    // MARK: GPX
    
    ///
    /// Starts parsing, returns parsed `GPXRoot` when done.
    ///
    public func parsedData() -> GPXRoot? {
        self.parser.parse() // parse when requested
        guard let firstTag = stack.first else { return nil }
        guard let rawGPX = firstTag.children.first else { return nil }
        
        let root = GPXRoot(raw: rawGPX) // to be returned; includes attributes.
        
        for child in rawGPX.children {
            let name = child.name
            
            switch name {
            case "metadata":
                let metadata = GPXMetadata(raw: child)
                root.metadata = metadata
            case "wpt":
                let waypoint = GPXWaypoint(raw: child)
                root.add(waypoint: waypoint)
            case "rte":
                let route = GPXRoute(raw: child)
                root.add(route: route)
            case "trk":
                let track = GPXTrack(raw: child)
                root.add(track: track)
            case "extensions":
                let extensions = GPXExtensions(raw: child)
                root.extensions = extensions
            default: continue
            }
        }
        
        // reset stack
        stackReset()
        
        return root
    }
    
    ///
    /// Starts parsing, returns parsed `GPXRoot` when done.
    ///
    /// - Parameters:
    ///     - forceContinue: If `true`, parser will continue parsing even if non XML-based issues like invalid coordinates have occurred
    ///
    /// - Throws: `GPXError` errors if an incident has occurred while midway or after parsing the GPX file.
    ///
    public func failibleParsedData(forceContinue: Bool) throws -> GPXRoot? {
        self.isErrorCheckEnabled = true
        self.shouldContinueAfterFirstError = forceContinue
        self.parser.parse() // parse when requested
        
        guard let firstTag = stack.first else { throw GPXError.parser.fileIsNotXMLBased }
        guard let rawGPX = firstTag.children.first else { throw GPXError.parser.fileIsEmpty }
        
        guard parserError == nil else { throw GPXError.parser.issueAt(line: errorAtLine, error: parserError!) }
        
        let root = GPXRoot(raw: rawGPX) // to be returned; includes attributes.
        guard root.version == "1.1" else { throw GPXError.parser.unsupportedVersion }
        
        guard errorsOccurred.isEmpty else { if errorsOccurred.count > 1 {
            throw GPXError.parser.multipleErrorsOccurred(errorsOccurred) } else {
            throw errorsOccurred.first! } }
        
        for child in rawGPX.children {
            let name = child.name
            
            switch name {
            case "metadata":
                let metadata = GPXMetadata(raw: child)
                root.metadata = metadata
            case "wpt":
                let waypoint = GPXWaypoint(raw: child)
                root.add(waypoint: waypoint)
            case "rte":
                let route = GPXRoute(raw: child)
                root.add(route: route)
            case "trk":
                let track = GPXTrack(raw: child)
                root.add(track: track)
            case "extensions":
                let extensions = GPXExtensions(raw: child)
                root.extensions = extensions
            default: throw GPXError.parser.fileDoesNotConformSchema
            }
        }
        
        // reset stack
        stackReset()
        
        return root
    }
    
    
}


///
/// XML Parser Delegate Implementation
///
extension GPXParser: XMLParserDelegate {
    /// Default XML Parser Delegate's start element (<element>) callback.
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if isErrorCheckEnabled {
            parserGPXErrorHandling(parser, elementName: elementName, attributeDict: attributeDict)
        }
        
        let node = GPXRawElement(name: elementName)
        if !attributeDict.isEmpty {
            node.attributes = attributeDict
        }
        
        let parentNode = stack.last
        
        parentNode?.children.append(node)
        stack.append(node)
    }
    
    /// Default XML Parser Delegate callback when characters are found.
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let foundString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if let text = stack.last?.text {
            stack.last?.text = text + foundString
        } else {
            stack.last?.text = "" + foundString
        }
    }
    
    /// Default XML Parser Delegate's end element (</element>) callback.
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        stack.last?.text = stack.last?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        stack.removeLast()
    }
    
    /// Handling of XML parser's thrown error. (if there is any)
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        errorAtLine = parser.lineNumber
        parserError = parseError
    }
    
    /// Handles GPX errors during parse, unrelated to XML formatting.
    private func parserGPXErrorHandling(_ parser: XMLParser, elementName: String, attributeDict: [String : String]) {
        if elementName == "gpx" && attributeDict["version"] != "1.1" && !shouldContinueAfterFirstError {
            parserError = GPXError.parser.unsupportedVersion
            
            if !shouldContinueAfterFirstError { parser.abortParsing() }
        }
        if elementName == "wpt" || elementName == "trkpt" || elementName == "rtept" {
            guard let lat = Convert.toDouble(from: attributeDict["lat"]) else { errorsOccurred.append(GPXError.parser.issueAt(line: parser.lineNumber)); return }
            guard let lon = Convert.toDouble(from: attributeDict["lon"]) else { errorsOccurred.append(GPXError.parser.issueAt(line: parser.lineNumber)); return }
            guard let error = GPXError.checkError(latitude: lat, longitude: lon) else {
                return }
            errorsOccurred.append(GPXError.parser.issueAt(line: parser.lineNumber, error: error))
            
            if !shouldContinueAfterFirstError { parser.abortParsing() }
        }
    }
}
