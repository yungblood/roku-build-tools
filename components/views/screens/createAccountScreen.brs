sub init()
    m.top.omnitureName = "/all-access/user/signup/"
    m.top.omniturePageType = "svod_signup"
    m.top.omnitureSiteHier = "all access|signup"
    
    m.persistedDataKey = "accountCreationData"

    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.firstName = m.top.findNode("firstName")
    m.lastName = m.top.findNode("lastName")
    m.email = m.top.findNode("email")
    m.password = m.top.findNode("password")
    m.zipCode = m.top.findNode("zipCode")
    m.birthdate = m.top.findNode("birthdate")
    m.gender = m.top.findNode("gender")
    
    m.form = m.top.findNode("form")
    m.form.observeField("buttonSelected", "onControlSelected")
    
    m.tos = m.top.findNode("tos")
    m.tos.observeField("buttonSelected", "onTosButtonSelected")
    
    m.store = m.top.findNode("store")
    m.store.observeField("userData", "onUserDataLoaded")

    trackRMFEvent("ACN")
    m.fakeButton = m.top.findNode("fakeButton")
    m.allowBackKey = false

    m.persistedData = {}
    loadPersistedData()
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if  m.allowBackKey = false then
            m.fakeButton.setFocus(true)
        else
            m.form.setFocus(true)
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if m.fakeButton.hasFocus()
        'We must eat the keypress here in this case
        'otherwise the roku store component could crash the app
        return true
    end if
    if press then
        if key = "down" then
            if m.form.isInFocusChain() then
                m.tos.setFocus(true)
                return true
            end if
        else if key = "up" then
            if m.tos.hasFocus() then
                m.form.setFocus(true)
                return true
            end if
        else if key = "back" then
            'save persisted
            savePersistedData(m.persistedData)
            return false
        end if
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
        else if control.id = "createAccount" then
            if validateData() then
                m.waitDialog = createWaitDialog("Validating account details...")
                setGlobalField("cbsDialog", m.waitDialog)

                m.validateTask = createObject("roSGNode", "ValidateAccountDetailsTask")
                m.validateTask.observeField("success", "onValidationSuccess")
                m.validateTask.accountDetails = getAccountDetails()
                m.validateTask.control = "run"
            end if
        end if
    end if
end sub

sub onTosButtonSelected(nodeEvent as object)
    button = nodeEvent.getRoSGNode()
    if button <> invalid then
        m.top.buttonSelected = button.id
    end if
end sub

sub onValidationSuccess(nodeEvent as object)
    m.waitDialog.close = true
    task = nodeEvent.getRoSGNode()
    if task.success then
        m.top.accountDetails = getAccountDetails()
        savePersistedData({})
    else
        if task.error = "EMAIL_EXISTS" then
            dialog = createCbsDialog("CBS Account Exists", "The email you entered is already associated with an existing CBS account. Please sign in instead.", ["OK"])
            dialog.observeField("buttonSelected", "onEmailExists")
            setGlobalField("cbsDialog", dialog)
        else if task.error = "INVALID_ZIP" then
            m.form.jumpToButton = "zipCode"
            dialog = createCbsDialog("Error", m.zipCode.validationError, ["OK"])
            dialog.observeField("buttonSelected", "closeDialog")
            setGlobalField("cbsDialog", dialog)
        end if
    end if
end sub

function getAccountDetails() as object
    return {
        firstName: m.firstName.text
        lastName: m.lastName.text
        email: m.email.text
        zip: m.zipCode.text
        password: m.password.text
        DOB: formatBirthDate(m.birthDate.text)
        gender: m.gender.text
    }
end function

