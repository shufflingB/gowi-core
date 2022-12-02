

import XCTest

class Test_100_ContainsDangerousDisabledByDefaultTests_PersistingChanges: XCTestCase {
    let app = XCUIApplication()

    // OK_TO_RUN_DANGEROUS Enables tests that need to run against the live backend data to do so.
    // WARNING:
    // WARNING: Only enable if okay with risk of any live data that the app has getting scrambled if the tests go wrong
    let OK_TO_RUN_DANGEROUS_TESTS = true

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

    func makeChanges(numChanges: Int, create: () -> Void) throws -> Array<TData> {
        XCTAssertGreaterThan(app.contentRows().count, numChanges,
                             "This test requires at least \(numChanges) item in the system")

        for _ in 1 ... numChanges {
            create()
            app.typeText("- ") /// Anything so that when create runs again it'll create a new one
        }

        var tdata: Array<TData> = []
        for n in 0 ... numChanges - 1 {
            app.contentRowTextField(n).click()

            app.detailTitle().click()
            let id = app.detailIDValue()
            let oTitle = app.detailTitleValue()
            app.typeKey(.rightArrow, modifierFlags: [.command])
            app.typeText(" T change \(n)")
            let mTitle = app.detailTitleValue()

            app.detailNotes().click()
            let oNote = app.detailNotesValue()
            app.typeKey(.rightArrow, modifierFlags: [.command])
            app.typeText(" N change \(n)")
            let mNote = app.detailNotesValue()

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

        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending,
                       "When the app starts the Toolbar Save Changes button shows no changes are waiting to be saved")

        let numItemsToSave = 2
        let tdata: Array<TData> = try makeChanges(numChanges: numItemsToSave, create: { app.menubarItemNew.click() })

        XCTAssertTrue(app.toolbarSaveChangesIsShowingPending,
                      "And after new items are added the Toolbar's Save button will indicate there are changes to be saved")

        switch saveMechanism {
        case .menuItem:
            app.menubarFileSaveChanges.click()
        case .shortcut:
            app.shortcutSaveChanges()
        case .toolbarItem:
            app.toolbarSaveChangesPending.click()
        }

        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending,
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

            app.contentRowTextField(dataIdx).click()
            XCTAssertEqual(app.detailTitleValue(), tdata[dataIdx].mutatedTitle,
                           "And after restarting \(ordDataIdx) sidebar item will contain the \(ordDataIdx) entry's title")
            XCTAssertEqual(app.detailNotesValue(), tdata[dataIdx].mutatedNote,
                           "And  notes")
            XCTAssertEqual(app.detailIDValue(), tdata[dataIdx].id,
                           "And  id")
        }

