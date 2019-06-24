'IMPORTS=utilities/general utilities/strings
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' Date / Time
'=====================
Function GetDurationString(totalSeconds = 0 As Integer, skipSeconds = False As Boolean, calcDays = True As Boolean, secondsString = "s" As String, minutesString = "m " As String, hoursString = "h " As String, daysString = "d " As String, secondString = secondsString As String, minuteString = minutesString As String, hourString = hoursString As String, dayString = daysString As String) As String
    remaining = totalSeconds
    days = "0"
    If calcDays Then
        days = Int(remaining / 86400).ToStr()
        remaining = remaining Mod 86400
    End If
    hours = Int(remaining / 3600).ToStr()
    remaining = remaining Mod 3600
    minutes = Int(remaining / 60).ToStr()
    remaining = remaining Mod 60
    seconds = remaining.ToStr()
    
    duration = ""
    If days <> "0" Then
        duration = duration + days
        If days = "1" Then
            duration = duration + dayString
        Else
            duration = duration + daysString
        End If
    End If
    If hours <> "0" Then
        duration = duration + hours
        If hours = "1" Then
            duration = duration + hourString
        Else
            duration = duration + hoursString
        End If
    End If
    If minutes <> "0" Then 'Or hours <> "0" Or days <> "0" Then
        duration = duration + minutes
        If minutes = "1" Then
            duration = duration + minuteString
        Else
            duration = duration + minutesString
        End If
    End If
    If Not skipSeconds And (seconds <> "0" Or minutes <> "0" Or hours <> "0" Or days <> "0") Then
        duration = duration + seconds
        If seconds = "1" Then
            duration = duration + secondString
        Else
            duration = duration + secondsString
        End If
    End If
    
    Return duration.Trim()
End Function

Function GetDurationStringStandard(totalSeconds = 0 As Integer, pad = True As Boolean) As String
    remaining = totalSeconds
    hours = Int(remaining / 3600).ToStr()
    remaining = remaining Mod 3600
    minutes = Int(remaining / 60).ToStr()
    remaining = remaining Mod 60
    seconds = remaining.ToStr()

    If hours <> "0" Then
        Return IIf(pad, PadLeft(hours, "0", 2), hours) + ":" + PadLeft(minutes, "0", 2) + ":" + PadLeft(seconds, "0", 2)
    Else
        Return IIf(pad, PadLeft(minutes, "0", 2), minutes) + ":" + PadLeft(seconds, "0", 2)
    End If
End Function

Function NowDate() As Object
    Return CreateObject("roDateTime")
End Function

Function LocalNowDate() As Object
    now = NowDate()
    now.ToLocalTime()
    Return now
End Function

Function GetShortDateString(dateTime As Object) As String
    dateString = dateTime.AsDateString("short-month")
    ' Trim the day
    dateString = dateString.Mid(dateString.InStr(" ") + 1)
    Return dateString
End Function

Function GetTimeString(dateTime As Object, format12 = True As Boolean, padDigits = False As Boolean, includeAmPm = True As Boolean, am = " am" as string, pm = " pm" as string) As String
    time = ""
    hours = dateTime.GetHours()
    ampm = IIf(includeAmPm, am, "")
    If hours >= 12 And format12 Then
        hours = hours - 12
        ampm = IIf(includeAmPm, pm, "")
    End If
    If hours = 0 And format12 Then
        hours = 12
    End If
    time = IIf(padDigits, PadLeft(hours.ToStr(), "0", 2), hours.ToStr())
    time = time + ":"
    time = time + PadLeft(dateTime.GetMinutes().ToStr(), "0", 2)
    If format12 Then
        time = time + ampm
    End If
    Return time
End Function

Function DateAsSeconds(date = NowDate() As Object) As Integer
    Return date.AsSeconds()
End Function

Function DateAsMilliseconds(date = NowDate() As Object) As Double
    seconds# = date.AsSeconds()
    Return seconds# * 1000 + date.GetMilliseconds()
End Function

Function DateFromSeconds(seconds As Integer) As Object
    date = CreateObject("roDateTime")
    date.FromSeconds(seconds)
    Return date
End Function

