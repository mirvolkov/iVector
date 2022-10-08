import SwiftUI

protocol PickListPopoverCallback: ObservableObject where ListItem: CustomStringConvertible {
    associatedtype ListItem
    var items: [ListItem] { get set  }
    func onItemSelected(item: ListItem)
}

struct PickListPopover<ViewModel: PickListPopoverCallback>: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        List(viewModel.items, id: \.description) { item in
            Text(item.description)
                .font(vectorRegular(18))
                .onTapGesture {
                    viewModel.onItemSelected(item: item)
                }
        }
        .listStyle(.plain)
        .frame(width: 320, height: 240)
    }
}
