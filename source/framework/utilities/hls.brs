'IMPORTS=utilities/web
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Function ParseHls(url As String) As Dynamic
    hls = invalid
    m3u8 = GetUrlToString(url)
    If Not IsNullOrEmpty(m3u8) Then
        m3u8 = Replace(m3u8, Chr(13), "")
        m3u8Lines = m3u8.Tokenize(Chr(10))
        startLine = -1
        ' Find the EXTM3U declaration
        For i = 0 To m3u8Lines.Count() - 1
            line = m3u8Lines[i]
            If UCase(line) = "#EXTM3U" Then
                startLine = i
                Exit For
            End If
        Next
        If startLine > -1 Then
            hls = {
                Segments:       []
                Playlists:      []
                Subtitles:      {}
                Metadata:       {}
                TotalDuration:  0
                ' Get the root path by finding the first slash after
                ' skipping at least enough to get past the ://
                RootPath:       url.Mid(0, url.InStr(9, "/"))
            }
            startTime = 0
            For i = startLine + 1 To m3u8Lines.Count() - 1
                line = m3u8Lines[i]
                If line.Mid(0, 1) = "#" Then
                    ' This is a tag line
                    tag = ParseHlsTagLine(line)
                    If tag <> invalid Then
                        If UCase(tag.Tag) = "#EXT-X-STREAM-INF" Then
                            ' This is a pointer to another playlist
                            ' The next line should be the URL
                            i = i + 1
                            tag.Url = m3u8Lines[i]
                            If StartsWith(tag.Url, "/") Then
                                ' Relative path, so prepend the root
                                tag.Url = hls.RootPath + tag.Url
                            End If
                            hls.Playlists.Push(tag)
                        Else If UCase(tag.Tag) = "#EXTINF" Then
                            ' This is a stream segment, capture the data
                            hls.TotalDuration = hls.TotalDuration + tag.Duration
                            ' The next line should be the URL
                            i = i + 1
                            tag.StartTime = startTime
                            tag.Url = m3u8Lines[i]
                            If StartsWith(tag.Url, "/") Then
                                ' Relative path, so prepend the root
                                tag.Url = hls.RootPath + tag.Url
                            End If
                            startTime = startTime + tag.Duration
                            hls.Segments.Push(tag)
                        Else If UCase(tag.Tag) = "#EXT-X-MEDIA" Then
                            groupID = tag["GROUP-ID"]
                            If tag.Type = "SUBTITLES" And Not IsNullOrEmpty(tag.URI) And Not IsNullOrEmpty(tag["GROUP-ID"]) Then
                                hls.Subtitles[groupID] = tag
                            Else If tag.Type = "VIDEO" Then
                                hls.Metadata[groupID] = tag
                            End If
                        Else If UCase(tag.Tag).InStr("#EXT-X") = 0 Then
                            hls.Metadata[tag.Tag] = tag.Value
                        End If 
                    End If
                End If
            Next
        End If
    End If
    Return hls
End Function

Function ParseHlsTagLine(tagLine As String) As Dynamic
    tag = invalid
    If StartsWith(tagLine, "#") Then
        tag = {}
        nameBreak = tagLine.InStr(":")
        If nameBreak = -1 Then
            tag.Tag = tagLine
        Else
            tag.Tag = tagLine.Mid(0, nameBreak)
            tag.Value = tagLine.Mid(nameBreak + 1)
            attributes = tag.Value.Tokenize(",")
            If UCase(tag.Tag) = "#EXTINF" Then
                If attributes.Count() > 0 Then
                    tag.Duration = attributes[0].ToInt()
                End If
                If attributes.Count() > 1 Then
                    tag.Title = Replace(attributes[1], Chr(34), "")
                End If
            Else
                For Each attribute In attributes
                    attribute = attribute.Trim()
                    valueBreak = attribute.InStr("=")
                    If valueBreak = -1 Then
                        tag[attribute] = True
                    Else
                        tag[attribute.Mid(0, valueBreak)] = Replace(attribute.Mid(valueBreak + 1), Chr(34), "")
                    End If
                Next
            End If
        End If
    End If
    Return tag
End Function