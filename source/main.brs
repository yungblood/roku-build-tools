Library "Roku_Ads.brs"

Sub RunUserInterface(ecp As Dynamic)
    SetLogLevel(1)

    InitTheme()

    App().Run(ecp)
End Sub

Sub ExitUserInterface()
    End
End Sub
