sub init()
    Runner = TestRunner()

    Runner.SetFunctions([
        MainTestSuite__SetUp
        MainTestSuite__TearDown
        TestCase__Main_CheckItemAttributes
    ])
end sub