import SwiftUI
import DifferCore

/// Commands for the Differ app menu
struct DifferCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Open Repository...") {
                // TODO: Implement repository picker
            }
            .keyboardShortcut("o", modifiers: [.command])
            
            Button("Open XCResult...") {
                // TODO: Implement XCResult picker
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
            
            Divider()
        }
        
        CommandGroup(replacing: .help) {
            Button("Differ Help") {
                // TODO: Open help documentation
            }
        }
    }
}
