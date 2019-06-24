function createMessageDialog(title as string, message as string, buttons = ["OK"] as object, dialogType = "Dialog" as string) as object
    dialog = createObject("roSGNode", dialogType)
    dialog.title = title
    dialog.message = message
    dialog.buttons = buttons
    return dialog
end function

function createDateDialog(title as string, date as object, buttons = ["OK"] as object) as object
    dialog = createObject("roSGNode", "DateDialog")
    dialog.title = title
    dialog.date = date
    dialog.buttons = buttons
    return dialog
end function

function createKeyboardDialog(title as string, text = "" as string, buttons = ["OK"] as object, isSecure = false as boolean) as object
    dialog = createObject("roSGNode", "KeyboardDialog")
    updateKeyboardDialog(dialog, title, text, buttons, isSecure)
    return dialog
end function

sub updateKeyboardDialog(dialog as object, title as string, text = "" as string, buttons = ["OK"] as object, isSecure = false as boolean)
    dialog.title = title
    dialog.keyboard.text = text
    dialog.keyboard.textEditBox.secureMode = isSecure
    dialog.keyboard.textEditBox.cursorPosition = text.len()
    'dialog.keyboard.keyColor = &hfefefeff
    'dialog.keyboard.focusedKeyColor = &hfefefeff
    'dialog.keyboard.focusBitmapUri = "pkg:/images/button_keyboard_focused_hd.9.png"
    dialog.buttons = buttons
end sub

function createWaitDialog(title as string, spinnerImage = "" as string) as object
    dialog = createObject("roSGNode", "ProgressDialog")
    dialog.title = title
'    'if spinnerImage <> invalid and spinnerImage <> "" then
'        dialog.busySpinner.control = "stop" '.poster.uri = spinnerImage
'    'end if
    return dialog
end function

function setSceneDialog(node as object, dialog as object) as boolean
    scene = node.getScene()
    if scene = invalid then
        scene = node.getParent()
        while scene <> invalid
            if scene.getParent() <> invalid then
                scene = scene.getParent()
            else
                exit while
            end if
        end while
    end if
    if scene <> invalid and scene.hasField("dialog") then
        scene.dialog = dialog
        return true
    end if
    return false
end function