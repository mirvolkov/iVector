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
    @State private var isChanged = false

    var body: some View {
        List {
            ForEach(items) { item in
                Text(item.description)
            }
            .onMove { indices, destination in
                items.move(fromOffsets: indices, toOffset: destination)
                isChanged = true
            }
            .onDelete(perform: { index in
                items.remove(atOffsets: index)
                isChanged = true
            })
            .deleteDisabled(false)
            .moveDisabled(false)
            
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
