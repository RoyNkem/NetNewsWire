//
//  FaviconGenerator.swift
//  NetNewsWire-iOS
//
//  Created by Maurice Parker on 4/29/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import Foundation
import RSCore
import Account

@MainActor final class FaviconGenerator {

	private static var faviconGeneratorCache = [String: IconImage]() // feedURL: RSImage

	static func favicon(_ feed: Feed) -> IconImage {
		
		if let favicon = FaviconGenerator.faviconGeneratorCache[feed.url] {
			return favicon
		}
		
		let colorHash = ColorHash(feed.url)
		if let favicon = AppAssets.faviconTemplateImage.maskWithColor(color: colorHash.color.cgColor) {
			let iconImage = IconImage(favicon, isBackgroundSupressed: true)
			FaviconGenerator.faviconGeneratorCache[feed.url] = iconImage
			return iconImage
		} else {
			return IconImage(AppAssets.faviconTemplateImage, isBackgroundSupressed: true)
		}
		
	}
	
}
