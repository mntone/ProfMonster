
struct IdentifyHolder<ViewModel>: Identifiable where ViewModel: Identifiable, ViewModel.ID == String {
	let id: String
	let content: ViewModel

	init(_ content: ViewModel, prefix: String? = nil) {
		if let prefix {
			self.id = "\(prefix);\(content.id)"
		} else {
			self.id = content.id
		}
		self.content = content
	}
}

extension IdentifyHolder: Equatable where ViewModel: Equatable {
	static func ==(lhs: IdentifyHolder, rhs: IdentifyHolder) -> Bool {
		lhs.id == rhs.id
	}
}

extension IdentifyHolder: Comparable where ViewModel: Comparable {
	static func <(lhs: IdentifyHolder, rhs: IdentifyHolder) -> Bool {
		lhs.content < rhs.content
	}
}

extension IdentifyHolder: Hashable where ViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		content.hash(into: &hasher)
	}
}
