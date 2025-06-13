//
//  Test_100_ContainsDangerousDisabledByDefaultTests_PersistingChanges.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import XCTest

class Test_100_ContainsDangerousDisabledByDefaultTests_PersistingChanges: XCTestCase {
    let app = XCUIApplication()

    // OK_TO_RUN_DANGEROUS Enables tests that need to run against the live backend data to do so.
    // WARNING:
    // WARNING: Only enable if okay with risk of any live data that the app has getting scrambled if the tests go wrong
    let OK_TO_RUN_DANGEROUS_TESTS = false

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Ensure we have some test date and a single window by default
        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    struct TData {
        let id: String
        let originalTitle: String
        let originalNote: String
        let mutatedTitle: String
        let mutatedNote: String
    }

    func makeChanges(numChanges: Int, create: () throws -> Void) throws -> Array<TData> {
        XCTAssertGreaterThan(app.contentRows_NON_THROWING().count, numChanges,
                             "This test requires at least \(numChanges) item in the system")

        for _ in 1 ... numChanges {
            try create()
            app.typeText("- ") /// Anything so that when create runs again it'll create a new one
        }

        var tdata: Array<TData> = []
        for n in 0 ... numChanges - 1 {
            app.contentRowTextField_NON_THROWING(n).click()

            app.detailTitle_NON_THROWING().click()
            let id = app.detailIDValue_NON_THROWING()
            let oTitle = app.detailTitleValue_NON_THROWING()
            app.typeKey(.rightArrow, modifierFlags: [.command])
            app.typeText(" T change \(n)")
            let mTitle = app.detailTitleValue_NON_THROWING()

            app.detailNotes_NON_THROWING().click()
            let oNote = app.detailNotesValue_NON_THROWING()
            app.typeKey(.rightArrow, modifierFlags: [.command])
            app.typeText(" N change \(n)")
            let mNote = app.detailNotesValue_NON_THROWING()

            tdata.append(TData(id: id!, originalTitle: oTitle, originalNote: oNote, mutatedTitle: mTitle, mutatedNote: mNote))
        }
        return tdata
    }

    enum SaveMech { case menuItem, shortcut, toolbarItem }

    func relaunchAgainstLiveData() {
        assert(OK_TO_RUN_DANGEROUS_TESTS,
               "Attempt to re-launch app for use against live data without OK_TO_RUN_DANGEROUS_TESTS set")
        app.shortcutAppQuit()
        app.launchEnvironment = Dictionary()
        app.launch()
    }

    func testCanSaveChangesUsing(_ saveMechanism: SaveMech) throws {
        assert(OK_TO_RUN_DANGEROUS_TESTS, "Attempt to test dangerous configuration without OK_TO_RUN_DANGEROUS_TESTS option set")

        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                       "When the app starts the Toolbar Save Changes button shows no changes are waiting to be saved")

        let numItemsToSave = 2
        let tdata: Array<TData> = try makeChanges(numChanges: numItemsToSave, create: { try app.menubarItemNew.click() })

        XCTAssertTrue(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                      "And after new items are added the Toolbar's Save button will indicate there are changes to be saved")

