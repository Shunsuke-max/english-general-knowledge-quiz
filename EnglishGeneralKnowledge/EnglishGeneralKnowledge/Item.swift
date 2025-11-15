//
//  Item.swift
//  EnglishGeneralKnowledge
//
//  Created by あさいしゅんすけ on 2025/11/14.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
