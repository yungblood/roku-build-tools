'*****************************************************************
'* Copyright Roku 2011-2018
'* All Rights Reserved
'*****************************************************************

function TestSuite__baseScene__MainTestSuite() as Object
    ' Inherit your test suite from BaseTestSuite
    this = BaseTestSuite()
    
    ' Test suite name for log statistics
    this.Name = "TestSuite__baseScene__MainTestSuite"
    
    ' Add tests to suite's tests collection
    this.addTest("MainTestSuite__SetUp", MainTestSuite__SetUp)
    this.addTest("TestCase__Main_CheckItemAttributes", TestCase__Main_CheckItemAttributes)
    this.addTest("MainTestSuite__TearDown", MainTestSuite__TearDown)
    
    return this
end function

'----------------------------------------------------------------
' This function called immediately before running tests of current suite.
' This function called to prepare all data for testing.
'----------------------------------------------------------------
' @BeforeAll
sub MainTestSuite__SetUp()
    ' Target testing object. To avoid the object creation in each test
    ' we create instance of target object here and use it in tests as m.targetTestObject.
    ' m.mainData  = GetApiArray()
    ? "YB-m" , m
    ? getglobalaa().top
end sub

'----------------------------------------------------------------
' This function called immediately after running tests of current suite.
' This function called to clean or remove all data for testing.
'----------------------------------------------------------------
' @AfterAll
sub MainTestSuite__TearDown()
    ' Remove all the test data
    ' m.Delete("mainData")
end sub

'----------------------------------------------------------------
' Check if first item has mandatory attributes
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
' @Test 
function TestCase__Main_CheckItemAttributes() as String
    mandatoryAttributes = [
        "omnitureName",
        "omniturePageType",
        "omnitureSiteHier",
        "omniturePageViewGuid",
        "omnitureData",
        "omnitureStateData",
        "close",
    ]

    return m.AssertAAHasKeys(getGlobalAA().top, mandatoryAttributes)
end function
