import Foundation

enum PhysiologyState: String, Codable {
	case unknown
	case `default`
	case broken
	case angry
	case distending
	case flame
	case guarding
	case hotShell = "hot_shell"
	case mud
	case rolling
}
