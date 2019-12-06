'*****************************************************************
'* Copyright Roku 2011-2018
'* All Rights Reserved
'*****************************************************************

'----------------------------------------------------------------
' This function called immediately before running tests of current suite.
' This function called to prepare all data for testing.
'----------------------------------------------------------------
' @BeforeAll
sub MainTestSuite__SetUp()
    ' Target testing object. To avoid the object creation in each test
    ' we create instance of target object here and use it in tests as m.targetTestObject.
    ' m.mainData  = GetApiArray()
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
' Check if data has an expected amount of items
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
' @Don't Test
function TestCase__Main_CheckDataCount() as String
    return true
    return m.assertArrayCount(m.mainData, 15)
end function

'----------------------------------------------------------------
' Check if first item has mandatory attributes
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
' @Don't Test 
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

    return m.AssertAAHasKeys(m.top, mandatoryAttributes)
end function

'----------------------------------------------------------------
' Check if stream format of the item is expected
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
' @Don't Test
function TestCase__Main_CheckStreamFormatType() as String
    firstItem = m.mainData[0]

    return m.assertEqual(firstItem.streamFormat, "mp4")
end function

'----------------------------------------------------------------
' Generates invalid input object and pass it to function.
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
' @Don't Test
function TestCase__Main_TestAddPrefixFunction__Failed() as String
    'Create scheme for item generator
    scheme = {
        key1  : "integer"
        key2  : "string"
        key3  : "boolean"
        key4  : {subKey1: "string"}
    }
    inputObject = ItemGenerator(scheme)

    'Pass generated item to your function
    result = AddPrefixToAAItems(inputObject)

    return m.assertNotInvalid(result, "Input data is invalid. All values should be strings.")
end function

'----------------------------------------------------------------
' Generates valid input object and pass it to function.
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
' @Don't Test
function TestCase__Main_TestAddPrefixFunction__Passed() as string
    'Create scheme for item generator
    scheme = {
        key1  : "string"
        key2  : "string"
        key3  : "string"
        key4  : "string"
    }
    inputObject = ItemGenerator(scheme)

    'Pass generated item to your function
    result = AddPrefixToAAItems(inputObject)

    return m.assertNotInvalid(result, "Input data is invalid. All values should be strings.")
end function

function stringProvider()
    return ["foo", "bar", 1, 0, {}]
end function

'----------------------------------------------------------------
' Validate that input parameters are not invalid.
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
' @ParameterizedTest
' @MethodSource("stringProvider")
sub testWithSimpleMethodSource(argument = invalid as Dynamic)
    UTF_assertNotInvalid(argument)
end sub

'----------------------------------------------------------------
' Create row list 3 times and check it.
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
' @Don't RepeatedTest(3)
sub NewApproach_CreateRowlistRepeatTest()
    rowList = CreateObject("roSGNode", "RowList")
    UTF_assertNotInvalid(rowlist.id)
end sub