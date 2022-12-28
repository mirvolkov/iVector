import Programmator
import SwiftUI

struct ProgramEditor<ViewModel: PickListPopoverCallback & PickListPopoverDelegate>: View {
    struct InstructionListItem: Identifiable, CustomStringConvertible {
        let instruction: Instruction
        let id: Int
        var description: String { instruction.description }
    }

    let item: ViewModel.ListItem
    @ObservedObject var viewModel: ViewModel
    @State private var items: [InstructionListItem] = []

    var body: some View {
        List(items) { item in
            Text(item.description)
        }
        .task {
            if let program = item as? Program {
                items = (try? await program.instructions.enumerated().map { InstructionListItem(
                    instruction: $1,
                    id: $0
                ) }) ?? []
            }
        }
    }
}
