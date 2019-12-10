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
    this.addTest("TestCase__Main_CheckItemAttributes", TestCase__Main_CheckItemAttributes)
    
    return this
end function

'----------------------------------------------------------------
' Check if first item has mandatory attributes
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
' @D Test 
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