Function DateFromString(dateString As Object) As Object
    If IsDateTime(dateString) Then
        Return dateString
    End If
    iso8601String = dateString
    regex = CreateObject("roRegex", "(?:(\d{1,2})[-/](\d{1,2})[-/](\d{4}))(?:\s?(\d{1,2})\:(\d{2})(?:\:(\d{2}))?\s?(AM|PM)?)?", "i")
    If regex.IsMatch(dateString) Then
        match = regex.Match(dateString)
        iso8601String = match[3] + "-" + PadLeft(match[1], "0", 2) + "-" + PadLeft(match[2], "0", 2) + "T" + PadLeft(match[4], "0", 2) + ":" + PadLeft(match[5], "0", 2) + ":" + PadLeft(match[6], "0", 2)
    End If
    Return DateFromISO8601String(iso8601String)
End Function

Function DateFromISO8601String(iso8601String As Object) As Object
    If IsDateTime(iso8601String) Then
        Return iso8601String
    End If
    If IsNullOrEmpty(iso8601String) Or Not IsString(iso8601String) Then
        iso8601String = "0"
    End If
'    If iso8601String.InStr(".") > 0 Then
'        regex = CreateObject("roRegex", "(\.\d{3})", "i")
'        iso8601String = regex.ReplaceAll(iso8601String, "")
'    End If
    date = CreateObject("roDateTime")
    date.FromISO8601String(iso8601String)
    Return date
End Function

Function DateToISO8601String(date = NowDate() As Object, includeMilliseconds = False As Boolean, includeZ = True As Boolean, encodeColons = False As Boolean) As String
    iso8601 =           PadLeft(date.GetYear().ToStr(), "0", 4)
    iso8601 = iso8601 + "-"
    iso8601 = iso8601 + PadLeft(date.GetMonth().ToStr(), "0", 2)
    iso8601 = iso8601 + "-"
    iso8601 = iso8601 + PadLeft(date.GetDayOfMonth().ToStr(), "0", 2)
    iso8601 = iso8601 + "T"
    iso8601 = iso8601 + PadLeft(date.GetHours().ToStr(), "0", 2)
    iso8601 = iso8601 + IIf(encodeColons, "%3A", ":")
    iso8601 = iso8601 + PadLeft(date.GetMinutes().ToStr(), "0", 2)
    iso8601 = iso8601 + IIf(encodeColons, "%3A", ":")
    iso8601 = iso8601 + PadLeft(date.GetSeconds().ToStr(), "0", 2)
    If includeMilliseconds Then
        iso8601 = iso8601 + "."
        iso8601 = iso8601 + PadLeft(date.GetMilliseconds().ToStr(), "0", 3)
    End If
    If includeZ Then
        iso8601 = iso8601 + "Z"
    End If
    Return iso8601
End Function

Sub SetTime(date As Object, time = "00:00:00" As String)
    milliseconds = "000"
    millis = time.InStr(".")
    If millis = -1 Then
        millis = time.InStr(",")
    End If
    If millis > -1 Then
        milliseconds = time.Mid(millis + 1)
        time = time.Mid(0, millis)
    End If
    time = PadLeft(time, "00:", 8)
    time = time + "." + milliseconds

    iso8601 = PadLeft(date.GetYear().ToStr(), "0", 4)
    iso8601 = iso8601 + "-"
    iso8601 = iso8601 + PadLeft(date.GetMonth().ToStr(), "0", 2)
    iso8601 = iso8601 + "-"
    iso8601 = iso8601 + PadLeft(date.GetDayOfMonth().ToStr(), "0", 2)
    iso8601 = iso8601 + "T" + time

    date.FromISO8601String(iso8601)
End Sub

Function AddSeconds(date As Object, seconds As Integer) As Object
    newDate = CreateObject("roDateTime")
    newDate.FromSeconds(date.AsSeconds() + seconds)
    Return newDate
End Function

Function GetTodaySeconds() As Integer
    now = NowDate()
    now.ToLocalTime()
    seconds = now.GetHours() * 60 * 60
    seconds = seconds + now.GetMinutes() * 60
    seconds = seconds + now.GetSeconds()
    Return seconds
End Function

Function GetTotalSecondsFromTime(time = "00:00:00" As Dynamic, roundUp = False As Boolean) As Integer
    If Not IsNullOrEmpty(time) Then
        date = CreateObject("roDateTime")
        date.FromSeconds(0)
        SetTime(date, time)
        seconds = date.AsSeconds()
        If roundUp And date.GetMilliseconds() > 0 Then
            seconds = seconds + 1
        End If
        Return seconds
    Else
        Return 0
    End If
