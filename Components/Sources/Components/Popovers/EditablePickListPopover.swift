import Programmator
import SwiftUI

protocol PickListPopoverDelegate {
    associatedtype ListItem: Hashable & Identifiable & CustomStringConvertible
    func onDelete(item: ListItem)
}

struct ProgramPickListPopover<ViewModel: PickListPopoverCallback & PickListPopoverDelegate>: View {
    enum Route<ListItem: Hashable>: Hashable {
        case progEditor(ListItem)
    }

    @ObservedObject var viewModel: ViewModel
    @State private var items: [ViewModel.ListItem] = []
    @State private var path: [Route<ViewModel.ListItem>] = []
    @State private var onDeleteAction: ViewModel.ListItem? = nil

    var body: some View {
        NavigationStack(path: $path) {
            List(items, id: \.description) { item in
                Text(item.description)
                    .font(vectorRegular(18))
                    .onTapGesture {
                        viewModel.onItemSelected(item: item)
                    }
                    .contextMenu {
                        Button(action: {
                            path.append(.progEditor(item))
                        }) {
                            Text(L10n.view)
                            Image(systemName: "text.justify")
                        }
                        Button(action: {
                            onDeleteAction = item
                        }) {
                            Text(L10n.delete)
                            Image(systemName: "trash.slash")
                        }
                    }
            }
            .navigationTitle(L10n.programs)
            .navigationDestination(for: Route<ViewModel.ListItem>.self) { route in
                switch route {
                    case .progEditor(let item):
                        ProgramEditor(
                            item: item,
                            viewModel: viewModel
                        )
                }
            }
        }
        .task {
            items = await self.viewModel.items
        }
        .alert(item: $onDeleteAction, content: { item in
            Alert(
                title: Text("\(item.description)"),
                message: Text(L10n.warning),
                primaryButton: .default(Text(L10n.cancel)) {
                    onDeleteAction = nil
                },
                secondaryButton: .default(Text(L10n.ok)) {
                    viewModel.onDelete(item: item)
                    items.removeAll(where: { $0 == item })
                }
            )
        })
        .listStyle(.plain)
        .frame(minWidth: 320, minHeight: 240)
    }
}
