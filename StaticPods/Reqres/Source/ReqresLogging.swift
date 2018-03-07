//
//  ReqresLogging.swift
//  Reqres
//
//  Created by Jan Mísař on 02.08.16.
//
//

import Foundation

public enum LogLevel {
    case none
    case light
    case verbose
}

public protocol ReqresLogging {
    var logLevel: LogLevel { get set }

    func logVerbose(_ message: String)
    func logLight(_ message: String)
    func logError(_ message: String)
}
