//
//  AccessibilityIdentifiers.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation

/**
 App level  UI element `AccessibilityIdentifiers`
 
 These are attached to controls and data fields in the app's UI to make finding and interacting with them easier during when automated testing
 and similar.
 */
enum AccessId: String {
    // MARK: Main AppMenu File

    case FileMenuSave
    case FileMenuRevert
    case FileMenuExportJSON

    // MARK: Main AppMenu Items

    case ItemsMenuNewItem
    case ItemsMenuDeleteItems
    case ItemsMenuOpenItemInNewTab
    case ItemsMenuOpenItemInNewWindow
    case ItemsMenuNudgePriorityUp
    case ItemsMenuNudgePriorityDown

    // MARK: Main AppMenu Window

    case WindowMenuNewMain

    // MARK: Main Toolbar

    case MainWindowToolbarSaveChangesPending
    case MainWindowToolbarSaveChangesNone
    case MainWindowToolbarRevertChangesPending
    case MainWindowToolbarRevertChangesNone
    case MainWindowToolbarCreateItemButton

    // MARK: Sidebar filter lists

    // Haven't defn'd these bc can't use case MainWindowSidebarAllList = Main.SidebarFilterListOpt.all bc it's not allowed 🙁

    // MARK: Main Window Content

    case MainWindowContentTitleField
    case MainWindowContentContextDelete
    case MainWindowContentContextOpenInNewTab
    case MainWindowContentContextOpenInNewWindow

    // MARK: Main Window Detail

    case MainWindowDetailTitleField
    case MainWindowDetailId
    case MainWindowDetailItemURL
    case MainWindowDetailCreatedDate
    case MainWindowDetailCompletedDate
    case MainWindowDetailTextEditor

    // MARK: OptionalDatePicker

    case OptionalDatePickerDoneToggle
}
