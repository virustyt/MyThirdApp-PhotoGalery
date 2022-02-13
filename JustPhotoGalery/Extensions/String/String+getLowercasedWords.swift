//
//  String+leaveOnlyNames.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 11.02.2022.
//

import Foundation

extension String {
    func getLowercasedWords() -> String {
        var name = ""
        let range = NSRange(location: 0, length: self.utf16.count)
        let regex = try? NSRegularExpression(pattern: "[a-zA-ZА-Яа-яÀ-ž]+", options: [.anchorsMatchLines])
        let matches = regex?.matches(in: self, options: [], range: range)
        matches?.forEach{
            name.append( String( self[Range($0.range, in: self)!] ) )
        }
        return name.lowercased()
    }
}

