import Combine
import CoreData

struct CoreDataUserDatabaseOptions {
	let useCloud: Bool

	public static let `default` = CoreDataUserDatabaseOptions(useCloud: true)
}

final class CoreDataUserDatabase: UserDatabase {
	private let options: CoreDataUserDatabaseOptions
	private var _historyToken: NSPersistentHistoryToken?

	private lazy var _container: NSPersistentContainer = {
		guard let url = Bundle(for: CoreDataUserDatabase.self).url(forResource: "Model", withExtension: "momd"),
			  let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
			fatalError("Failed to get managed object model.")
		}

		let container: NSPersistentContainer
		if options.useCloud {
			container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: managedObjectModel)
		} else {
			container = NSPersistentContainer(name: "Model", managedObjectModel: managedObjectModel)
		}
		guard let description = container.persistentStoreDescriptions.first else {
			fatalError("Failed to retrieve a persistent store description.")
		}

		// Enable persistent history tracking
		/// - Tag: persistentHistoryTracking
		description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

		if options.useCloud {
			// Enable persistent store remote change notifications
			/// - Tag: persistentStoreRemoteChange
			description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
		}

		container.loadPersistentStores { _, error in
			if let error {
				fatalError("Unable to load persistent stores: \(error.localizedDescription)")
			}
		}

		let viewContext: NSManagedObjectContext = container.viewContext
		viewContext.automaticallyMergesChangesFromParent = true
		viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		return container
	}()

	private lazy var _publisher = {
		let publisher = NotificationCenter.default
			.publisher(for: .NSPersistentStoreRemoteChange)
			.compactMap { [weak self] _ -> [NSPersistentHistoryChange]? in
				guard let self else { return nil }

				let context = _container.newBackgroundContext()
				var changes: [NSPersistentHistoryChange]?
				context.performAndWait {
					let transactionRequest = NSPersistentHistoryTransaction.fetchRequest!
					let persistentRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self._historyToken)
					persistentRequest.fetchRequest = transactionRequest
					guard let persistentResult = try? context.execute(persistentRequest) as? NSPersistentHistoryResult,
						  let transactions = persistentResult.result as? [NSPersistentHistoryTransaction],
						  !transactions.isEmpty else {
						return
					}

					changes = transactions.flatMap { transaction -> [NSPersistentHistoryChange] in
						guard let changes = transaction.changes else { return [] }
						return changes
					}

					// The last always return the object. Transactions is not empty.
					self._historyToken = transactions.last.unsafelyUnwrapped.token
				}
				return changes
			}
			.share()
		return publisher
	}()

	init(options: CoreDataUserDatabaseOptions = .default) {
		self.options = options
	}

	func ensureState() {
		let viewContext = _container.viewContext
		if viewContext.hasChanges {
			viewContext.performAndWait {
				try! viewContext.save()
			}
		}
	}

	func getMonsters(by prefixID: String) -> [UDMonster] {
		let request = CDMonster.fetchRequest()
		request.includesPendingChanges = false
		request.predicate = NSPredicate(format: "id BEGINSWITH %@", prefixID)
		request.returnsObjectsAsFaults = false

		let context = _container.newBackgroundContext()
		let result = context.performAndWait {
			do {
				return try context.fetch(request).map { item in
					UDMonster(coreData: item)
				}
			} catch {
				// TODO: Log
				return []
			}
		}
		return result
	}

	func getMonster(by id: String) -> UDMonster? {
		let request = CDMonster.fetchRequest()
		request.fetchLimit = 1
		request.includesPendingChanges = false
		request.predicate = NSPredicate(format: "id=%@", id)
		request.returnsObjectsAsFaults = false

		let context = _container.newBackgroundContext()
		let result = context.performAndWait {
			do {
				let coreDataObject = try context.fetch(request).first
				assert(coreDataObject?.isFault != true)
				return coreDataObject.map { item in
					UDMonster(coreData: item)
				}
			} catch {
				// TODO: Log
				return nil
			}
		}
		return result
	}

	private func getCDMonster(by id: String, in context: NSManagedObjectContext) -> CDMonster? {
		let request = CDMonster.fetchRequest()
		request.fetchLimit = 1
		request.includesPropertyValues = true
		request.predicate = NSPredicate(format: "id=%@", id)
		request.returnsObjectsAsFaults = false

		do {
			let coreDataObject = try context.fetch(request).first
			assert(coreDataObject?.isFault != true)
			return coreDataObject
		} catch {
			// TODO: Log
			return nil
		}
	}

	func update(_ monster: UDMonster) {
		let context = _container.newBackgroundContext()
		context.perform {
			if let coreDataObject = self.getCDMonster(by: monster.id, in: context) {
				coreDataObject.isFavorited = monster.isFavorited
				coreDataObject.note = monster.note
			} else {
				let trasientCoreDataObject = CDMonster(context: context)
				trasientCoreDataObject.id = monster.id
				trasientCoreDataObject.isFavorited = monster.isFavorited
				trasientCoreDataObject.note = monster.note
			}

			do {
				try context.save()
			} catch {
				// TODO: Log
			}
		}
	}

	func observeChange(of monsterID: String) -> AnyPublisher<UDChange, Never> {
		let context = _container.newBackgroundContext()
		let publisher: AnyPublisher<UDChange, Never>? = context.performAndWait {
			guard let coreDataObject = getCDMonster(by: monsterID, in: context) else {
				return nil
			}
			return observeChange(ofObject: coreDataObject)
		}

		return publisher ?? _publisher
			.compactMap { [weak self] changes in
				guard let self else {
					return Empty<UDChange, Never>().eraseToAnyPublisher()
				}

				let insertedChange = changes.filter { $0.changeType == .insert }
				if !insertedChange.isEmpty {
					let context = _container.newBackgroundContext()
					return context.performAndWait {
						for change in insertedChange {
							guard let monster = context.object(with: change.changedObjectID) as? CDMonster else { continue }

							if monster.id == monsterID {
								// Update the target object.
								return Just(UDChange.add)
									.merge(with: self.observeChange(ofObject: monster))
									.eraseToAnyPublisher()
							}
						}
						return nil
					}
				}
				return nil
			}
			.switchToLatest()
			.eraseToAnyPublisher()
	}

	private func observeChange(ofObject monster: CDMonster) -> AnyPublisher<UDChange, Never> {
		let targetObjectID = monster.objectID
		let publisher = _publisher
			.compactMap { changes -> UDChange? in
				let change = changes
					.filter { change in
						change.changedObjectID == targetObjectID
					}
					.compactMap { change -> UDChange? in
						switch change.changeType {
						case .update:
							guard let updatedProperties = change.updatedProperties else { return nil }
							return .update(updatedProperties.map(\.name))
						case .delete:
							return .delete
						default:
							return nil
						}
					}
					.reduce(into: UDChange.update([])) { result, next in
						guard case let .update(currentNames) = result else { return }

						switch next {
						case .add:
							fatalError("Unknown operation.")
						case let .update(nextNames):
							let names = Set(currentNames + nextNames)
							result = .update(Array(names))
						case .delete:
							result = .delete
						}
					}

				if case .update([]) = change {
					return nil
				} else {
					return change
				}
			}
			.eraseToAnyPublisher()
		return publisher
	}
}