        switch saveMechanism {
        case .menuItem:
            app.menubarFileSaveChanges_NON_THROWING.click()
        case .shortcut:
            app.shortcutSaveChanges()
        case .toolbarItem:
            app.toolbarSaveChangesPending_NON_THROWING.click()
        }

        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                       "After saving changes using \(saveMechanism) the Toolbar's Save Changes button will indicate no other changes need saving ")

        ///
        /// Restart the app and check the save worked
        ///
        app.shortcutAppQuit()
        app.launch()

        let ordFmtr = NumberFormatter()
        ordFmtr.numberStyle = .ordinal
        for dataIdx in 0 ... numItemsToSave - 1 {
            ///  because new items are always pushed onto the top of the todo list, the first one will be furthest from the top in the sidebar. Make sidebar row idx that
            ///  takes that maps our expected test data onto what should be stored in the app

            let ordDataIdx = ordFmtr.string(from: NSNumber(value: dataIdx))!

            app.contentRowTextField_NON_THROWING(dataIdx).click()
            XCTAssertEqual(app.detailTitleValue_NON_THROWING(), tdata[dataIdx].mutatedTitle,
                           "And after restarting \(ordDataIdx) sidebar item will contain the \(ordDataIdx) entry's title")
            XCTAssertEqual(app.detailNotesValue_NON_THROWING(), tdata[dataIdx].mutatedNote,
                           "And  notes")
            XCTAssertEqual(app.detailIDValue_NON_THROWING(), tdata[dataIdx].id,
                           "And  id")
        }

        ///
        /// Remove them so as not leave a mess in the system
        ///
        for data in tdata {
            app.contentRowTextField_NON_THROWING(0).click()
            XCTAssertEqual(app.detailIDValue_NON_THROWING(), data.id, "ID's must match removing")
            app.shortcutItemDelete()
        }
        app.menubarFileSaveChanges_NON_THROWING.click()
    }

    func test_000_dangerous_unsavedChangesAgainstLiveDataAreDiscardedOnAppRestarts() throws {
        try XCTSkipUnless(OK_TO_RUN_DANGEROUS_TESTS,
                          "Test relies on access to Live backend DB, possible risk of data corruption")
        relaunchAgainstLiveData()

        try app.sidebarAllList().click()
        let numChangesToMake = 2

        XCTAssertGreaterThan(app.contentRows_NON_THROWING().count, numChangesToMake,
                             "This test requires at least \(numChangesToMake) item in the system")

        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                       "When the app starts the Toolbar Save Changes button shows no changes are waiting to be saved")

        ///
        /// Stash original values for comparision after re-start and make changes to titles and notes
        /// (fairly safe to assume that if these two get reverted anything else should be good as well)
        ///

        let tdata = try makeChanges(numChanges: numChangesToMake, create: {})

        XCTAssertTrue(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                      "And after updates are made to Item's the Toolbar's Save button will indicate there are changes to save")

        ///
        /// Re-start the app and make sure back on our list
        ///
        app.shortcutAppQuit()
        app.launch()
        try app.sidebarAllList().click()

        ///
        /// Check that the changes we made have been reverted by the restart
        ///
        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                       "But, without saving, on restart the Save Changes button will show nothing needs saving")

        let ordFmtr = NumberFormatter()
        ordFmtr.numberStyle = .ordinal
        for e in 0 ... numChangesToMake - 1 {
            app.contentRowTextField_NON_THROWING(e).click()

            let ordStr: String = ordFmtr.string(from: NSNumber(value: e))!
            XCTAssertEqual(app.detailTitleValue_NON_THROWING(), tdata[e].originalTitle,
                           "And changes made before the restart to the \(ordStr) row's Item Title will be gone")

            XCTAssertEqual(app.detailTitleValue_NON_THROWING(), tdata[e].originalTitle,
                           "As well as those to its (\(ordStr) row) Notes")
        }
    }

    func test_100_disabled_by_default_canSaveChangesAgainstLiveDataUsingMenuItem() throws {
        try XCTSkipUnless(OK_TO_RUN_DANGEROUS_TESTS,
                          "Test relies on access to Live backend DB, possible risk of data corruption")
        relaunchAgainstLiveData()

        try testCanSaveChangesUsing(.menuItem)
    }

    func test_200_disabled_by_default_canSaveChangesAgainstLiveDataUsingShortCut() throws {
        try XCTSkipUnless(OK_TO_RUN_DANGEROUS_TESTS,
                          "Test relies on access to Live backend DB, possible risk of data corruption")
        relaunchAgainstLiveData()

        try testCanSaveChangesUsing(.shortcut)
    }

    func test_300_disabled_by_default_canSaveChangesAgainstLiveDataUsingToolbarSaveButton() throws {
        try XCTSkipUnless(OK_TO_RUN_DANGEROUS_TESTS,
                          "Test relies on access to Live backend DB, possible risk of data corruption")
        relaunchAgainstLiveData()

        try testCanSaveChangesUsing(.toolbarItem)
    }

    
    func test_400_allUnsavedChangesCanBeRevertedFromTheMenubar() throws {
        try app.sidebarAllList().click()
        let numChangesToMake = 2
        XCTAssertGreaterThan(app.contentRows_NON_THROWING().count, numChangesToMake,
                             "This test requires at least \(numChangesToMake) items in the system")

        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                       "When the app starts the Toolbar Save Changes button shows no changes are waiting to be saved")

        XCTAssertFalse(app.toolbarRevertChangesIsShowing_NON_THROWING,
                       "And the Revert Changes button indicates there is nothing for it to do")

        ///
        /// Stash original values for comparision after re-start and make changes to titles and notes
        /// (fairly safe to assume that if these two get reverted anything else should be good as well)
        ///

        let tdata = try makeChanges(numChanges: numChangesToMake, create: {})

        XCTAssertTrue(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                      "And after updates are made to items the Toolbar's Save button will indicate there are changes to save")
        XCTAssertTrue(app.toolbarRevertChangesIsShowing_NON_THROWING,
                      "And the Revert Changes button will show that those changes can also be abandoned")

        ///
        /// Revert changes
        ///
        app.menubarFileRevertChanges_NON_THROWING.click()
        app.dialogueConfirmRevertOK_NON_THROWING.click()

        ///
        /// Check that the changes we made have been reverted by the restart
        ///
        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                       "And after clicking on the the Menubar's Revert Changes button and confirming, then the Save Changes button will show nothing to save")
        XCTAssertFalse(app.toolbarRevertChangesIsShowing_NON_THROWING,
                       "and the Revert button will show there is nothing further to revert")

        let ordFmtr = NumberFormatter()
        ordFmtr.numberStyle = .ordinal
        for e in 0 ... numChangesToMake - 1 {
            app.contentRowTextField_NON_THROWING(e).click()

            let ordStr: String = ordFmtr.string(from: NSNumber(value: e))!
            XCTAssertEqual(app.detailTitleValue_NON_THROWING(), tdata[e].originalTitle,
                           "And the unsaved changes to the \(ordStr) row's Item Title will be gone")

            XCTAssertEqual(app.detailTitleValue_NON_THROWING(), tdata[e].originalTitle,
                           "As well as those to its (\(ordStr) row) Notes")
        }
    }
    
    
    func test_410_allUnsavedChangesCanBeRevertedFromTheToolbar() throws {
        try app.sidebarAllList().click()
        let numChangesToMake = 2
        XCTAssertGreaterThan(app.contentRows_NON_THROWING().count, numChangesToMake,
                             "This test requires at least \(numChangesToMake) items in the system")

        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                       "When the app starts the Toolbar Save Changes button shows no changes are waiting to be saved")

        XCTAssertFalse(app.toolbarRevertChangesIsShowing_NON_THROWING,
                       "And the Revert Changes button indicates there is nothing for it to do")

        ///
        /// Stash original values for comparision after re-start and make changes to titles and notes
        /// (fairly safe to assume that if these two get reverted anything else should be good as well)
        ///

        let tdata = try makeChanges(numChanges: numChangesToMake, create: {})

        XCTAssertTrue(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                      "And after updates are made to items the Toolbar's Save button will indicate there are changes to save")
        XCTAssertTrue(app.toolbarRevertChangesIsShowing_NON_THROWING,
                      "And the Revert Changes button will show that those changes can also be abandoned")

        ///
        /// Revert changes
        ///
        app.toolbarRevertChangesPending_NON_THROWING.click()
        app.dialogueConfirmRevertOK_NON_THROWING.click()

        ///
        /// Check that the changes we made have been reverted by the restart
        ///
        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending_NON_THROWING,
                       "And after clicking on the the Toolbar's Revert Changes button and confirmin, then the Save Changes button will show nothing to save")
        XCTAssertFalse(app.toolbarRevertChangesIsShowing_NON_THROWING,
                       "and the Revert button will show there is nothing further to revert")

        let ordFmtr = NumberFormatter()
        ordFmtr.numberStyle = .ordinal
        for e in 0 ... numChangesToMake - 1 {
            app.contentRowTextField_NON_THROWING(e).click()

            let ordStr: String = ordFmtr.string(from: NSNumber(value: e))!
            XCTAssertEqual(app.detailTitleValue_NON_THROWING(), tdata[e].originalTitle,
                           "And the unsaved changes to the \(ordStr) row's Item Title will be gone")

            XCTAssertEqual(app.detailTitleValue_NON_THROWING(), tdata[e].originalTitle,
                           "As well as those to its (\(ordStr) row) Notes")
        }
    }

    func test_500_whenRevertingUnsavedChangesTheAppDoubleChecksTheRequestToPreventAccidents() throws {
        XCTAssertFalse(app.toolbarRevertChangesIsShowing_NON_THROWING,
                       "When test starts the Toolbar's Revert Changes button should indicate there is nothing for it to do")

        try app.menubarItemNew.click()
        app.detailTitle_NON_THROWING().click()
        app.typeText("A title")
        let title = app.detailTitleValue_NON_THROWING()

        XCTAssertTrue(app.toolbarRevertChangesIsShowing_NON_THROWING,
                      "And after a new Item is created the Revert Changes button will indicate it can be used to revert changes")

        app.toolbarRevertChangesPending_NON_THROWING.click()
        app.dialogueConfirmRevertCancel_NON_THROWING.click()

        XCTAssertTrue(app.toolbarRevertChangesIsShowing_NON_THROWING,
                      "If the Toolbar's Revert Button is accidentally clicked then the operation can be cancelled")

        XCTAssertEqual(app.detailTitleValue_NON_THROWING(), title,
                       "And the unsaved changes do not end up getting reverted")
    }
}
