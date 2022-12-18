//
//  Settings.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 24.10.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import Foundation

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}
