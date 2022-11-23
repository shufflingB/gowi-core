//
//  AccessibilityId.swift
//  macOSToDo
//
//  Created by Jonathan Hume on 03/05/2022.
//

import Foundation



enum AccessId: String {
    // MARK: Main AppMenu File
    case FileMenuSave
    
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


//struct AI {
//    /// Catalogue of all Accessibility Identifiers used in the application. Shared between the built
//
//    
//    static let Main = "main"
//
//    static let ToolBarItemNewButton = "toolbarItemButton"
//
//    static let ToolBarSavePendingChanges = "toolbarSaveChangesPending"
//    static let ToolBarSaveChangesNone = "toolbarSaveChangesNone"
//
//    static let ToolBarRevertChangesPending = "toolbarRevertChangesPending"
//    static let ToolBarRevertChangesNone = "toolbarRevertChangesNone"
//
//    static let SideBarTodoList = "mainWindowSideBarTodoList"
//    static let SideBarDoneList = "mainWindowSideBarDoneList"
//    static let SideBarAllList = "mainWindowSideBarAllList"
//    static let SideBarRow = "mainWindowSideBarRow"
//
//    static let DetailCreatedDate = "mainWindowDetailCreatedDate"
//    static let DetailCompletedDate = "mainWindowDetailCompletedDate"
//
//    static let DetailTitleField = "mainWindowDetailTitleField"
//    static let DetailId = "mainWindowDetailId"
//    static let DetailItemURL = "mainWindowItemURL"
//    static let DetailTextEditor = "mainWindowDetailTextEditor"
//
//    static let optionalDatePickerDoneToggle = "optionalDatePickerDoneToggle"
//}
