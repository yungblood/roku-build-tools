Function NewRegistrationWizard() As Object
    this                                    = {}
    this.ClassName                          = "RegistrationWizard"

    this.Show                               = RegistrationWizard_Show
    this.CreateAccount                      = RegistrationWizard_CreateAccount
    
    this.GetUserData                        = RegistrationWizard_GetUserData
    this.EditUserData                       = RegistrationWizard_EditUserData
    
    this.ValidateEmailAddress               = RegistrationWizard_ValidateEmailAddress
    this.ValidateZipCode                    = RegistrationWizard_ValidateZipCode
    this.ValidateBirthDate                  = RegistrationWizard_ValidateBirthDate
    this.FormatBirthDate                    = RegistrationWizard_FormatBirthDate
    
    this.ShowWelcomeScreen                  = RegistrationWizard_ShowWelcomeScreen
    this.AuthenticateWithCode               = RegistrationWizard_AuthenticateWithCode
    this.ShowTOSScreen                      = RegistrationWizard_ShowTOSScreen
    this.ShowConfirmationScreen             = RegistrationWizard_ShowConfirmationScreen
    this.ShowKeyboardScreen                 = RegistrationWizard_ShowKeyboardScreen
    
    this.ShowSubscriptionSelectionScreen    = RegistrationWizard_ShowSubscriptionSelectionScreen
    this.ShowLiveTVUpsellScreen             = RegistrationWizard_ShowLiveTVUpsellScreen
    this.ShowUpgradeScreen                  = RegistrationWizard_ShowUpgradeScreen
    this.ShowDowngradeScreen                = RegistrationWizard_ShowDowngradeScreen
    this.ProcessOptionsScreenResult         = RegistrationWizard_ProcessOptionsScreenResult
    
    this.SignUp                             = RegistrationWizard_SignUp
    this.SwitchPlan                         = RegistrationWizard_SwitchPlan

    Return this
End Function

' 0  - registration failed or was cancelled
' 1  - registration succeeded
' 99 - browse was selected
Function RegistrationWizard_Show() As Integer
    SetThemeAttribute("OverhangSliceSD", "pkg:/images/overhang_sd.jpg")
    SetThemeAttribute("OverhangSliceHD", "pkg:/images/overhang_hd.jpg")
    ClearThemeAttribute("OverhangPrimaryLogoHD")
    ClearThemeAttribute("OverhangPrimaryLogoSD")
    
    result = m.ShowWelcomeScreen()

    SetThemeAttribute("OverhangSliceSD", "pkg:/images/overhang_options_sd.jpg")
    SetThemeAttribute("OverhangSliceHD", "pkg:/images/overhang_options_hd.jpg")

    Return result
End Function

Function RegistrationWizard_CreateAccount(userData As Object) As Integer
    waitDialog = ShowWaitDialog("Please wait...")
    Return Cbs().CreateAccount(userData)
End Function

Function RegistrationWizard_GetUserData() As Object
    pageName = "app:roku:new user request to share information"
    Omniture().TrackPage(pageName)
    
    shared = False
    result = ChannelStore().GetPartialUserData("firstname,lastname,email,zip")
    If result = invalid Then
        linkName = pageName + ":don't share"
        Omniture().TrackEvent("Don't share", ["event19"], { v46: linkName })
        
        result = {
            FirstName:  ""
            LastName:   ""
            Email:      ""
            Zip:        ""
            Password:   ""
            DOB:        ""
            Gender:     ""
        }
    Else
        shared = True
        linkName = pageName + ":share"
        Omniture().TrackEvent("Share", ["event19"], { v46: linkName })
        
        ' We need to check whether the email is already taken
        If m.ValidateEmailAddress(result.Email) = -1 Then
            Return invalid
        End If
    End If
    Return m.EditUserData(result, Not shared)
End Function

