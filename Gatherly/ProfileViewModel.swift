import Foundation
import Observation

@Observable
final class ProfileViewModel {
    let tabs = ["My Events", "RSVP'd", "Past Events"]
    var selectedTab: String = "My Events"

    func selectTab(_ tab: String) { selectedTab = tab }
}
