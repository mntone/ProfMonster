import Foundation

enum ViewModelStateAnd<Data> {
	case ready
	case loading
	case complete(data: Data)
	case failure(date: Date, error: ViewModelError)
}