Function RegistrationWizard_EditUserData(userData = {} As Object, requestPrefilled = True As Boolean) As Object
    If userData = invalid Then
        userData = {}
    End If
    userInfoCollection = [
        {
            Title:      "Enter your first name"
            Text:       "Enter first name"
            Value:      userData.FirstName
            ID:         "FirstName"
            Error:      "Please enter a valid first name."
            Validation: "^(.+)$"
        }
        {
            Title:      "Enter your last name"
            Text:       "Enter last name"
            Value:      userData.LastName
            ID:         "LastName"
            Error:      "Please enter a valid last name."
            Validation: "^(.+)$"
        }
        {
            Title:      "Enter your email address"
            Text:       "Enter email address"
            Value:      userData.Email
            ID:         "Email"
            Error:      "Please enter a valid email address."
            Validation: "^([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6})$"
            ValidationFunction: "ValidateEmailAddress"
        }
        {
            Title:      "Enter your zip code"
            Text:       "Enter 5-digit zip code"
            Value:      userData.Zip
            ID:         "Zip"
            Error:      "Please enter a valid 5-digit zip code."
            Validation: "^([0-9]{5})$"
            ValidationFunction: "ValidateZipCode"
        }
        {
            Title:      "Password"
            Text:       "Create a password (must be at least 6 characters)"
            Value:      userData.Password
            ID:         "Password"
            Masked:     False
            ToggleMask: True
            ToggleText: ["Hide password", "Show password"]
            Error:      "Please enter a valid password that is at least 6 characters."
            Validation: "^(.{6,128})$"
        }
        {
            Title:      "Enter your birth date"
            Text:       "Enter MM.DD.YYYY - example: 12.24.1978"
            Value:      userData.DOB
            ID:         "DOB"
            Error:      "Please enter a valid date of birth in the following format: MM.DD.YYYY."
            Validation: "^(?:(?:(?:0?[13578]|1[02])(\/|-|\.)31)\1|(?:(?:0?[1,3-9]|1[0-2])(\/|-|\.)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:0?2(\/|-|\.)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00)))$|^(?:(?:0?[1-9])|(?:1[0-2])))(\/|-|\.)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{4})$"
            ValidationFunction: "ValidateBirthDate"
        }
        {
            Text:       "Enter your gender"
            Value:      ""
            Values:     [
                "Male"
                "Female"
            ]
            ID:         "Gender"
        }
    ]
    
    userInfo = []
    userInfo.Append(userInfoCollection)
    ' Removed the prefilled values
    If Not requestPrefilled Then
        For i = userInfo.Count() - 1 To 0 Step -1
            data = userInfo[i]
            If Not IsNullOrEmpty(data.Value) Then
                userInfo.Delete(i)
            End If
        Next
    End If
    
    ' Show a facade while keyboard screens are being shown and hidden
    facade = CreateObject("roPosterScreen")
    facade.Show()
    For i = 0 To userInfo.Count() - 1
        data = userInfo[i]
        If data.Values = invalid Then
            If m.ShowKeyboardScreen(data) Then
                If Not IsNullOrEmpty(data.ValidationFunction) And IsFunction(m[data.ValidationFunction]) Then
                    validateValue = m[data.ValidationFunction](data.Value)
                    If validateValue = -1 Then
                        ' Exit flow
                        Return invalid
                    Else If validateValue = 0 Then
                        ' Stay on screen
                        i = i - 1
                    Else If validateValue = 1 Then
                    End If
                End If
            Else
                If i = 0 Then
                    Return invalid
                Else
                    'Drop back a screen
                    i = i - 2
                End If
            End If
        Else
            facade = CreateObject("roPosterScreen")
            facade.Show()
            Sleep(250)
            pageName = "app:roku:new user:share information workflow:gender"
            Omniture().TrackPage(pageName)

            result = ShowMessageBox(data.Text, "", data.Values, True, False, 0, 0, False)
            If result <> invalid Then
                linkName = pageName + ":" + LCase(AsString(result))
                Omniture().TrackEvent(AsString(result), ["event19"], { v46: linkName })
            
                data.Value = result
            End If
            facade.Close()
        End If
    Next
    facade.Close()

    result = {
        FirstName:  ""
        LastName:   ""
        Email:      ""
        Zip:        ""
        Password:   ""
        DOB:        ""
        Gender:     ""
    }
    ' Save off values
    For Each data In userInfoCollection
        result[data.ID] = data.Value
    Next
    Return result
End Function

Function RegistrationWizard_ValidateEmailAddress(email As String) As Integer
    result = 1
    dialog = ShowWaitDialog("Validating email address...")
    If Cbs().CheckEmailExists(email) Then
        dialog.Close()
        m.AuthenticateWithCode(email)
        Return -1
    End If
    dialog.Close()
    Return result
End Function

Function RegistrationWizard_ValidateZipCode(zip As String) As Integer
    result = 0
    dialog = ShowWaitDialog("Validating zip code...")
    If Cbs().ValidateZipCode(zip) Then
        result = 1
    Else
        ShowMessageBox("Invalid Zip Code", "Please enter a valid 5-digit zip code.", ["OK"], True)
    End If
    dialog.Close()
    Return result
End Function

Function RegistrationWizard_ValidateBirthDate(birthDate As String, requiredAge = 13 As Integer) As Integer
    regex = CreateObject("roRegex", "^(\d{1,2})(?:[\.|/|-]{1})(\d{1,2})(?:[\.|/|-]{1})(\d{4})$", "")
    dateParts = regex.Match(birthDate)
    If dateParts.Count() = 4 Then
        ' Ensure the date is before today
        validDate = AsString(AsInteger(dateParts[3])) + "-" + PadLeft(dateParts[1], "0", 2) + "-" + PadLeft(dateParts[2], "0", 2) + "T" + GetTimeString(NowDate(), False, True, False)
        seconds = DateFromISO8601String(validDate).AsSeconds()
        ' NOTE: An invalid ISO parse will result in a 1/1/1970 12:00am date, which is 0 seconds from linux epoch.
        '       If someone was actually born on 1/1/1970 and they test this at exactly 12:00:00.000 (extremely unlikely),
        '       this check will still fail.
        If seconds = 0 Or seconds >= NowDate().AsSeconds() Then
            ShowMessageBox("Invalid Date", "Please enter a valid date of birth in the following format: MM.DD.YYYY.", ["OK"], True)
            Return 0
        End If
        
        ' Add requiredAge years to birth date
        validDate = AsString(AsInteger(dateParts[3]) + requiredAge) + "-" + PadLeft(dateParts[1], "0", 2) + "-" + PadLeft(dateParts[2], "0", 2) + "T" + GetTimeString(NowDate(), False, True, False)
        seconds = DateFromISO8601String(validDate).AsSeconds()
        If seconds > NowDate().AsSeconds() Then
            ShowMessageBox("", "We are sorry, but we are unable to create an account for you at this time.", ["OK"], True)
            Return -1
        End If
    Else
        ShowMessageBox("Invalid Date", "Please enter a valid date of birth in the following format: MM.DD.YYYY.", ["OK"], True)
        Return 0
    End If
    Return 1
End Function

Function RegistrationWizard_FormatBirthDate(birthDate As String) As String
    regex = CreateObject("roRegex", "^(\d{1,2})(?:[\.|/|-]{1})(\d{1,2})(?:[\.|/|-]{1})(\d{4})$", "")
    dateParts = regex.Match(birthDate)
    If dateParts.Count() = 4 Then
        Return PadLeft(dateParts[1], "0", 2) + "/" + PadLeft(dateParts[2], "0", 2) + "/" + AsString(AsInteger(dateParts[3]))
    End If
    Return birthDate
