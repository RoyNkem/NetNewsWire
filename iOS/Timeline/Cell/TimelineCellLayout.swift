//
//  TimelineCellLayout.swift
//  NetNewsWire-iOS
//
//  Created by Maurice Parker on 4/29/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import UIKit
import Images

protocol TimelineCellLayout {
	
	var height: CGFloat {get}
	var unreadIndicatorRect: CGRect {get}
	var starRect: CGRect {get}
	var iconImageRect: CGRect {get}
	var titleRect: CGRect {get}
	var summaryRect: CGRect {get}
	var feedNameRect: CGRect {get}
	var dateRect: CGRect {get}
	
}

extension TimelineCellLayout {
	
	static func rectForUnreadIndicator(_ point: CGPoint) -> CGRect {
		var r = CGRect.zero
		r.size = CGSize(width: TimelineDefaultCellLayout.unreadCircleDimension, height: TimelineDefaultCellLayout.unreadCircleDimension)
		r.origin.x = point.x
		r.origin.y = point.y + 5
		return r
	}
	
	
	static func rectForStar(_ point: CGPoint) -> CGRect {
		var r = CGRect.zero
		r.size.width = TimelineDefaultCellLayout.starDimension
		r.size.height = TimelineDefaultCellLayout.starDimension
		r.origin.x = floor(point.x - ((TimelineDefaultCellLayout.starDimension - TimelineDefaultCellLayout.unreadCircleDimension) / 2.0))
		r.origin.y = point.y + 3
		return r
	}
	
	static func rectForIconView(_ point: CGPoint, iconSize: IconSize) -> CGRect {
		var r = CGRect.zero
		r.size = iconSize.size
		r.origin.x = point.x
		r.origin.y = point.y + 4
		return r
	}
	
	@MainActor static func rectForTitle(_ cellData: TimelineCellData, _ point: CGPoint, _ textAreaWidth: CGFloat) -> (CGRect, Int) {

		var r = CGRect.zero
		if cellData.title.isEmpty {
			return (r, 0)
		}
		
		r.origin = point
		
		let sizeInfo = MultilineUILabelSizer.size(for: cellData.title, font: TimelineDefaultCellLayout.titleFont, numberOfLines: cellData.numberOfLines, width: Int(textAreaWidth))
		
		r.size.width = textAreaWidth
		r.size.height = sizeInfo.size.height
		if sizeInfo.numberOfLinesUsed < 1 {
			r.size.height = 0
		}
		
		return (r, sizeInfo.numberOfLinesUsed)
		
	}
	
	@MainActor static func rectForSummary(_ cellData: TimelineCellData, _ point: CGPoint, _ textAreaWidth: CGFloat, _ linesUsed: Int) -> CGRect {
		
		let linesLeft = cellData.numberOfLines - linesUsed
		
		var r = CGRect.zero
		if cellData.summary.isEmpty || linesLeft < 1 {
			return r
		}
		
		r.origin = point
		
		let sizeInfo = MultilineUILabelSizer.size(for: cellData.summary, font: TimelineDefaultCellLayout.summaryFont, numberOfLines: linesLeft, width: Int(textAreaWidth))
		
		r.size.width = textAreaWidth
		r.size.height = sizeInfo.size.height
		if sizeInfo.numberOfLinesUsed < 1 {
			r.size.height = 0
		}
		
		return r
		
	}

	static func rectForFeedName(_ cellData: TimelineCellData, _ point: CGPoint, _ textAreaWidth: CGFloat) -> CGRect {
		
		var r = CGRect.zero
		r.origin = point
		
		let feedName = cellData.showFeedName == .feed ? cellData.feedName : cellData.byline
		let size = SingleLineUILabelSizer.size(for: feedName, font: TimelineDefaultCellLayout.feedNameFont)
		r.size = size
		
		if r.size.width > textAreaWidth {
			r.size.width = textAreaWidth
		}
		
		return r
		
	}
	
}
