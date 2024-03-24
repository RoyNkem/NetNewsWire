//
//  MainWindowController+Scriptability.swift
//  NetNewsWire
//
//  Created by Olof Hellman on 2/7/18.
//  Copyright © 2018 Olof Hellman. All rights reserved.
//

import Foundation
import Articles

protocol ScriptingMainWindowController {
    
	@MainActor var scriptingCurrentArticle: Article? { get }
	@MainActor var scriptingSelectedArticles: [Article] { get }
}

