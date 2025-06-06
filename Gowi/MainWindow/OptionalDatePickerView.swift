//
//  OptionalDatePickerView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Combine
import SwiftUI

/**
 A component for displaying and setting optional dates, such as those that might be used for completion dates.

 Rendered as a `DatePicker` alongside a `Toggle`.

 With the default inactive value displayed  in the `DatePicker` being either:
    1. A self updating,  localised wall clock time when the input date param is  not defined
    2. Whatever the input date param is when it is defined.

 While the value displayed in the `Toggle` control reflects if the input date is defined or not.

 When the user interacts with the `Toggle` it triggers a call to a callback function that can be used to update the input date param . To do this the callback is passed the:
    1. `Date` currently set in the `DatePicker` when the `Toggle` is checked.
    2. And `nil` when the `Toggle` is unchecked.

 Notes
 1. To stop the system stomping on values the user might be creating wall clock updates cease when the user changes the value in the `DatePicker` even when the the `Toggle` is
 unchecked.
 2. The date updating callbacks are still made even when the `Toggle` is set i.e. there is no logic currently stopping something like post-hoc completion date manipulation.

 */
struct OptionalDatePickerView: View {
    /// Unique identifier to enable SwifUI to determine when it should create a new instance of the component (vs just reuse)
    let ourId: UUID

    ///  Text to display alongside the `Toggle`
    let setLabel: String

    /// The date value used to derive the values displayed in the `DatePicker` (wall clock iff `nil`, `Date` value supplied otherwise) and`Toggle` (unchecked iff `Date` `nil`,
    /// checked != `nil`)
    let externalDate: Date?

    /// Callback  intended for updating an external date.   Is passed:
    /// -  `nil` when `Toggle` is unset.
    /// - `Date` from the `DatePicker` when `Toggle` is set OR if `DatePicker` changes.
    let externalDateUpdate: (Date?) -> Void

    /// Local date value that the publisher will update if nothing set from outside AND the user hasn't been making changes.
    @State private var localDate: Date = Date()

    // Flag used to indicate no local user changes
    @State private var userMadeNoLocalChanges: Bool = true

    // Used to update the default Date value displayed in the DatePicker when input date param is nil
    private let timerPublisher: AnyPublisher<Date, Never> = Timer.publish(every: 1, tolerance: 1, on: .main, in: .common)
        .autoconnect()
        .eraseToAnyPublisher()

    private var isDoneBinding: Binding<Bool> {
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

    /// Date to display in the control
    private var displayDate: Binding<Date> {
        return Binding {
            if let externalDate = externalDate { // => is complete
                return externalDate
            } else {
                return localDate
            }
        } set: { newUserSetDisplayDate in
            if externalDate != nil { // => is complete, always just call the update handler
                externalDateUpdate(newUserSetDisplayDate)
            } else { // Just update the local date and stop the timer from overwriting what's just been set by the user
                userMadeNoLocalChanges = false
                localDate = newUserSetDisplayDate
            }
        }
    }

    /// Format to apply to the date displayed
    private static let minsInHourOnlyFmt: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "mm"
        return fmt
    }()

    var body: some View {
        return Layout(setLabel: setLabel, date: displayDate, isDone: isDoneBinding)
            .onChange(of: ourId) { _ in
                localDate = Date()
                userMadeNoLocalChanges = true
            }
            .onReceive(timerPublisher) { newDate in
                /*
                  Ignore updates to the local date when:
                    1) The user has altered it themselves and would be annoyed to have timer stomp on what they have set.
                    2) It would cause unneccesary rebuilding of the View because what's actually displayed by the view will not
                    actually change (done this way because we still want the displayed minutes to be accurate to within 1s of system
                    wallclock)
                 */

                guard userMadeNoLocalChanges,
                      Self.minsInHourOnlyFmt.string(from: localDate) != Self.minsInHourOnlyFmt.string(from: newDate)
                else {
                    return
                }

                localDate = newDate
            }
    }
}

extension OptionalDatePickerView {
    fileprivate struct Layout: View {
        let setLabel: String
        @Binding var date: Date
        @Binding var isDone: Bool

        var body: some View {
            HStack {
                DatePicker("", selection: $date)
                    .opacity(isDone ? 1 : 0.5001)
                    .help("Adjust the Item's completion date")
                // Wrt to altering how defined vs undefined values are displayed, empirically:
                // 1) opacity cannot be set to less than 5 otherwise the controls cease to functifon (probably to prevent bad-actors
                // adding hidden control to apps)
                // 2) The text colour for the DatePicker cannot be changed via the foreground modifier (probably a bug)

                Text(setLabel)
                Toggle("", isOn: $isDone)
                    .accessibilityIdentifier(AccessId.OptionalDatePickerDoneToggle.rawValue)
                    .help("Mark the Item as complete")
            }
            .fixedSize()
        }
    }
}


#Preview("Not Done") {
    OptionalDatePickerView.Layout(
        setLabel: "iSet",
        date: .constant(Date()),
        isDone: .constant(false)
    )
}

#Preview("Done") {
    OptionalDatePickerView.Layout(
        setLabel: "iSet",
        date: .constant(Date()),
        isDone: .constant(true)
    )
}
