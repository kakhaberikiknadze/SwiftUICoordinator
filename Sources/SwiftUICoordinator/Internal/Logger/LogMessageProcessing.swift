//
//  File.swift
//  
//
//  Created by Kakhaberi Kiknadze on 04.10.22.
//

import Foundation

protocol LogMessageProcessing {
    func process(
        message: @autoclosure () -> Any,
        metadata: @autoclosure () -> Log.Metadata?,
        level: LogLevel
    ) -> String
}

struct LogMessageProcessor: LogMessageProcessing {
    private let dateFormatter: DateFormatter
    
    init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }
    
    func process(
        message: @autoclosure () -> Any,
        metadata: @autoclosure () -> Log.Metadata?,
        level: LogLevel
    ) -> String {
        let dashes = String(repeating: "-", count: 25)
        let separator = "\n\n<" + dashes + "{}" + dashes + ">\n\n"
        let title = getMessageTitle(for: level)
        let header = separator.replacingOccurrences(of: "{}", with: title)
        let messageString = "đŖ " + self.message(from: message())
        let formattedMetadata = metadata().flatMap(formatMetadata) ?? ""
        
        return header + messageString + formattedMetadata + separator
    }
}

private extension LogMessageProcessor {
    func message(from value: Any) -> String {
        if let value = value as? String {
            return value
        } else if let value = value as? CustomStringConvertible {
            return value.description
        } else {
            return "\(value)"
        }
    }
    
    func getMessageTitle(for level: LogLevel) -> String {
        switch level {
        case .debug:
            return "DEBUG MESSAGE đ "
        case .notice:
            return "NOTICE MESSAGE đĄ"
        case .trace:
            return "TRACE MESSAGE đĩ"
        case .info:
            return "INFO MESSAGE âšī¸"
        case .error:
            return "ERROR MESSAGE đ´"
        case .warning:
            return "WARNING MESSAGE â ī¸"
        case .fault:
            return "FAULT MESSAGE đ"
        case .critical:
            return "CRITICAL MESSAGE đ¨"
        }
    }
    
    func formatMetadata(_ metadata: Log.Metadata) -> String {
        var formattedString = "\n|\n|__ Metadata â¤ĩī¸"
        metadata.forEach { key, value in
            let string = key + ": " + "\(value)"
            formattedString.append("\nđš" + string)
        }
        return formattedString
    }
}