End Function

' 0  - registration failed or was cancelled
' 1  - registration succeeded
' 99 - browse was selected
Function RegistrationWizard_ShowWelcomeScreen() As Integer
    screen = CreateObject("roImageCanvas")
    m.WelcomeScreenCanvas = screen
    screen.SetMessagePort(CreateObject("roMessagePort"))
    screen.SetRequireAllImagesToDraw(False)
    
    upsellInfo = Cbs().GetUpsellInfo()
    layers = [
        {
            Color: "#000e1b"
        }
        {
            Url: upsellInfo.Background
            TargetRect: {
                x: 0
                y: 0
                w: 1280
                h: 720
            }
        }
        {
            Text: upsellInfo.Headline
            TargetRect: {
                x: 125
                y: 200
                w: 500
                h: 40
            }
            TextAttrs: {
                Font:   "Large" 'GetCanvasFont("Default", IIf(IsHD(), 36, 24), 500)
                Color:  "#c9d3df"
                HAlign: "Left"
            }
        }
        {
            Text: upsellInfo.Message
            TargetRect: {
                x: 125
                y: 240
                w: 500
                h: 90
            }
            TextAttrs: {
                Font:   "Medium" 'GetCanvasFont("Default", IIf(IsHD(), 22, 15))
                Color:  "#c9d3df"
                HAlign: "Left"
                VAlign: "Top"
            }
        }
    ]
    
    signUpText = "Sign Up for CBS All Access"
    signInText = "Already a Subscriber? Sign In"
    browseText = "Browse and Watch Clips"
    buttonFont = GetCanvasFont("Default", IIf(IsHD(), 22, 16))
    buttons = [
        {
            ID: "signUp"
            Layers:  [
                {
                    Url: "pkg:/images/upsell/button_upsell_off.png"
                    TargetRect: {
                        x: 402
                        y: 462
                        w: 476
                        h: 52
                    }
                }
                {
                    Text: signUpText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#CCCCCC"
                        HAlign: "Center"
                    }
                    TargetRect: {
                        x: 402
                        y: 462
                        w: 476
                        h: 52
                    }
                }
            ]
            FocusedLayers:  [
                {
                    Url: "pkg:/images/upsell/button_upsell_on.png"
                    TargetRect: {
                        x: 402
                        y: 462
                        w: 476
                        h: 52
                    }
                }
                {
                    Text: signUpText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#FFFFFF"
                        HAlign: "Center"
                    }
                    TargetRect: {
                        x: 402
                        y: 462
                        w: 476
                        h: 52
                    }
                }
            ]
        }
        {
            ID: "signIn"
            Layers: [
                {
                    Url: "pkg:/images/upsell/button_upsell_off.png"
                    TargetRect: {
                        x: 402
                        y: 524
                        w: 476
                        h: 52
                    }
                }
                {
                    Text: signInText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#CCCCCC"
                        HAlign: "Center"
                    }
                    TargetRect: {
                        x: 402
                        y: 524
                        w: 476
                        h: 52
                    }
                }
            ]
            FocusedLayers:  [
                {
                    Url: "pkg:/images/upsell/button_upsell_on.png"
                    TargetRect: {
                        x: 402
                        y: 524
                        w: 476
                        h: 52
                    }
                }
                {
                    Text: signInText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#FFFFFF"
                        HAlign: "Center"
                    }
                    TargetRect: {
                        x: 402
                        y: 524
                        w: 476
                        h: 52
                    }
                }
            ]
        }
        {
            ID: "browse"
            Layers: [
                {
                    Url: "pkg:/images/upsell/button_upsell_off.png"
                    TargetRect: {
                        x: 402
                        y: 586
                        w: 476
                        h: 52
                    }
                }
                {
                    Text: browseText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#CCCCCC"
                        HAlign: "Center"
                    }
                    TargetRect: {
                        x: 402
                        y: 586
                        w: 476
                        h: 52
                    }
                }
            ]
            FocusedLayers:  [
                {
                    Url: "pkg:/images/upsell/button_upsell_on.png"
                    TargetRect: {
                        x: 402
                        y: 586
                        w: 476
                        h: 52
                    }
                }
                {
                    Text: browseText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#FFFFFF"
                        HAlign: "Center"
                    }
                    TargetRect: {
                        x: 402
                        y: 586
                        w: 476
                        h: 52
                    }
                }
            ]
        }
    ]
    
    If Not IsHD() Then
        HDTargetRectToSDTargetRect(layers)
        HDTargetRectToSDTargetRect(buttons, True)
    End If
    
    screen.SetLayer(1, layers)
    
    buttonIndex = 0
    buttonLayer = 2
    For i = 0 To buttons.Count() - 1
        If i = buttonIndex Then
            screen.SetLayer(buttonLayer + i, buttons[i].FocusedLayers)
        Else
            screen.SetLayer(buttonLayer + i, buttons[i].Layers)
        End If
    Next
    
    screen.Show()
    Omniture().TrackPage("app:roku:launch:splash page")
    While True
        msg = Wait(0, screen.GetMessagePort())
        If Type(msg) = "roImageCanvasEvent" Then
            If msg.IsRemoteKeyPressed() Then
                key = msg.GetIndex()
                If key = 0 Then         ' Back
                    screen.Close()
                Else If key = 6 Then    ' Select
                    button = buttons[buttonIndex]
                    If button <> invalid Then
                        If button.ID = "signUp" Then
                            Omniture().TrackEvent(signUpText, ["event19"], { v46: "roku:splash:" + LCase(signUpText) })
                            If Cbs().IsCFFlowEnabled Then
                                If m.ShowSubscriptionSelectionScreen(upsellInfo.productCode) Then
                                    Return 1
                                End If
                            Else
                                If m.SignUp(upsellInfo.productCode) Then
                                    Return 1
                                End If
                            End If
                        Else If button.ID = "signIn" Then
                            Omniture().TrackEvent(signInText, ["event19"], { v46: "roku:splash:" + LCase(signInText) })
                            If m.AuthenticateWithCode() Then
                                Return 1
                            End If
                        Else If button.ID = "browse" Then
                            Omniture().TrackEvent(browseText, ["event19"], { v46: "roku:splash:" + LCase(browseText) })
                            Return 99
                        End If
                    End If
                Else
                    If key = 2 Then         ' Up
                        buttonIndex = buttonIndex - 1
                    Else If key = 3 Then    ' Down
                        buttonIndex = buttonIndex + 1
                    End If
                    If buttonIndex < 0 Then
                        buttonIndex = 0
                    Else If buttonIndex >= buttons.Count() Then
                        buttonIndex = buttons.Count() - 1
                    End If
                    For i = 0 To buttons.Count() - 1
                        If i = buttonIndex Then
                            screen.SetLayer(buttonLayer + i, buttons[i].FocusedLayers)
                        Else
                            screen.SetLayer(buttonLayer + i, buttons[i].Layers)
                        End If
                    Next
                End If
            Else If msg.IsScreenClosed() Then
                Return 0
            End If
        End If
    End While
    Return 0
