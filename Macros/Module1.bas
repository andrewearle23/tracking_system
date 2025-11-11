Attribute VB_Name = "Module1"
Sub RefreshQueriesWithSheetProtection()
    Dim ws As Worksheet
    Dim sheetToProtect As String
    Dim password As String
    Dim connection As WorkbookConnection

    sheetToProtect = "Data Validation"
    password = "Track"
    
    ' Unprotect the sheet before refresh
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(sheetToProtect)
    If Not ws Is Nothing Then
        If ws.ProtectContents Then
            ws.Unprotect password:=password
        End If
    End If
    On Error GoTo 0
    
    ' Refresh all workbook connections (Power Query)
    For Each connection In ThisWorkbook.Connections
        If connection.Type = xlConnectionTypeOLEDB Or connection.Type = xlConnectionTypeODBC Or connection.Type = xlConnectionTypeWORKSHEET Then
            connection.Refresh
        End If
    Next connection
    
    ' Wait for all queries to complete
    DoEvents
    Application.CalculateUntilAsyncQueriesDone
    
    ' Re-protect the sheet after refresh
    On Error Resume Next
    If Not ws Is Nothing Then
        ws.Protect password:=password, UserInterfaceOnly:=True
    End If
    On Error GoTo 0
    
    MsgBox "All queries refreshed and '" & sheetToProtect & "' re-protected.", vbInformation
End Sub
