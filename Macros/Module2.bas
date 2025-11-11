Attribute VB_Name = "Module2"
Sub ToggleDemurrageSchedule()
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("Demurrage Schedule")
    On Error GoTo 0

    If ws Is Nothing Then
        MsgBox "The 'Demurrage Schedule' worksheet was not found.", vbExclamation
        Exit Sub
    End If

    If ws.Visible = xlSheetVisible Then
        ws.Visible = xlSheetHidden
    Else
        ws.Visible = xlSheetVisible
        ws.Activate
    End If
End Sub