        ///
        /// Remove them so as not leave a mess in the system
        ///
        for data in tdata {
            app.contentRowTextField(0).click()
            XCTAssertEqual(app.detailIDValue(), data.id, "ID's must match removing")
            app.shortcutItemDelete()
        }
        app.menubarFileSaveChanges.click()
    }

    func test_000_dangerous_unsavedChangesAgainstLiveDataAreDiscardedOnAppRestarts() throws {
        try XCTSkipUnless(OK_TO_RUN_DANGEROUS_TESTS,
                          "Test relies on access to Live backend DB, possible risk of data corruption")
        relaunchAgainstLiveData()

        app.sidebarAllList().click()
        let numChangesToMake = 2

        XCTAssertGreaterThan(app.contentRows().count, numChangesToMake,
                             "This test requires at least \(numChangesToMake) item in the system")

        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending,
                       "When the app starts the Toolbar Save Changes button shows no changes are waiting to be saved")

        ///
        /// Stash original values for comparision after re-start and make changes to titles and notes
        /// (fairly safe to assume that if these two get reverted anything else should be good as well)
        ///

        let tdata = try makeChanges(numChanges: numChangesToMake, create: {})

        XCTAssertTrue(app.toolbarSaveChangesIsShowingPending,
                      "And after updates are made to Item's the Toolbar's Save button will indicate there are changes to save")

        ///
        /// Re-start the app and make sure back on our list
        ///
        app.shortcutAppQuit()
        app.launch()
        app.sidebarAllList().click()

        ///
        /// Check that the changes we made have been reverted by the restart
        ///
        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending,
                       "But, without saving, on restart the Save Changes button will show nothing needs saving")

        let ordFmtr = NumberFormatter()
        ordFmtr.numberStyle = .ordinal
        for e in 0 ... numChangesToMake - 1 {
            app.contentRowTextField(e).click()

            let ordStr: String = ordFmtr.string(from: NSNumber(value: e))!
            XCTAssertEqual(app.detailTitleValue(), tdata[e].originalTitle,
                           "And changes made before the restart to the \(ordStr) row's Item Title will be gone")

            XCTAssertEqual(app.detailTitleValue(), tdata[e].originalTitle,
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
        app.sidebarAllList().click()
        let numChangesToMake = 2
        XCTAssertGreaterThan(app.contentRows().count, numChangesToMake,
                             "This test requires at least \(numChangesToMake) items in the system")

        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending,
                       "When the app starts the Toolbar Save Changes button shows no changes are waiting to be saved")

        XCTAssertFalse(app.toolbarRevertChangesIsShowing,
                       "And the Revert Changes button indicates there is nothing for it to do")

        ///
        /// Stash original values for comparision after re-start and make changes to titles and notes
        /// (fairly safe to assume that if these two get reverted anything else should be good as well)
        ///

        let tdata = try makeChanges(numChanges: numChangesToMake, create: {})

        XCTAssertTrue(app.toolbarSaveChangesIsShowingPending,
                      "And after updates are made to items the Toolbar's Save button will indicate there are changes to save")
        XCTAssertTrue(app.toolbarRevertChangesIsShowing,
                      "And the Revert Changes button will show that those changes can also be abandoned")

        ///
        /// Revert changes
        ///
        app.menubarFileRevertChanges.click()
        app.dialogueConfirmRevertOK.click()

        ///
        /// Check that the changes we made have been reverted by the restart
        ///
        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending,
                       "And after clicking on the the Menubar's Revert Changes button and confirming, then the Save Changes button will show nothing to save")
        XCTAssertFalse(app.toolbarRevertChangesIsShowing,
                       "and the Revert button will show there is nothing further to revert")

        let ordFmtr = NumberFormatter()
        ordFmtr.numberStyle = .ordinal
        for e in 0 ... numChangesToMake - 1 {
            app.contentRowTextField(e).click()

            let ordStr: String = ordFmtr.string(from: NSNumber(value: e))!
            XCTAssertEqual(app.detailTitleValue(), tdata[e].originalTitle,
                           "And the unsaved changes to the \(ordStr) row's Item Title will be gone")

            XCTAssertEqual(app.detailTitleValue(), tdata[e].originalTitle,
                           "As well as those to its (\(ordStr) row) Notes")
        }
    }
    
    
    func test_410_allUnsavedChangesCanBeRevertedFromTheToolbar() throws {
        app.sidebarAllList().click()
        let numChangesToMake = 2
        XCTAssertGreaterThan(app.contentRows().count, numChangesToMake,
                             "This test requires at least \(numChangesToMake) items in the system")

        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending,
                       "When the app starts the Toolbar Save Changes button shows no changes are waiting to be saved")

        XCTAssertFalse(app.toolbarRevertChangesIsShowing,
                       "And the Revert Changes button indicates there is nothing for it to do")

        ///
        /// Stash original values for comparision after re-start and make changes to titles and notes
        /// (fairly safe to assume that if these two get reverted anything else should be good as well)
        ///

        let tdata = try makeChanges(numChanges: numChangesToMake, create: {})

        XCTAssertTrue(app.toolbarSaveChangesIsShowingPending,
                      "And after updates are made to items the Toolbar's Save button will indicate there are changes to save")
        XCTAssertTrue(app.toolbarRevertChangesIsShowing,
                      "And the Revert Changes button will show that those changes can also be abandoned")

        ///
        /// Revert changes
        ///
        app.toolbarRevertChangesPending.click()
        app.dialogueConfirmRevertOK.click()

        ///
        /// Check that the changes we made have been reverted by the restart
        ///
        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending,
                       "And after clicking on the the Toolbar's Revert Changes button and confirmin, then the Save Changes button will show nothing to save")
        XCTAssertFalse(app.toolbarRevertChangesIsShowing,
                       "and the Revert button will show there is nothing further to revert")

        let ordFmtr = NumberFormatter()
        ordFmtr.numberStyle = .ordinal
        for e in 0 ... numChangesToMake - 1 {
            app.contentRowTextField(e).click()

            let ordStr: String = ordFmtr.string(from: NSNumber(value: e))!
            XCTAssertEqual(app.detailTitleValue(), tdata[e].originalTitle,
                           "And the unsaved changes to the \(ordStr) row's Item Title will be gone")

            XCTAssertEqual(app.detailTitleValue(), tdata[e].originalTitle,
                           "As well as those to its (\(ordStr) row) Notes")
        }
    }

    func test_500_whenRevertingUnsavedChangesTheAppDoubleChecksTheRequestToPreventAccidents() throws {
        XCTAssertFalse(app.toolbarRevertChangesIsShowing,
                       "When test starts the Toolbar's Revert Changes button should indicate there is nothing for it to do")

        app.menubarItemNew.click()
        app.detailTitle().click()
        app.typeText("A title")
        let title = app.detailTitleValue()

        XCTAssertTrue(app.toolbarRevertChangesIsShowing,
                      "And after a new Item is created the Revert Changes button will indicate it can be used to revert changes")

        app.toolbarRevertChangesPending.click()
        app.dialogueConfirmRevertCancel.click()

        XCTAssertTrue(app.toolbarRevertChangesIsShowing,
                      "If the Toolbar's Revert Button is accidentally clicked then the operation can be cancelled")

        XCTAssertEqual(app.detailTitleValue(), title,
                       "And the unsaved changes do not end up getting reverted")
    }
}
