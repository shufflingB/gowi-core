//
//  TickableDate.swift
//  TickableDate
//
//  Created by Jonathan Hume on 02/09/2021.
//

import Combine
import SwiftUI

struct OptionalDatePickerView: View {
    let setLabel: String
    let id: UUID
    let externalDate: Date?
    let externalDateUpdate: (Date?) -> Void

    @State var localDate: Date = Date()
    @State var localDateAllowTimerUpdates: Bool = true

    let timerPublisher: AnyPublisher<Date, Never> = Timer.publish(every: 1, tolerance: 1, on: .main, in: .common)
        .autoconnect()
        .eraseToAnyPublisher()

    /// 1)  If the External date set then:
    /// - isDone is to be set true
    /// - that External date is to be displayed.
    ///
    /// 2) If no External date set then:
    /// - isDone is to be set false
    /// - And a Default date that corresponds to the current time when the Item is first diplayed is supplied and periodically updated
    ///     - Unless the user is editing the date
    ///     - Or has edited the previous date.
    ///
    /// - Then if the user:
    ///     A) Click on the done checkbox then external date is set to whatever is the default date at that moment in time
    ///     Or,
    ///     B) If the user edits the local date this then becomes thee fix default date that is set when the done checkbox is selected
    ///
    /// 3) It should pick up changes in the External date

    var isDoneBinding: Binding<Bool> {
        return Binding {
            externalDate == nil ? false : true
        } set: { newValue in
            if newValue {
                externalDateUpdate(localDate)
            } else {
                externalDateUpdate(nil)
            }
        }
    }

    var displayDate: Binding<Date> {
        return Binding {
            if let externalDate = externalDate { // => is complete
                return externalDate
            } else {
                return localDate
            }
        } set: { newUserSetDisplayDate in
            if externalDate != nil { // => is complete
                externalDateUpdate(newUserSetDisplayDate)
            } else { // Just update the local date and stop the timer from overwriting what's just been set
                localDateAllowTimerUpdates = false
                localDate = newUserSetDisplayDate
            }
        }
    }

    private static let minsInHourOnlyFmt: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "mm"
        return fmt
    }()

    var body: some View {
        return Layout(setLabel: setLabel, date: displayDate, isDone: isDoneBinding)
            .onChange(of: id) { _ in
                localDate = Date()
                localDateAllowTimerUpdates = true
            }
            .onReceive(timerPublisher) { newDate in
                /// We'll ignore updates to the local date
                /// - when the user has altered it themselves and it would be annoying to have timer stomp on what they set.
                /// - it avoid unneccesary rebuilding of the View, its Binding etc that would be caused by updates that do not actually change what the UI ends up displaying
                ///   (UI does not display information below the level of minutes)
                guard localDateAllowTimerUpdates,
                      Self.minsInHourOnlyFmt.string(from: localDate) != Self.minsInHourOnlyFmt.string(from: newDate)
                else {
                    return
                }

                localDate = newDate
            }
    }
}

extension OptionalDatePickerView {
    struct Layout: View {
        let setLabel: String
        @Binding var date: Date
        @Binding var isDone: Bool

        var body: some View {
            HStack {
                DatePicker("", selection: $date)
                    .opacity(isDone ? 1 : 0.5001)
                    .help("Adjust the Item's completion date")
                /// 1) opacity cannot be set less than 5 otherwise the controls cease to function.
                /// 2) The text colour for the DatePicker cannot be changed via the foreground modifier without all sorts of comedy
                /// work-arounds ...

                Text(setLabel)
                Toggle("", isOn: $isDone)
                    .accessibilityIdentifier(AccessId.OptionalDatePickerDoneToggle.rawValue)
                    .help("Mark the Item as complete")
            }
            .fixedSize()
        }
    }
}

struct OptionalDatePicker_Layout_Previews: PreviewProvider {
    static var previews: some View {
        OptionalDatePickerView.Layout(setLabel: "iSet", date: .constant(Date()), isDone: .constant(false))

        OptionalDatePickerView.Layout(setLabel: "iSet", date: .constant(Date()), isDone: .constant(true))
    }
}
