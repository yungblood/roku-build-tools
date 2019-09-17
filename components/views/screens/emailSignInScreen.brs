sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.email = m.top.findNode("email")
    m.password = m.top.findNode("password")
    
    m.form = m.top.findNode("form")
    m.form.observeField("buttonSelected", "onControlSelected")

    m.store = m.top.findNode("store")
    'Set KEY LOCKOUT FLAG for appScene main scenegraph thread
    'This is to track that the channel store is set to run a request
    SetGlobalField("storeDisplayed", true)
    showSpinner()
    m.store.observeField("userData", "onUserDataLoaded")
    m.store.requestedUserData = "email"
    m.store.command = "getUserData"
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.form.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
    end if
    return false
end function

sub onTextboxSelected(nodeEvent as object)
    textbox = nodeEvent.getRoSGNode()
    captureInput(textbox)
end sub

sub onControlSelected(nodeEvent as object)
    control = m.form.getChild(nodeEvent.getData())
    if control <> invalid then
        if control.subtype() = "TextBox" then
            captureInput(control)
        else if control.id = "signIn" then
            if m.signInTask = invalid then
                if validateData() then
                    setGlobalField("showWaitScreen", true)
                    m.signInTask = createObject("roSGNode", "SignInTask")
                    m.signInTask.username = m.email.text
                    m.signInTask.password = m.password.text
                    m.signInTask.observeField("signedIn", "onSignedIn")
                    m.signInTask.control = "run"
                end if
            end if
        else if control.id = "forgotPassword" then
            if m.forgotPasswordTask = invalid then
                if not m.email.isValid then
                    m.form.jumpToButton = "email"
                    dialog = createCbsDialog("Incorrect email address", m.email.validationError.replace("\n", chr(10)), ["OK"])
                    dialog.observeField("buttonSelected", "closeDialog")
                    setGlobalField("cbsDialog", dialog)
                else
                    setGlobalField("showWaitScreen", true)
                    m.forgotPasswordTask = createObject("roSGNode", "ForgotPasswordTask")
                    m.forgotPasswordTask.email = m.email.text
                    m.forgotPasswordTask.observeField("success", "onForgotPasswordSuccess")
                    m.forgotPasswordTask.control = "run"
                end if
            end if
        end if
    end if
end sub

sub onForgotPasswordSuccess(nodeEvent as object)
    m.forgotPasswordTask = invalid
    task = nodeEvent.getRoSGNode()
    setGlobalField("showWaitScreen", false)
    if task.success then
        dialog = createCbsDialog("Password reset email sent", "Instructions to change your password have been sent to " + task.email + ".", ["OK"])
        dialog.observeField("buttonSelected", "closeDialog")
        setGlobalField("cbsDialog", dialog)
    else
        dialog = createCbsDialog("Error", "An error occurred sending password reset email.  Please check your email address and try again.", ["OK"])
        dialog.observeField("buttonSelected", "closeDialog")
        setGlobalField("cbsDialog", dialog)
    end if
end sub

sub onSignedIn(nodeEvent as object)
    dialog = getGlobalField("cbsDialog")
    if dialog <> invalid then
        dialog.close = true
    end if
    m.signInTask = invalid
    task = nodeEvent.getRoSGNode()
    setGlobalField("showWaitScreen", false)
    if task.signedIn then
        m.top.cookies = task.cookies
        m.top.localStation = task.localStation
        m.top.lastLiveChannel = task.lastLiveChannel
        m.top.shows = task.shows
        m.top.showCache = task.showCache
        m.top.user = task.user

        m.top.success = true
    else
        dialog = createCbsDialog("Error", "Incorrect username or password.", ["OK"])
        dialog.observeField("buttonSelected", "closeDialog")
        setGlobalField("cbsDialog", dialog)
    end if
end sub

sub closeDialog(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
end sub

sub advanceToFirstEmptyField(select = false as boolean)
    for i = 0 to m.form.getChildCount() - 1
        m.form.jumpToIndex = i
        textbox = m.form.getChild(i)
        if textbox <> invalid then
            if textbox.subtype() = "TextBox" then
                if isNullOrEmpty(textbox.text) then
                    if select then
                        m.form.buttonSelected = i
                    end if
                    exit for
                end if
            else
                exit for
            end if
        end if
    next
end sub

sub captureInput(textbox as object)
    if textbox.id = "email" then
        dialog = createKeyboardDialog("Enter your email address", textbox.text, ["OK","Clear"])
        dialog.id = textbox.id
        dialog.observeField("buttonSelected", "onDialogButtonSelected")
        setGlobalField("cbsDialog", dialog)
    else if textbox.id = "password" then
        dialog = createKeyboardDialog("Enter your password", textbox.text, ["OK","Clear"])
        dialog.keyboard.textEditBox.secureMode = true
        dialog.id = textbox.id
        dialog.observeField("buttonSelected", "onDialogButtonSelected")
        setGlobalField("cbsDialog", dialog)
    end if
end sub

sub onDialogButtonSelected(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    textbox = m.top.findNode(dialog.id)
    if dialog.buttonSelected = 0 then 'OK
        if textbox <> invalid then
            textbox.text = dialog.text
        end if
        dialog.close = true
        advanceToFirstEmptyField(false)
    else if dialog.buttonSelected = 1 then 'Cancel
        dialog.text = ""
        textbox.text = dialog.text
    end if
end sub

sub onUserDataLoaded()
    userData = m.store.userData
    if userData <> invalid then
        m.email.text = userData.email
        advanceToFirstEmptyField(false)
    end if
    SetGlobalField("storeDisplayed", false)
    hideSpinner()
    m.form.setFocus(true)
end sub

function validateData() as boolean
    for i = 0 to m.form.getChildCount() - 1
        textbox = m.form.getChild(i)
        if textbox.subtype() = "TextBox" then
            if not textbox.isValid then
                m.form.jumpToIndex = i
                
                title = "Error"
                if textbox.id = "email" then
                    title = "Incorrect email address"
                end if
                dialog = createCbsDialog(title, textbox.validationError.replace("\n", chr(10)), ["OK"])
                dialog.observeField("buttonSelected", "closeDialog")
                setGlobalField("cbsDialog", dialog)
                return false
            end if
        end if
    next
    return true
end function