End Function

Function RegistrationWizard_AuthenticateWithCode(email = "" As String) As Boolean
    pageName = "app:roku:existing user"
    events = []
    params = {}
    If Not IsNullOrEmpty(email) Then
        pageName = "app:roku:email collision during registration"
        events = ["event20"]
        params.v70 = "email collision during registration"
    End If
    Omniture().TrackPage(pageName, events, params)

    screen = CreateObject("roCodeRegistrationScreen")
    screen.SetMessagePort(CreateObject("roMessagePort"))
    screen.SetTitle("Sign in")
    
    activationUrl = Cbs().GetCodeAuthUrl()
    
    If Not IsNullOrEmpty(email) Then
        screen.AddFocalText("Already a CBS All Access subscriber?", "spacing-dense")
        screen.AddFocalText(email + " is associated with a CBS All Access account", "spacing-normal")
        screen.AddFocalText("", "spacing-normal")
    End If
    screen.AddFocalText("To start streaming your favorite CBS shows, follow the steps below.", "spacing-normal")
    screen.AddParagraph("Step 1: Visit " + activationUrl + " on your computer or mobile device")
    screen.AddParagraph("Step 2: Enter the following code")
    screen.SetRegistrationCode("retrieving code...")
    screen.AddParagraph("Step 3: When complete this screen will refresh")
    screen.AddButton(0, "Get a new code")
    screen.AddButton(1, "Back")
    screen.Show()

    While True
        linkCodeInfo = Cbs().GetLinkCode()
        If linkCodeInfo = invalid Then
            screen.SetRegistrationCode("Error retrieving code")
            linkCodeInfo = {
                retryInterval: 0
            }
        Else
            screen.SetRegistrationCode(linkCodeInfo.regCode)
        End If
        While True
            msg = Wait(AsInteger(linkCodeInfo.retryInterval), screen.GetMessagePort())
            If msg = invalid Then
                ' Check the code for success
                If Cbs().CheckLinkCode(linkCodeInfo.regCode) Then
                    If m.WelcomeScreenCanvas <> invalid Then 
                        m.WelcomeScreenCanvas.Close()
                    End If
                    m.WelcomeScreenCanvas = invalid
                    Return True
                End If
            Else If Type(msg) = "roCodeRegistrationScreenEvent" Then
                If msg.isScreenClosed() Then
                    Return False
                Else If msg.isButtonPressed() Then
                    button = msg.GetIndex()
                    If button = 0 Then      ' Get a new code
                        linkName = pageName + ":" + "get a new code"
                        Omniture().TrackEvent("Get a new code", ["event19"], { v46: linkName })
                        
                        screen.SetRegistrationCode("retrieving code...")
                        Exit While
                    Else If button = 1 Then ' Back
                        linkName = pageName + ":" + "back"
                        Omniture().TrackEvent("Back", ["event19"], { v46: linkName })
                        Return False
                    End If
                End If
            End If
        End While
    End While
    Return False
End Function

Function RegistrationWizard_ShowTOSScreen() As Boolean
    pageName = "app:roku:new user:share information workflow:tos-policies"
    Omniture().TrackPage(pageName)

    screen = CreateObject("roTextScreen")
    screen.SetMessagePort(CreateObject("roMessagePort"))

    screen.SetText("")
    screen.AddButton(0, "I agree")
    screen.AddButton(1, "Cancel")
    screen.Show()
    
    screen.AddText(Cbs().GetTosText())

    While True
        msg = Wait(0, screen.GetMessagePort())
        If type(msg) = "roTextScreenEvent" Then
            If msg.isScreenClosed() Then
                Return False
            Else If msg.isButtonPressed() Then
                result = msg.GetIndex()
                If result = 0 Then ' Agree
                    linkName = pageName + ":i agree"
                    Omniture().TrackEvent("I agree", ["event19"], { v46: linkName })
                        
                    Return True
                Else If result = 1 Then ' Cancel
                    linkName = pageName + ":cancel"
                    Omniture().TrackEvent("Cancel", ["event19"], { v46: linkName })
                        
                    Return False
                End If
            End If
        End If
    End While
    Return False
