//
//  File.swift
//  
//
//  Created by Kakhaberi Kiknadze on 04.10.22.
//

import os
import Foundation

enum Log {
    static var isEnabled: Bool = false
    private static var messageProcessor: LogMessageProcessing = getMessageProcessor()
    private static var subSystemName = "com.swiftuicoordinator"
}

// MARK: - Private

private extension Log {
    static func getMessageProcessor() -> LogMessageProcessing {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
        return LogMessageProcessor(dateFormatter: formatter)
    }
}

// MARK: - Internal

extension Log {
    struct SubSystem {
        let name: String
        let categoryName: String
    }
}

extension Log {
    typealias Metadata = [String: Any]
}

extension Log {
    static func log(
        category: String? = nil,
        level: LogLevel,
        message: @autoclosure () -> Any,
        metadata: @autoclosure () -> Log.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        guard isEnabled else { return }
        let logger: Logger = .init(subsystem: subSystemName, category: category ?? "global")
        let processedMessage = messageProcessor.process(
            message: message(),
            metadata: metadata(),
            level: level
        )
        
        switch level {
        case .trace:
            logger.trace("\(processedMessage)")
        case .debug:
            logger.debug("\(processedMessage)")
        case .info:
            logger.info("\(processedMessage)")
        case .notice:
            logger.notice("\(processedMessage)")
        case .warning:
            logger.warning("\(processedMessage)")
        case .error:
            logger.error("\(processedMessage)")
        case .fault:
            logger.fault("\(processedMessage)")
        case .critical:
            logger.critical("\(processedMessage)")
        }
    }
}

extension Log {
    static func deinitialization(
        category: String,
        metadata: Log.Metadata? = nil
    ) {
        log(
            category: category,
            level: .trace,
            message: category + " Deinitialized! 💥",
            metadata: metadata
        )
    }
    
    static func initialization(
        category: String,
        metadata: Log.Metadata? = nil
    ) {
        log(
            category: category,
            level: .trace,
            message: category + " Initialized! 🐣",
            metadata: metadata
        )
    }
    
    static func trace(
        category: String? = nil,
        message: @autoclosure () -> Any,
        metadata: @autoclosure () -> Log.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(category: category, level: .trace, message: message(), metadata: metadata())
    }
    
    static func critical(
        category: String? = nil,
        message: @autoclosure () -> Any,
        metadata: @autoclosure () -> Log.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(category: category, level: .critical, message: message(), metadata: metadata())
    }
}

public func enableSwiftUICoordinatorLogs(_ enable: Bool) {
    Log.isEnabled = enable
}
