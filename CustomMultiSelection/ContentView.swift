import SwiftUI

struct PreferenceModel: Identifiable {
    let id = UUID()
    var isSelected: Bool
    let title: String
}


class PreferenceViewModel: ObservableObject {
    @Published var PreferenceArray: [PreferenceModel]

    init() {
        self.PreferenceArray = [
            PreferenceModel(isSelected: false, title: "Swift"),
            PreferenceModel(isSelected: false, title: "Kotlin"),
            PreferenceModel(isSelected: false, title: "Java"),
            PreferenceModel(isSelected: false, title: "JavaScript"),
            PreferenceModel(isSelected: false, title: "Python")
        ]
    }

    // init(items: [String]) {
    //     self.PreferenceArray = items.map { PreferenceModel(isSelected: false, title: $0) }
    // }
    // This initializer takes an array of strings (items) as input.
    // It maps each string to a PreferenceModel with 'isSelected' set to false and
    // the string as the 'title'. The resulting array is then assigned to 'PreferenceArray'.
    
    func getSelectedPreferences() -> [String] {
        return PreferenceArray.filter { $0.isSelected }.map { $0.title }
    }
    // This function returns an array of titles for all selected preferences.
    // It first filters the 'PreferenceArray' to include only those items
    // where 'isSelected' is true, then maps the filtered result to an array of their titles.
}

struct PreferenceView: View {
    let title: String
    @Binding var isSelected: Bool

    var body: some View {
        Text(title)
            .font(.body)
            .lineLimit(1)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .foregroundColor(isSelected ? .white : .black)
            .background(
                RoundedRectangle(cornerRadius: 100)
                    .fill(isSelected ? Color.red : Color.yellow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.white, lineWidth: isSelected ? 0 : 1)
            )
            .onTapGesture {
                isSelected.toggle()
            }
    }
}

struct ChipContainerView: View {
    @ObservedObject var viewModel: PreferenceViewModel

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 10) {
                ForEach(getRows(geometry: geo).enumerated().map { RowWrapper(index: $0.offset, row: $0.element) }) { rowWrapper in
                    HStack(alignment: .center, spacing: 5) {
                        ForEach(rowWrapper.row) { item in
                            PreferenceView(title: item.title, isSelected: Binding(
                                get: { item.isSelected },
                                set: { newValue in
                                    if let index = viewModel.PreferenceArray.firstIndex(where: { $0.id == item.id }) {
                                        viewModel.PreferenceArray[index].isSelected = newValue
                                    }
                                }
                            ))
                            
                        }
                    }
                    .frame(width: geo.size.width, alignment: .center) // Centers the row
                }
            }
        }
    }
    
    // Dynamically calculate rows based on chip width and available screen width
    private func getRows(geometry: GeometryProxy) -> [[PreferenceModel]] {
        var rows: [[PreferenceModel]] = []
        var currentRow: [PreferenceModel] = []
        var rowWidth: CGFloat = 0
        let padding: CGFloat = 5
        let maxWidth = geometry.size.width - 40 // Consider padding from both sides (adjust according to your need)
        
        for item in viewModel.PreferenceArray {
            var itemWidth = textWidth(for: item.title)
            if currentRow.count > 1 {
                itemWidth += padding
                            }
                            // If adding the chip exceeds the available width, start a new row
                            if rowWidth + itemWidth  > maxWidth {
                                rows.append(currentRow)
                                currentRow = [item]
                                rowWidth = itemWidth
                            } else {
                                currentRow.append(item)
                                rowWidth += itemWidth
                            }
                        }
                        // Add the last row
                        if !currentRow.isEmpty {
                            rows.append(currentRow)
                        }
                        
                        return rows
                    }
                    
                    // Estimate the width of the chip based on its title length
                    private func textWidth(for text: String) -> CGFloat {
                        let attributes: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize)
                        ]
                        let size = (text as NSString).size(withAttributes: attributes)
                        return size.width + 30
                    }
                }

                struct RowWrapper: Identifiable {
                    let id = UUID()
                    let index: Int
                    let row: [PreferenceModel]
                }


struct ContentView: View {
    @StateObject private var viewModel = PreferenceViewModel()

    var body: some View {
        VStack {
            ChipContainerView(viewModel: viewModel)
                .padding()
            Spacer()
        }
        .background(Color.blue)
    }
}

#Preview {
    ContentView()
}