End Function

Function RegistrationWizard_ShowConfirmationScreen(userData As Object) As Boolean
    While True
        pageName = "app:roku:new user:share information workflow"
        Omniture().TrackPage(pageName)

        screen = CreateObject("roParagraphScreen")
        screen.SetMessagePort(CreateObject("roMessagePort"))
    
        confirmationText = "Name: " + userData.FirstName + " " + userData.LastName
        confirmationText = confirmationText + Chr(10)
        confirmationText = confirmationText + "Email address: " + userData.Email
        confirmationText = confirmationText + Chr(10)
        confirmationText = confirmationText + "Zip code: " + userData.Zip
        confirmationText = confirmationText + Chr(10)
        confirmationText = confirmationText + "Date of birth: " + userData.DOB
        confirmationText = confirmationText + Chr(10)
        confirmationText = confirmationText + "Gender: " + userData.Gender
        
        screen.AddHeaderText("Please verify the following information:")
        screen.AddParagraph(confirmationText)
        
        screen.AddButton(0, "Confirm")
        screen.AddButton(1, "Edit information")
        screen.AddButton(2, "Cancel")
        screen.Show()
        
        While True
            msg = Wait(0, screen.GetMessagePort())
            If type(msg) = "roParagraphScreenEvent" Then
                If msg.isScreenClosed() Then
                    Return False
                Else If msg.isButtonPressed() Then
                    result = msg.GetIndex()
                    If result = 0 Then ' Confirm
                        linkName = pageName + ":confirm"
                        Omniture().TrackEvent("Confirm", ["event19"], { v46: linkName })

                        Return True
                    Else If result = 1 Then ' Edit
                        linkName = pageName + ":edit information"
                        Omniture().TrackEvent("Edit information", ["event19"], { v46: linkName })

                        updatedData = m.EditUserData(userData)
                        If updatedData <> invalid Then
                            userData.Append(updatedData)
                            Exit While
                        End If
                    Else If result = 2 Then ' Cancel
                        linkName = pageName + ":cancel"
                        Omniture().TrackEvent("Cancel", ["event19"], { v46: linkName })

                        Return False
                    End If
                End If
            End If
        End While
    End While
End Function

Function RegistrationWizard_ShowKeyboardScreen(data As Object, saveText = "Continue" As String, cancelText = "Back" As String) As Boolean
    pageName = "app:roku:new user:share information workflow:" + LCase(AsString(data.ID))
    Omniture().TrackPage(pageName)
    
    keyboard = CreateObject("roKeyboardScreen")
    keyboard.SetMessagePort(CreateObject("roMessagePort"))

    keyboard.SetTitle(AsString(data.Title))
    keyboard.SetDisplayText(AsString(data.Text))
    keyboard.SetText(AsString(data.Value))
    
    data.Masked = AsBoolean(data.Masked)
    keyboard.SetSecureText(data.Masked)
    If data.ToggleMask = True Then
        If Not IsArray(data.ToggleText) Or data.ToggleText.Count() < 2 Then
            data.ToggleText = ["Show", "Hide"]
        End If
        keyboard.AddButton(99, IIf(data.Masked, data.ToggleText[1], data.ToggleText[0]))
    End If
    keyboard.AddButton(0, saveText)
    keyboard.AddButton(1, cancelText)
    keyboard.Show()
    
    While True
        msg = Wait(0, keyboard.GetMessagePort())
        If msg <> invalid Then
            If Type(msg) = "roKeyboardScreenEvent" Then
                If msg.IsButtonPressed() Then
                    index = msg.GetIndex()
                    If index = 0 Then   ' Next
                        linkName = pageName + ":" + LCase(saveText)
                        Omniture().TrackEvent(saveText, ["event19"], { v46: linkName })
                        
                        value = keyboard.GetText().Trim()
                        success = True
                        If Not IsNullOrEmpty(data.ConfirmValue) Then
                            success = (value = data.ConfirmValue)
                        Else If Not IsNullOrEmpty(data.Validation) Then
                            regex = CreateObject("roRegex", data.Validation, "")
                            success = regex.IsMatch(value)
                        End If
                        If success Then
                            data.Value = value
                            Return True
                        Else
                            facade = CreateObject("roPosterScreen")
                            facade.Show()
                            Sleep(250)
                            ShowMessageBox("Validation Error", data.Error, ["OK"], True)
                            If facade <> invalid Then
                                facade.close() 
                                facade = invalid
                            End If
                        End If
                    Else If index = 1 Then
                        linkName = pageName + ":" + LCase(cancelText)
                        Omniture().TrackEvent(cancelText, ["event19"], { v46: linkName })
                        
                        keyboard.Close()
                        Return False
                    Else If index = 99 Then
                        linkName = pageName + ":" + LCase(IIf(data.Masked, data.ToggleText[1], data.ToggleText[0]))
                        Omniture().TrackEvent(IIf(data.Masked, data.ToggleText[1], data.ToggleText[0]), ["event19"], { v46: linkName })
                        
                        ' Update the mask
                        data.Masked = Not data.Masked
                        keyboard.SetSecureText(data.Masked)
                        ' Update the buttons
                        keyboard.ClearButtons()
                        keyboard.AddButton(99, IIf(data.Masked, data.ToggleText[1], data.ToggleText[0]))
                        keyboard.AddButton(0, saveText)
                        keyboard.AddButton(1, cancelText)                        
                    End If
                Else If msg.IsScreenClosed() Then
                    Return False
                End If
            End If
        End If
    End While
    Return False
End Function

