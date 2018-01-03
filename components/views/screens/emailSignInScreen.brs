sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.email = m.top.findNode("email")
    m.password = m.top.findNode("password")
    
    m.form = m.top.findNode("form")
    m.form.observeField("buttonSelected", "onControlSelected")
    
    m.store = m.top.findNode("store")
    m.store.observeField("userData", "onUserDataLoaded")
    m.store.requestedUserData = "email"
    m.store.command = "getUserData"

    m.top.setFocus(true)
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
            if validateData() then
                m.global.showWaitScreen = true
                m.signInTask = createObject("roSGNode", "SignInTask")
                m.signInTask.username = m.email.text
                m.signInTask.password = m.password.text
                m.signInTask.observeField("signedIn", "onSignedIn")
                m.signInTask.control = "run"
            end if
        else if control.id = "forgotPassword" then
            if not m.email.isValid then
                m.form.jumpToButton = "email"
                dialog = createCbsDialog("Error", m.email.validationError, ["OK"])
                dialog.observeField("buttonSelected", "closeDialog")
                m.global.dialog = dialog
            else
                m.global.showWaitScreen = true
                m.forgotPasswordTask = createObject("roSGNode", "ForgotPasswordTask")
                m.forgotPasswordTask.email = m.email.text
                m.forgotPasswordTask.observeField("success", "onForgotPasswordSuccess")
                m.forgotPasswordTask.control = "run"
            end if
        end if
    end if
end sub

sub onForgotPasswordSuccess(nodeEvent as object)
    m.global.showWaitScreen = false
    if m.forgotPasswordTask.success then
        dialog = createCbsDialog("Password Reset Email Sent", "Please check your email and follow the instructions to reset your password.", ["OK"])
        dialog.observeField("buttonSelected", "closeDialog")
        m.global.dialog = dialog
    else
        dialog = createCbsDialog("Error", "An error occurred sending password reset email.  Please check your email address and try again.", ["OK"])
        dialog.observeField("buttonSelected", "closeDialog")
        m.global.dialog = dialog
    end if
end sub

sub onSignedIn(nodeEvent as object)
    if m.global.dialog <> invalid then
        m.global.dialog.close = true
    end if
    m.global.showWaitScreen = false
    if m.signInTask.signedIn then
        m.top.success = true
    else
        dialog = createCbsDialog("Error", "Incorrect username or password.", ["OK"])
        dialog.observeField("buttonSelected", "closeDialog")
        m.global.dialog = dialog
    end if
end sub

sub closeDialog(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
end sub

sub captureInput(textbox as object)
    if textbox.id = "email" then
        dialog = createKeyboardDialog("Enter your email address", textbox.text, ["OK"])
        dialog.id = textbox.id
        dialog.observeField("buttonSelected", "onDialogButtonSelected")
        m.global.dialog = dialog
    else if textbox.id = "password" then
        dialog = createKeyboardDialog("Enter your password", textbox.text, ["OK"])
        dialog.keyboard.textEditBox.secureMode = true
        dialog.id = textbox.id
        dialog.observeField("buttonSelected", "onDialogButtonSelected")
        m.global.dialog = dialog
    end if
end sub

sub onDialogButtonSelected(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    textbox = m.top.findNode(dialog.id)
    if textbox <> invalid then
        textbox.text = dialog.text
    end if
    dialog.close = true
    m.top.setFocus(true)
end sub

sub onUserDataLoaded()
    userData = m.store.userData
    if userData <> invalid then
        m.email.text = userData.email
        if not isNullOrEmpty(m.email.text) then
            m.form.jumpToButton = "password"
        end if
    end if
    m.top.setFocus(true)
end sub

function validateData() as boolean
    for i = 0 to m.form.getChildCount() - 1
        textbox = m.form.getChild(i)
        if textbox.subtype() = "TextBox" then
            if not textbox.isValid then
                m.form.jumpToIndex = i
                dialog = createCbsDialog("Error", textbox.validationError, ["OK"])
                dialog.observeField("buttonSelected", "closeDialog")
                m.global.dialog = dialog
                return false
            end if
        end if
    next
    return true
end function

