//
//  FeedlyGetStreamOperation.swift
//  Account
//
//  Created by Kiel Gillard on 20/9/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import Parser
import os.log

public protocol FeedlyEntryProviding {
	@MainActor var entries: [FeedlyEntry] { get }
}

public protocol FeedlyParsedItemProviding {
	@MainActor var parsedItemProviderName: String { get }
	@MainActor var parsedEntries: Set<ParsedItem> { get }
}

public protocol FeedlyGetStreamContentsOperationDelegate: AnyObject {
	func feedlyGetStreamContentsOperation(_ operation: FeedlyGetStreamContentsOperation, didGetContentsOf stream: FeedlyStream)
}

/// Get the stream content of a Collection from Feedly.
public final class FeedlyGetStreamContentsOperation: FeedlyOperation, FeedlyEntryProviding, FeedlyParsedItemProviding {

	@MainActor struct ResourceProvider: FeedlyResourceProviding {
		var resource: FeedlyResourceID
	}
	
	let resourceProvider: FeedlyResourceProviding
	
	public var parsedItemProviderName: String {
		return resourceProvider.resource.id
	}
	
	public var entries: [FeedlyEntry] {
		guard let entries = stream?.items else {
//			assert(isFinished, "This should only be called when the operation finishes without error.")
			assertionFailure("Has this operation been addeded as a dependency on the caller?")
			return []
		}
		return entries
	}
	
	public var parsedEntries: Set<ParsedItem> {
		if let entries = storedParsedEntries {
			return entries
		}
		
		let parsed = Set(entries.compactMap {
			FeedlyEntryParser(entry: $0).parsedItemRepresentation
		})
		
		if parsed.count != entries.count {
			let entryIDs = Set(entries.map { $0.id })
			let parsedIDs = Set(parsed.map { $0.uniqueID })
			let difference = entryIDs.subtracting(parsedIDs)
			os_log(.debug, log: log, "Dropping articles with ids: %{public}@.", difference)
		}
		
		storedParsedEntries = parsed
		
		return parsed
	}
	
	private(set) var stream: FeedlyStream? {
		didSet {
			storedParsedEntries = nil
		}
	}
	
	private var storedParsedEntries: Set<ParsedItem>?
	
	let service: FeedlyGetStreamContentsService
	let unreadOnly: Bool?
	let newerThan: Date?
	let continuation: String?
	let log: OSLog
	
	public weak var streamDelegate: FeedlyGetStreamContentsOperationDelegate?

	public init(resource: FeedlyResourceID, service: FeedlyGetStreamContentsService, continuation: String? = nil, newerThan: Date?, unreadOnly: Bool? = nil, log: OSLog) {

		self.resourceProvider = ResourceProvider(resource: resource)
		self.service = service
		self.continuation = continuation
		self.unreadOnly = unreadOnly
		self.newerThan = newerThan
		self.log = log
	}
	
	convenience init(resourceProvider: FeedlyResourceProviding, service: FeedlyGetStreamContentsService, newerThan: Date?, unreadOnly: Bool? = nil, log: OSLog) {
	
		self.init(resource: resourceProvider.resource, service: service, newerThan: newerThan, unreadOnly: unreadOnly, log: log)
	}
	
	public override func run() {

		Task { @MainActor in

			do {
				let stream = try await service.getStreamContents(for: resourceProvider.resource, continuation: continuation, newerThan: newerThan, unreadOnly: unreadOnly)

				self.stream = stream
				self.streamDelegate?.feedlyGetStreamContentsOperation(self, didGetContentsOf: stream)
				self.didFinish()

			} catch {
				os_log(.debug, log: self.log, "Unable to get stream contents: %{public}@.", error as NSError)
				self.didFinish(with: error)
			}
		}
	}
}