Function RegistrationWizard_ShowSubscriptionSelectionScreen(defaultProductCode = "PROD1" As String) As Boolean
    pageName = "app:roku:all access:upsell"
    Omniture().TrackPage(pageName, ["event89"], {v10: "upsell"})

    facade = CreateObject("roImageCanvas")
    facade.SetLayer(0, { Color: "#000000" })
    facade.Show()
    
    waitDialog = ShowWaitDialog()
    
    bgInfo = Cbs().GetUpsellInfo("AAUPSELLBKCD")
    
    If bgInfo.Response = invalid Then
        ' We're not getting a response from the upsell info API, so
        ' fallback to the old flow
        Return m.SignUp(defaultProductCode)
    End If
    
    lcInfo = Cbs().GetUpsellInfo("CBS_ALL_ACCESS_PACKAGE")
    cfInfo = Cbs().GetUpsellInfo("CBS_ALL_ACCESS_AD_FREE_PACKAGE")

    lcTitleText = AsString(lcInfo.Response.upsellMessage)
    lcPriceText = AsString(lcInfo.Response.upsellMessage2)
    lcTrialText = AsString(lcInfo.Response.callToAction)
    lcProductID = AsString(lcInfo.Response.aaProductID, defaultProductCode)
    cfTitleText = AsString(cfInfo.Response.upsellMessage)
    cfPriceText = AsString(cfInfo.Response.upsellMessage2)
    cfTrialText = AsString(cfInfo.Response.callToAction)
    cfProductID = AsString(cfInfo.Response.aaProductID, defaultProductCode)
    
    tourText    = "Take a Quick Tour"
    signInText  = "Already a Subscriber? Sign In"
    
    headerImage = AsString(bgInfo.Background)
    disclaimerText = AsString(bgInfo.Response.upsellMessage)
    tourVideoID = AsString(bgInfo.Response.contentID)
    
    options = []
    options.Push({
        ID:             "subscribe"
        TitleText:      lcTitleText
        PriceText:      lcPriceText
        TrialText:      lcTrialText
        ProductCode:    lcProductID
        OmnitureData:   {
            Product: "Limited Commercial"
            LinkName: pageName + ":Limited Commercial:click"
            Params: {  
                v10: "upsell"
            }
            Events: ["event19"]
        }
    })
    options.Push({
        ID:             "subscribe"
        TitleText:      cfTitleText
        PriceText:      cfPriceText
        TrialText:      cfTrialText
        ProductCode:    cfProductID
        OmnitureData:   {
            Product: "Commercial Free"
            LinkName: pageName + ":Commercial Free:click"
            Params: {  
                v10: "upsell"
            }
            Events: ["event19"]
        }
    })
    
    buttons = []
    buttons.Push({
        ID:     "quickTour"
        Text:   tourText
        OmnitureData:   {
            LinkName: pageName + ":take a tour:click"
            Params: {  
                v10: "upsell"
            }
            Events: ["event19"]
        }
    })
    buttons.Push({
        ID:     "signIn"
        Text:   signInText
        OmnitureData:   {
            LinkName: pageName + ":sign in:click"
            Params: {  
                v10: "upsell"
            }
            Events: ["event19"]
        }
    })

    lcProduct = ChannelStore().GetProduct(lcProductID)
    cfProduct = ChannelStore().GetProduct(cfProductID)
    waitDialog.Close()
    
    If lcProduct = invalid Or cfProduct = invalid Or ChannelStore().GetPurchases().Count() > 0 Then
        Return m.AuthenticateWithCode()
    End If
    
    optionsScreen = NewOptionsScreen()
    optionsScreen.Setup(options, buttons, "", disclaimerText, headerImage)
      
    While True
        result = optionsScreen.Show()
        If result = invalid Then
            Exit While
        Else If m.ProcessOptionsScreenResult(result, tourVideoID) Then
            Return True
        End If
    End While
    Return False
End Function

Function RegistrationWizard_ShowLiveTVUpsellScreen(defaultProductCode = "PROD1" As String) As Boolean
    pageName = "app:roku:all access:upsell"
    Omniture().TrackPage(pageName, ["event89"], {v10: "upsell"})

    facade = CreateObject("roImageCanvas")
    facade.SetLayer(0, { Color: "#000000" })
    facade.Show()
    
    waitDialog = ShowWaitDialog()
        
    bgInfo = Cbs().GetUpsellInfo("AAUPSELLBKCD")
    liveInfo = Cbs().GetUpsellInfo("LIVETVBUTTON")

    titleText = AsString(liveInfo.Response.upsellMessage)
    subTitleText = AsString(liveInfo.Response.upsellMessage2)
    priceText = AsString(liveInfo.Response.upsellMessage3)
    trialText = AsString(liveInfo.Response.callToAction)
    productID = AsString(liveInfo.Response.aaProductID, defaultProductCode)
    
    tourText    = "Take a Quick Tour"
    signInText  = "Already a Subscriber? Sign In"

    headerImage = AsString(bgInfo.Background)
    disclaimerText = AsString(bgInfo.Response.upsellMessage)
    tourVideoID = AsString(bgInfo.Response.contentID)
    
    options = []
    options.Push({
        ID:             "subscribe"
        TitleText:      titleText
        SubtitleText:   subTitleText
        PriceText:      priceText
        TrialText:      trialText
        ProductCode:    productID
        OmnitureData:   {
            Product: "Limited Commercial"
            LinkName: pageName + ":Limited Commercial:click"
            Params: {  
                v10: "upsell"
            }
            Events: ["event19"]
        }
    })
    
    buttons = []
    buttons.Push({
        ID:     "quickTour"
        Text:   tourText
        OmnitureData:   {
            LinkName: pageName + ":take a tour:click"
            Params: {  
                v10: "upsell"
            }
            Events: ["event19"]
        }
    })
    buttons.Push({
        ID:     "signIn"
        Text:   signInText
        OmnitureData:   {
            LinkName: pageName + ":sign in:click"
            Params: {  
                v10: "upsell"
            }
            Events: ["event19"]
        }
    })
    
    optionsScreen = NewOptionsScreen()
    optionsScreen.Setup(options, buttons, "", disclaimerText, headerImage)
    
    product = ChannelStore().GetProduct(productID)
    waitDialog.Close()
    
    If product = invalid Or ChannelStore().GetPurchases().Count() > 0 Then
        Return m.AuthenticateWithCode()
    End If
    
    While True
        result = optionsScreen.Show()
        If result = invalid Then
            Exit While
        Else If m.ProcessOptionsScreenResult(result, tourVideoID) Then
            Return True
        End If
    End While
    Return False
