//
//  JamoMapper.swift
//  HangulSwift
//
//  Created by wookyoung on 2/2/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import Foundation

func split_by(LF str: String) -> [String] {
    return str.componentsSeparatedByString("\n")
}

enum JamoLine {
//    case Empty
//    case Comment(String) // 음
    case Just(String)
    case Normal(String, String) // 외
    case 초(String, String)
    case 중(String, String)
    case 종(String, String)
    case 갈(String, String, String) // 갈마들이
    case 모(String, String) // 이중모음용
}


class KeyMapper {

    func load(path: String) -> [[JamoLine]] {
        return parse(read_keymap_file(path))
    }
    
    internal func read_keymap_file(path: String) -> String {
        do {
            return try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
        }
        return ""
    }
    
    internal func parse(str: String) -> [[JamoLine]] {
        let lines = split_by(LF: str)
        var rows = [[JamoLine]]()
        var row = [JamoLine]()
        for line in lines {
            if line == "" {
                // Empty
                if row.count > 0 {
                    rows.append(row)
                    row = [JamoLine]()
                }
            } else if line.hasPrefix("음") {
                // Comment
            } else {
                let item = split_by(space: line)
                switch item.count {
                case 1:
                    let sym = item[0]
                    row.append(.Just(sym))
                case 3,4:
                    let (sym, type, sound) = (item[0], item[1], item[2])
                    switch type {
                    case "초":
                         row.append(.초(sym, sound))
                    case "중":
                         row.append(.중(sym, sound))
                    case "종":
                         row.append(.종(sym, sound))
                    case "모":
                        row.append(.모(sym, sound))
                    default:
                        row.append(.Normal(sym, sound))
                    }
                case 6: // 갈마들이
                    let (sym, type, _, jung, _, jong) = (item[0], item[1], item[2], item[3], item[4], item[5])
                    if "갈" == type {
                        row.append(.갈(sym, jung, jong))
                    }
                default:
                    break
                }
            }
        }
        if row.count > 0 {
            rows.append(row)
        }
        return rows
    }
}

func jamo_mapper_rows(path: String) -> [[JamoLine]] {
    let mapper = KeyMapper()
    return mapper.load(path)
}