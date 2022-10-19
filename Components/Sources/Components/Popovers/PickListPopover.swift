import SwiftUI

protocol PickListPopoverCallback: ObservableObject where ListItem: CustomStringConvertible {
    associatedtype ListItem
    var items: [ListItem] { get async }
    func onItemSelected(item: ListItem)
}

struct PickListPopover<ViewModel: PickListPopoverCallback>: View {
    @ObservedObject var viewModel: ViewModel
    @State var items: [ViewModel.ListItem] = []

    var body: some View {
        List(items, id: \.description) { item in
            Text(item.description)
                .font(vectorRegular(18))
                .onTapGesture {
                    viewModel.onItemSelected(item: item)
                }
        }
        .task {
            items = await self.viewModel.items
        }
        .listStyle(.plain)
        .frame(minWidth: 320, minHeight: 240)
    }
}