End Function

Function RegistrationWizard_ShowUpgradeScreen(enabled As Boolean, defaultProductCode = "PROD1" As String) As Boolean
    pageName = "app:roku:all access:upsell"
    Omniture().TrackPage(pageName, ["event89"], {v10: "upsell_upgrade"})

    facade = CreateObject("roImageCanvas")
    facade.SetLayer(0, { Color: "#000000" })
    facade.Show()
    
    waitDialog = ShowWaitDialog()
        
    bgInfo = Cbs().GetUpsellInfo("AAUPSELLBKCD")
    upsellInfo = {}
    If enabled Then
        upsellInfo = Cbs().GetUpsellInfo("ROKUUPGRADE")
    Else
        upsellInfo = Cbs().GetUpsellInfo("OTHERUPGRADE")
    End If

    titleText = AsString(upsellInfo.Response.upsellMessage)
    subTitleText = AsString(upsellInfo.Response.upsellMessage2)
    priceText = AsString(upsellInfo.Response.callToAction)
    trialText = ""
    productID = AsString(upsellInfo.Response.aaProductID, defaultProductCode)

    noButtonsText = AsString(upsellInfo.Response.upsellMessage3)

    headerImage = AsString(bgInfo.Background)
    disclaimerText = AsString(bgInfo.Response.upsellMessage)
    
    options = []
    options.Push({
        ID:             "upgrade"
        TitleText:      titleText
        SubtitleText:   subTitleText
        PriceText:      priceText
        TrialText:      trialText
        Enabled:        enabled
        ProductCode:    productID
        OmnitureData:   {
            Product: "Upgrade"
            LinkName: pageName + ":upgrade:click"
            Params: {  
                v10: "upsell_upgrade"
            }
            Events: ["event19"]
        }
    })
    
    buttons = []
    
    optionsScreen = NewOptionsScreen()
    optionsScreen.Setup(options, buttons, noButtonsText, disclaimerText, headerImage)
    
    waitDialog.Close()
    
    While True
        result = optionsScreen.Show()
        If result = invalid Then
            Exit While
        Else If m.ProcessOptionsScreenResult(result, "") Then
            Return True
        End If
    End While
    Return False
End Function

Function RegistrationWizard_ShowDowngradeScreen(enabled = True As Boolean, defaultProductCode = "PROD1" As String) As Boolean
    pageName = "app:roku:all access:upsell"
    Omniture().TrackPage(pageName, ["event89"], {v10: "upsell_downgrade"})

    facade = CreateObject("roImageCanvas")
    facade.SetLayer(0, { Color: "#000000" })
    facade.Show()
    
    waitDialog = ShowWaitDialog()
        
    bgInfo = Cbs().GetUpsellInfo("AAUPSELLBKCD")
    upsellInfo = {}
    If enabled Then
        upsellInfo = Cbs().GetUpsellInfo("ROKUDOWNGRADE")
    Else
        upsellInfo = Cbs().GetUpsellInfo("OTHERDOWNGRADE")
    End If

    titleText = AsString(upsellInfo.Response.upsellMessage)
    subTitleText = AsString(upsellInfo.Response.upsellMessage2)
    priceText = AsString(upsellInfo.Response.callToAction)
    trialText = ""
    productID = AsString(upsellInfo.Response.aaProductID, defaultProductCode)

    noButtonsText = AsString(upsellInfo.Response.upsellMessage3)

    headerImage = AsString(bgInfo.Background)
    disclaimerText = AsString(bgInfo.Response.upsellMessage)
    
    options = []
    options.Push({
        ID:             "keep"
        TitleText:      titleText
        SubtitleText:   subTitleText
        PriceText:      priceText
        TrialText:      trialText
        Enabled:        enabled
        ProductCode:    productID
    })
    
    buttons = []
    If enabled Then
        buttons.Push({
            ID: "downgrade"
            Text: "Switch Plan"
            ProductCode: productID
            OmnitureData:   {
                Product: "Downgrade"
                LinkName: pageName + ":downgrade:click"
                Params: {  
                    v10: "upsell_downgrade"
                }
                Events: ["event19"]
            }
        })
    End If
    
    optionsScreen = NewOptionsScreen()
    optionsScreen.Setup(options, buttons, noButtonsText, disclaimerText, headerImage)
    
    waitDialog.Close()
    
    While True
        result = optionsScreen.Show()
        If result = invalid Then
            Exit While
        Else If m.ProcessOptionsScreenResult(result, "") Then
            Return True
        End If
    End While
    Return False
End Function