End Function

Function GetStartDateOfWeek(dateTime As Object) As Object
    startDate = CreateObject("roDateTime")
    startDate.FromSeconds(dateTime.AsSeconds())
    
    daySeconds = 60 * 60 * 24
    weekday = dateTime.GetWeekday()
    If weekday = "Monday" Then
        startDate.FromSeconds(dateTime.AsSeconds() - daySeconds)
    Else If weekday = "Tuesday" Then
        startDate.FromSeconds(dateTime.AsSeconds() - (daySeconds * 2))
    Else If weekday = "Wednesday" Then
        startDate.FromSeconds(dateTime.AsSeconds() - (daySeconds * 3))
    Else If weekday = "Thursday" Then
        startDate.FromSeconds(dateTime.AsSeconds() - (daySeconds * 4))
    Else If weekday = "Friday" Then
        startDate.FromSeconds(dateTime.AsSeconds() - (daySeconds * 5))
    Else If weekday = "Saturday" Then
        startDate.FromSeconds(dateTime.AsSeconds() - (daySeconds * 6))
    End If
    Return startDate
End Function

Function GetEndDateOfWeek(dateTime As Object) As Object
    endDate = CreateObject("roDateTime")
    endDate.FromSeconds(dateTime.AsSeconds())
    
    daySeconds = 60 * 60 * 24
    weekday = dateTime.GetWeekday()
    If weekday = "Sunday" Then
        endDate.FromSeconds(dateTime.AsSeconds() + (daySeconds * 6))
    Else If weekday = "Monday" Then
        endDate.FromSeconds(dateTime.AsSeconds() + (daySeconds * 5))
    Else If weekday = "Tuesday" Then
        endDate.FromSeconds(dateTime.AsSeconds() + (daySeconds * 4))
    Else If weekday = "Wednesday" Then
        endDate.FromSeconds(dateTime.AsSeconds() + (daySeconds * 3))
    Else If weekday = "Thursday" Then
        endDate.FromSeconds(dateTime.AsSeconds() + (daySeconds * 2))
    Else If weekday = "Friday" Then
        endDate.FromSeconds(dateTime.AsSeconds() + (daySeconds * 1))
    End If
    Return endDate
End Function

Function GetDayOfYear(date = NowDate() As Object) As Integer
    firstDay = CreateObject("roDateTime")
    firstDay.FromISO8601String(date.GetYear().ToStr() + "-01-01T00:00:00")
    totalSeconds = date.AsSeconds() - firstDay.AsSeconds()
    Return Int(totalSeconds / 60 / 60 / 24) + 1
End Function

' 0=Sunday
Function GetDayOfWeek(date As Object) As Integer
    daysFromEpoch = Int(date.AsSeconds() / 86400) + 1
    day = (daysFromEpoch Mod 7) - 4 'epoch is a Thursday (4)
    If day < 0 Then
        day = day + 7
    End If
    Return day
End Function

Function IsDaylightSavingsTime() As Boolean
    'Starting in 2007, most of the United States and Canada observe DST from the second Sunday in March to the first Sunday in November
    now = NowDate()
    now.ToLocalTime()
    
    month = now.GetMonth()
    day = now.GetDayOfMonth()
    dayOfWeek = GetDayOfWeek(now)
    hour = now.GetHours()
    
    If month < 3 Or month > 11 Then
        Return False
    Else If month > 3 And month < 11 Then
        Return True
    Else If month = 3 Then
        If day < 8 Then         ' 8th is the earliest the second Sunday could be
            Return False
        Else If day > 14 Then   ' 14th is the latest the second Sunday could be
            Return True
        Else If dayOfWeek = 0 Then
            Return hour >= 2
        Else
            Return day > dayOfWeek + 7
        End If
    Else' November
        If day > 7 Then         ' 7th is the earliest the first Sunday could be
            Return False
        Else If dayOfWeek = 0 Then
            Return hour < 2
        Else
            Return day <= dayOfWeek
        End If
    End If
End Function

Function IsLeapYear(year = NowDate().GetYear()) As Boolean
    If year Mod 4 = 0 Then
        If year Mod 100 = 0 Then
            Return (year Mod 400 = 0)
        End If
        Return True
    End If
    Return False
End Function
