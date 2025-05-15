//
//  Training.swift
//  ApexApp
//
//  Created by Круглич Влад on 25.04.25.
//

import Foundation
import FirebaseFirestore

struct Training: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var approach: String
    var count: String
    var date: String
    var exerciseId: String
    var name: String
    var userId: String
}