Function RegistrationWizard_ProcessOptionsScreenResult(result As Object, tourVideoID = "" As String) As Boolean
    If result = invalid Then
        Return True
    Else
        If result.OmnitureData <> invalid Then
            Omniture().TrackEvent(result.OmnitureData.LinkName, result.OmnitureData.Events, result.OmnitureData.Params)
        End If
        If result.id = "quickTour" Then
            If Not IsNullOrEmpty(tourVideoID) Then
                tourVideo = Cbs().GetEpisode(tourVideoID)
                videoPlayer = NewVideoPlayer()
                If videoPlayer.Play(tourVideo, False) Then
                    While EventListener().ListenForOne()
                        If videoPlayer.Screen = invalid Then
                            Exit While
                        End If
                    End While
                End If
                Return False
            End If
        Else If result.id = "signIn" Then
            If m.AuthenticateWithCode() Then
                Return True
            End If
        Else If result.id = "subscribe" Then
            If m.SignUp(result.productCode) Then
                Omniture().TrackEvent("", ["event101"], { v10: "billing_confirm_" + AsString(result.OmnitureData.Product) })
                Return True
            Else
                Omniture().TrackEvent("", ["event102"], { v10: "billing_failure_" + AsString(result.OmnitureData.Product) })
            End If
        Else If result.id = "upgrade" Or result.id = "downgrade" Then
            upgradeTime = NowDate().AsSeconds()
            If upgradeTime - Cbs().UpgradeTime > Cbs().UpgradeCoolDown Then
                If result.id = "upgrade" Then
                    If m.SwitchPlan(result.productCode) Then
                        Omniture().TrackEvent("", ["event103"], { v10: "billing_confirm_" + AsString(result.OmnitureData.Product) })
                        Return True
                    Else
                        Omniture().TrackEvent("", ["event102"], { v10: "billing_failure_" + AsString(result.OmnitureData.Product) })
                    End If
                Else If result.id = "downgrade" Then
                    If m.SwitchPlan(result.productCode) Then
                        Omniture().TrackEvent("", ["event104"], { v10: "billing_confirm_" + AsString(result.OmnitureData.Product) })
                        Return True
                    Else
                        Omniture().TrackEvent("", ["event102"], { v10: "billing_failure_" + AsString(result.OmnitureData.Product) })
                    End If
                End If
            Else
                ShowMessageBox("", "We are currently processing your initial purchase. Please try again in a couple minutes.", ["OK"], True)
                Return True
            End If
        Else If result.id = "keep" Then
            Return True
        End If
    End If
    Return False
End Function

Function RegistrationWizard_SignUp(productCode As String) As Boolean
    facade = CreateObject("roPosterScreen")
    facade.Show()
    dialog = ShowWaitDialog("Please wait...")
    product = ChannelStore().GetProduct(AsString(productCode))
    If product <> invalid And ChannelStore().GetPurchases().Count() = 0 Then
        dialog.Close()
        dialog = invalid
        userData = m.GetUserData()
        If userData <> invalid Then
            If m.ShowConfirmationScreen(userData) Then
                If m.ShowTOSScreen() Then
                    transactionID = Cbs().Subscribe(product)
                    If Not IsNullOrEmpty(transactionID) Then
                        Omniture().TrackPage("app:roku:new user:share information workflow:creating account")
                        dialog = ShowWaitDialog("Creating account...") 
                        data = ShallowCopy(userData)
                        data.DOB = m.FormatBirthDate(data.DOB)
                        createResult = Cbs().CreateAccount(data, transactionID)
                        dialog.Close()
                        If createResult Then
                            Omniture().TrackPage("app:roku:new user:share information workflow:congratulations", ["event100"])
                            dialog = ShowMultilineWaitDialog("Congratulations! Your CBS All Access account has been created.")
                            Sleep(3000)
                            dialog.Close()
                            Return True
                        Else
                            ShowMessageBox("Error", "An error occurred when creating your CBS All Access account. Please contact customer support for assistance at " + Cbs().CSNumber + ".", ["OK"], True)
                        End If
                    End If
                End If
            End If
        Else
            If Cbs().IsAuthenticated() Then
                ' If we get here, the user was prompted to log in to an existing account,
                ' so return a success value
                Return True
            End If
        End If
    Else
        dialog.Close()
        dialog = invalid
        'ShowMessageBox("Sign Up", "Please visit cbs.com/all-access to sign up now.", ["OK"], True)
'        Omniture().TrackEvent(signInText, ["event19"], { v46: "roku:splash:" + LCase(signInText) })
        If m.AuthenticateWithCode() Then
            Return True
        End If
    End If
    If dialog <> invalid Then
        dialog.Close()
    End If
    facade.Close()
    Return False
End Function

Function RegistrationWizard_SwitchPlan(productCode As String, upgrade = True As Boolean) As Boolean
    facade = CreateObject("roPosterScreen")
    facade.Show()
    dialog = ShowWaitDialog("Please wait...")
    product = ChannelStore().GetProduct(AsString(productCode))
    If product <> invalid Then
        dialog.Close()
        dialog = invalid
        transactionID = Cbs().Subscribe(product)
        If Not IsNullOrEmpty(transactionID) Then
            dialog = ShowWaitDialog("Switching plan...") 
            result = False
            If upgrade Then
                result = Cbs().Upgrade(transactionID)
            Else
                result = Cbs().Downgrade(transactionID)
            End If
            dialog.Close()
            If result Then
                Return True
            Else
                ShowMessageBox("Error", "An error occurred when switching your CBS All Access plan. Please contact customer support for assistance at " + Cbs().CSNumber + ".", ["OK"], True)
            End If
        End If
    Else
        dialog.Close()
        dialog = invalid
        ShowMessageBox("Switch Plan", "Please visit cbs.com/all-access to switch your plan.", ["OK"], True)
    End If
    If dialog <> invalid Then
        dialog.Close()
    End If
    facade.Close()
    Return False
End Function

