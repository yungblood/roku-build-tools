'*************************************************************
'** Set the configurable theme attributes for the application
'*************************************************************
Sub InitTheme()
    buttonTextColor                                 = "#B2B2B2"
    buttonHighlightTextColor                        = "#FFFFFF"
    
    theme     = {}
    
    theme.ThemeType                                 = "generic-dark"
    
    theme.DialogBackgroundSize                      = "full-screen"
    theme.DialogTitleText                           = "#FFFFFF"
    theme.DialogBodyText                            = "#FFFFFF"

    theme.OverhangSliceSD                           = "pkg:/images/overhang_options_sd.jpg"
    theme.OverhangSliceHD                           = "pkg:/images/overhang_options_hd.jpg"

    theme.BackgroundColor                           = "#000000"

    theme.ButtonMenuNormalText                      = buttonTextColor
    theme.ButtonMenuNormalColor                     = buttonTextColor
    theme.ButtonMenuHighlightText                   = buttonHighlightTextColor
    theme.ButtonMenuHighlightColor                  = buttonHighlightTextColor
    theme.ButtonNormalText                          = buttonTextColor
    theme.ButtonNormalColor                         = buttonTextColor
    theme.ButtonHighlightText                       = buttonHighlightTextColor
    theme.ButtonHighlightColor                      = buttonHighlightTextColor
    theme.ButtonMenuNormalOverlayText               = buttonTextColor
    theme.ButtonMenuNormalOverlayColor              = buttonTextColor
    
    'theme.BreadcrumbAdjustHD_X                      = "32"
    'theme.BreadcrumbAdjustSD_X                      = "18"
    theme.BreadcrumbAdjustSD_Y                      = "-5"
    theme.DefaultBreadcrumbDelimiter                = "#FFFFFF" '"#B2B2B2"
    theme.DefaultBreadcrumbTextLeft                 = "#FFFFFF" '"#B2B2B2"
    theme.DefaultBreadcrumbTextRight                = "#FFFFFF" '"#B2B2B2"
    
    theme.BreadcrumbDelimiter                       = theme.DefaultBreadcrumbDelimiter
    theme.BreadcrumbTextLeft                        = theme.DefaultBreadcrumbTextLeft
    theme.BreadcrumbTextRight                       = theme.DefaultBreadcrumbTextRight

    ' GridScreen Theme Settings
    theme.GridScreenBackgroundColor                 = "#000000"
    theme.GridScreenLogoHD                          = ""
    theme.GridScreenLogoSD                          = ""
    theme.GridScreenLogoOffsetHD_X                  = "383"
    theme.GridScreenLogoOffsetHD_Y                  = "0"
    theme.GridScreenLogoOffsetSD_X                  = "229"
    theme.GridScreenLogoOffsetSD_Y                  = "0"
    
    theme.OverhangPrimaryLogoHD                     = ""
    theme.OverhangPrimaryLogoSD                     = ""
    theme.OverhangPrimaryLogoOffsetHD_X             = "383"
    theme.OverhangPrimaryLogoOffsetHD_Y             = "0"
    theme.OverhangPrimaryLogoOffsetSD_X             = "229"
    theme.OverhangPrimaryLogoOffsetSD_Y             = "0"
'    theme.GridScreenRetrievingColor                 = "#CCCCCC"
'    theme.GridScreenListNameColor                   = "#CCCCCC"
'    
'    theme.GridScreenDescriptionTitleColor           = "#FFFFFF"
'    theme.GridScreenDescriptionDateColor            = "#FF0000"
'    theme.GridScreenDescriptionRuntimeColor         = "#FFFFFF"
'    theme.GridScreenDescriptionSynopsisColor        = "#FFFFFF"
'
'    theme.GridScreenBreadcrumbAdjustHD_X            = theme.BreadcrumbAdjustHD_X
'    theme.GridScreenBreadcrumbAdjustSD_X            = theme.BreadcrumbAdjustSD_X
'    theme.GridScreenBreadcrumbDelimiter             = "#555555"
'    theme.GridScreenBreadcrumbTextLeft              = "#555555"
'    theme.GridScreenBreadcrumbTextRight             = "#555555"
    
    ' Grid Screen
    theme.CounterTextLeft                           = "#CCCCCC"
    theme.CounterSeparator                          = "#9A9A9A"
    theme.CounterTextRight                          = "#CCCCCC"
    
    theme.GridScreenOverhangSliceHD                 = "pkg:/images/overhang_options_hd.jpg"
    theme.GridScreenOverhangSliceSD                 = "pkg:/images/overhang_options_sd.jpg"
    
    theme.GridScreenOverhangHeightSD                = "61"
    theme.GridScreenOverhangHeightHD                = "120"
    theme.GridScreenBreadcrumbAdjustSD_Y            = theme.BreadcrumbAdjustSD_Y
    
'    theme.GridScreenFocusBorderHD                   = "pkg:/images/grid_focus_hd.png"
'    theme.GridScreenBorderOffsetHD                  = "(-2,-2)"
'    theme.GridScreenFocusBorderSD                   = "pkg:/images/grid_focus_sd.png"
'    theme.GridScreenBorderOffsetSD                  = "(-2,-2)"
'    
'    theme.GridScreenDescriptionImageHD              = "pkg:/images/grid_description_hd.png"
'    theme.GridScreenDescriptionUpperLeftBorderHD    = "(65,60)"
'    theme.GridScreenDescriptionLowerRightBorderHD   = "(26,32)"
'    theme.GridScreenDescriptionBackFillSizeHD       = "(0x0)" ' disable backfill
'
'    theme.GridScreenDescriptionImageSD              = "pkg:/images/grid_description_sd.png"
'    theme.GridScreenDescriptionUpperLeftBorderSD    = "(40,40)"
'    theme.GridScreenDescriptionLowerRightBorderSD   = "(17,23)"
'    theme.GridScreenDescriptionBackFillSizeSD       = "(0x0)" ' disable backfill
    
'    ' List Screen
'    theme.ListItemHighlightSD                       = "pkg:/images/list_button_sd.png"
'    theme.ListItemHighlightHD                       = "pkg:/images/list_button_hd.png"
'        
    theme.ListItemText                              = "#9D9D9D"
    theme.ListItemHighlightText                     = "#FFFFFF"
    theme.ListScreenDescriptionText                 = "#CCCCCC"
    theme.ListScreenHeaderText                      = "#CACACA"

    theme.SpringboardTitleText                      = "#CACACA"
    theme.SpringboardActorColor                     = "#CCCCCC"
    theme.SpringboardSynopsisColor                  = "#9D9D9D"
    theme.SpringboardRuntimeColor                   = "#9D9D9D"
    
    theme.RegistrationCodeColor                     = "#FFFFFF"
    theme.RegistrationFocalColor                    = "#FFFFFF"
    theme.ParagraphBodyText                         = "#9D9D9D"


    SetTheme(theme)
End Sub
