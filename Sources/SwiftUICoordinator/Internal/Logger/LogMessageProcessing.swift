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
        let messageString = "📣 " + self.message(from: message())
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
            return "DEBUG MESSAGE 🟠"
        case .notice:
            return "NOTICE MESSAGE 🟡"
        case .trace:
            return "TRACE MESSAGE 🔵"
        case .info:
            return "INFO MESSAGE ℹ️"
        case .error:
            return "ERROR MESSAGE 🔴"
        case .warning:
            return "WARNING MESSAGE ⚠️"
        case .fault:
            return "FAULT MESSAGE 🐞"
        case .critical:
            return "CRITICAL MESSAGE 🚨"
        }
    }
    
    func formatMetadata(_ metadata: Log.Metadata) -> String {
        var formattedString = "\n|\n|__ Metadata ⤵️"
        metadata.forEach { key, value in
            let string = key + ": " + "\(value)"
            formattedString.append("\n🔹" + string)
        }
        return formattedString
    }
}
