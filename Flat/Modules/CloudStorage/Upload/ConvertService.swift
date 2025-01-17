//
//  ConvertService.swift
//  Flat
//
//  Created by xuyunshi on 2021/12/23.
//  Copyright © 2021 agora.io. All rights reserved.
//

import Foundation
import Whiteboard

fileprivate struct ConvertConfig {
    static let staticConvertPathExtensions: [String] = ["pdf", "ppt", "doc", "docx"]
    
    static let dynamicConvertPathExtensions: [String] = ["pptx"]
    
    static let shouldConvertPathExtensions: [String] = {
        return staticConvertPathExtensions + dynamicConvertPathExtensions
    }()
}

struct ConvertService {
    static func convertingTaskTypeFor(url: URL) -> WhiteConvertTypeV5? {
        let ext = url.pathExtension.lowercased()
        if ConvertConfig.staticConvertPathExtensions.contains(ext) {
            return .static
        } else if ConvertConfig.dynamicConvertPathExtensions.contains(ext) {
            return .dynamic
        }
        return nil
    }
    
    static func isFileConvertible(withFileURL url: URL) -> Bool {
        ConvertConfig.shouldConvertPathExtensions.contains(url.pathExtension.lowercased())
    }
    
    static func shouldConvertFile(withFile file: StorageFileModel) -> Bool {
        if file.convertStep == .none,
           ConvertConfig.shouldConvertPathExtensions.contains(file.fileURL.pathExtension.lowercased()) {
            return true
        }
        return false
    }
    
    static func startConvert(fileUUID: String,
                             completion: @escaping ((Result<StartConvertResponse, Error>)->Void)) {
        ApiProvider.shared.request(fromApi: StartConvertRequest(fileUUID: fileUUID)) { result in
            switch result {
            case .success(let item):
                print("submit convert task success")
                completion(.success(item))
            case .failure(let error):
                print("submit convert task fail, \(error)")
                completion(.failure(error))
            }
        }
    }
}