sub closeDialog(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
end sub

sub closeDialogAndScreen(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
    m.top.buttonSelected = "back"
end sub

sub onEmailExists(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
    m.top.buttonSelected = "signIn"
end sub

sub advanceToFirstEmptyField(select = true as boolean)
    for i = 0 to m.form.getChildCount() - 1
        m.form.jumpToIndex = i
        textbox = m.form.getChild(i)
        if textbox <> invalid and textbox.subtype() = "TextBox" then
            if isNullOrEmpty(textbox.text) then
                if select then
                    m.form.buttonSelected = i
                end if
                exit for
            end if
        end if
    next
end sub

sub captureInput(textbox as object)
    if textbox.id = "firstName" then
        dialog = createKeyboardDialog("Enter your first name", textbox.text, ["OK"])
        dialog.id = textbox.id
        dialog.observeField("buttonSelected", "onDialogButtonSelected")
        setGlobalField("cbsDialog", dialog)
    else if textbox.id = "lastName" then
        dialog = createKeyboardDialog("Enter your last name", textbox.text, ["OK"])
        dialog.id = textbox.id
        dialog.observeField("buttonSelected", "onDialogButtonSelected")
        setGlobalField("cbsDialog", dialog)
    else if textbox.id = "email" then
        dialog = createKeyboardDialog("Enter your email address", textbox.text, ["OK"])
        dialog.id = textbox.id
        dialog.observeField("buttonSelected", "onDialogButtonSelected")
        setGlobalField("cbsDialog", dialog)
    else if textbox.id = "password" then
        dialog = createKeyboardDialog("Create a password (must be at least 6 characters)", textbox.text, ["OK"])
        dialog.keyboard.textEditBox.secureMode = true
        dialog.id = textbox.id
        dialog.observeField("buttonSelected", "onDialogButtonSelected")
        setGlobalField("cbsDialog", dialog)
    else if textbox.id = "zipCode" then
        dialog = createKeyboardDialog("Enter your 5-digit zip code", textbox.text, ["OK"])
        dialog.id = textbox.id
        dialog.observeField("buttonSelected", "onDialogButtonSelected")
        setGlobalField("cbsDialog", dialog)
    else if textbox.id = "birthDate" then
        captureBirthDate(textbox)
        'dialog = createKeyboardDialog("Enter your birth date MM/DD/YYYY - example: 12/24/1978", textbox.text, ["OK"])
        'dialog.id = textbox.id
        'dialog.observeField("buttonSelected", "onDialogButtonSelected")
       ' setGlobalField("cbsDialog", dialog)
    else if textbox.id = "gender" then
        dialog = createMessageDialog("Select your gender", "", ["Male", "Female", "Other", "Prefer Not To Say"])
        dialog.id = textbox.id
        dialog.observeField("buttonSelected", "onDialogButtonSelected")
        setGlobalField("cbsDialog", dialog)
    end if
end sub

sub captureBirthDate(textbox as object)
    dialog = createKeyPadDialog("Enter your birth month (MM) - example: 12", "", "", ["OK"])
    dialog.id = textbox.id
    dialog.textLength = 2
    dialog.observeField("buttonSelected", "onBirthMonthChanged")
    setGlobalField("cbsDialog", dialog)
end sub

sub onBirthMonthChanged(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    textbox = m.top.findNode(dialog.id)
    if textbox <> invalid then
        textbox.text = dialog.text + "/"
    end if
    dialog.close = true

    dialog = createKeyPadDialog("Enter your birth day (DD) - example: 24", "", "", ["OK"])
    if textbox <> invalid then
        dialog.id = textbox.id
    end if
    dialog.textLength = 2
    dialog.observeField("buttonSelected", "onBirthDayChanged")
    setGlobalField("cbsDialog", dialog)
end sub

sub onBirthDayChanged(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    textbox = m.top.findNode(dialog.id)
    if textbox <> invalid then
        textbox.text = textbox.text + dialog.text + "/"
    end if
    dialog.close = true
    dialog = createKeyPadDialog("Enter your birth year (YYYY) - example: 1978", "", "", ["OK"])
    if textbox <> invalid then
        dialog.id = textbox.id
    end if
    dialog.textLength = 4
    dialog.observeField("buttonSelected", "onBirthYearChanged")
    setGlobalField("cbsDialog", dialog)
end sub

sub onBirthYearChanged(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    textbox = m.top.findNode(dialog.id)
    if textbox <> invalid then
        textbox.text = textbox.text + dialog.text
        m.persistedData[textbox.id] = textbox.text
        if not isNullOrEmpty(textbox.text) then
            advanceToFirstEmptyField(true)
        end if
    end if
    dialog.close = true
end sub

sub onDialogButtonSelected(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    textbox = m.top.findNode(dialog.id)
    if textbox <> invalid then
        if textbox.id = "gender" then
            textbox.text = dialog.buttons[nodeEvent.getData()]
        else
            textbox.text = dialog.text
        end if
        
        m.persistedData[textbox.id] = textbox.text

        if not isNullOrEmpty(textbox.text) then
            advanceToFirstEmptyField(true)
        end if
    end if
    dialog.close = true
end sub

function validateData() as boolean
    for i = 0 to m.form.getChildCount() - 1
        textbox = m.form.getChild(i)
        if textbox.subtype() = "TextBox" then
            if not textbox.isValid then
                m.form.jumpToIndex = i
                dialog = createCbsDialog("Error", textbox.validationError, ["OK"])
                dialog.observeField("buttonSelected", "closeDialog")
                setGlobalField("cbsDialog", dialog)
                return false
            else if textbox.id = "birthDate" then
                valid = validateBirthDate(textbox.text)
                if valid <> 1 then
                    errorMessage = textbox.validationError
                    if valid = -1 then
                        errorMessage = "We are sorry, but we are unable to create an account for you at this time."
                    end if
                    m.form.jumpToIndex = i
                    dialog = createCbsDialog("Error", errorMessage, ["OK"])
                    dialog.observeField("buttonSelected", "closeDialog")
                    setGlobalField("cbsDialog", dialog)
                    return false
                end if
            end if
        end if
    next
    return true
end function

function validateBirthDate(birthDate as string, requiredAge = 18 as integer) as integer
    regex = createObject("roRegex", "^(\d{1,2})(?:[\.|/|-]{1})(\d{1,2})(?:[\.|/|-]{1})(\d{4})$", "")
    dateParts = regex.match(birthDate)
    if dateParts.count() = 4 then
        ' Ensure the date is before today
        validDate = asString(asInteger(dateParts[3])) + "-" + padLeft(dateParts[1], "0", 2) + "-" + padLeft(dateParts[2], "0", 2) + "T" + getTimeString(nowDate(), false, true, false)
        seconds = dateFromIso8601String(validDate).asSeconds()
        ' NOTE: An invalid ISO parse will result in a 1/1/1970 12:00am date, which is 0 seconds from linux epoch.
        '       if someone was actually born on 1/1/1970 and they test this at exactly 12:00:00.000 (extremely unlikely),
        '       this check will still fail.
        if seconds = 0 Or seconds >= nowDate().asSeconds() then
            'ShowMessageBox("Invalid Date", "Please enter a valid date of birth in the following format: MM.DD.YYYY.", ["OK"], true)
            return 0
        end if
        
        ' Add requiredAge years to birth date
        validDate = asString(AsInteger(dateParts[3]) + requiredAge) + "-" + padLeft(dateParts[1], "0", 2) + "-" + padLeft(dateParts[2], "0", 2) + "T" + getTimeString(nowDate(), false, true, false)
        seconds = dateFromIso8601String(validDate).asSeconds()
        if seconds > nowDate().asSeconds() then
            return -1
        end if
    else
        return 0
    end if
    return 1
end function

function formatBirthDate(birthDate as string) as string
    regex = createObject("roRegex", "^(\d{1,2})(?:[\.|/|-]{1})(\d{1,2})(?:[\.|/|-]{1})(\d{4})$", "")
    dateParts = regex.match(birthDate)
    if dateParts.count() = 4 then
        return padLeft(dateParts[1], "0", 2) + "/" + padLeft(dateParts[2], "0", 2) + "/" + asString(asInteger(dateParts[3]))
    end if
    return birthDate
end function

sub loadUserData()
    showSpinner()
    m.store.requestedUserData = "firstname,lastname,email,zip"
    m.store.command = "getUserData"
end sub

sub onUserDataLoaded(nodeEvent as object)
    userData = nodeEvent.getData()
    hideSpinner()
    m.allowBackKey = true
    if userData = invalid then
        if m.noShareDialog = invalid then
            m.noShareDialog = createCbsDialog("Information Needed", "In order to subscribe to the CBS All Access channel, you are required to share your Roku information. If you need to update your information, please visit Roku.com, then come back to CBS All Access and try again.", ["OK"])
            m.noShareDialog.observeField("buttonSelected", "closeDialogAndScreen")
            setGlobalField("cbsDialog", m.noShareDialog)
        end if
    else
        m.firstName.text = userData.firstname
        m.lastName.text = userData.lastname
        m.email.text = userData.email
        m.zipCode.text = userData.zip
        
        m.persistedData[m.firstName.id] = m.firstName.text
        m.persistedData[m.lastName.id] = m.lastName.text
        m.persistedData[m.email.id] = m.email.text
        m.persistedData[m.zipCode.id] = m.zipCode.text
        
        m.form.setFocus(true)
        advanceToFirstEmptyField(false)
    end if
end sub

sub loadPersistedData()
    m.registryTask = createObject("roSGNode", "RegistryTask")
    m.registryTask.observeField("complete", "onPersistedDataLoaded")
    m.registryTask.key = m.persistedDataKey
    m.registryTask.section = constants().registrySection
    m.registryTask.mode = "load"
end sub

sub onPersistedDataLoaded(nodeEvent as object)
    m.registryTask = invalid
    task = nodeEvent.getRoSGNode()
    if isNullOrEmpty(task.value) then
        loadUserData()
    else
        data = parseJson(task.value)
        for each key in data.keys()
            textbox = m.top.findNode(key)
            if textbox <> invalid then
                textbox.text = data[key]
            end if
            m.persistedData[key] = data[key]
        next
        advanceToFirstEmptyField(false)
        m.allowBackKey = true
        m.form.setFocus(true)
    end if
end sub

sub savePersistedData(data = {} as object)
    m.registryTask = createObject("roSGNode", "RegistryTask")
    m.registryTask.observeField("complete", "onPersistedDataSaved")
    m.registryTask.key = m.persistedDataKey
    m.registryTask.section = constants().registrySection
    if data.isEmpty() then
        m.registryTask.mode = "delete"
    else
        m.registryTask.value = formatJson(data)
        m.registryTask.mode = "save"
    end if
end sub

sub onPersistedDataSaved(nodeEvent as object)
    m.registryTask = invalid
end sub
