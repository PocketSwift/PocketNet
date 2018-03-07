//
//  ReqresDefaultLogger.swift
//  Reqres
//
//  Created by Jan Mísař on 02.08.16.
//
//

import Foundation

open class ReqresDefaultLogger: ReqresLogging {

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        return df
    }()

    open var logLevel: LogLevel = .verbose

    open func logVerbose(_ message: String) {
        logMessage(message)
    }

    open func logLight(_ message: String) {
        logMessage(message)
    }

    open func logError(_ message: String) {
        logMessage(message)
    }

    private func logMessage(_ message: String) {
        print("[" + dateFormatter.string(from: Date()) + "] " + message)
    }
}

open class ReqresDefaultNSLogger: ReqresLogging {

    open var logLevel: LogLevel = .verbose

    open func logVerbose(_ message: String) {
        print(message)
    }

    open func logLight(_ message: String) {
        print(message)
    }

    open func logError(_ message: String) {
        print(message)
    }
}
