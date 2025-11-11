Attribute VB_Name = "Module4"
Sub DeleteRowsFromTable1BottomUp()
    Dim tbl As ListObject
    Dim ws As Worksheet
    Dim numRows As Long
    Dim i As Long

    ' Set the worksheet containing the table
    Set ws = ThisWorkbook.Sheets("Tracking Report") ' Change if needed

    ' Set the table
    On Error Resume Next
    Set tbl = ws.ListObjects("Table1")
    On Error GoTo 0

    If tbl Is Nothing Then
        MsgBox "Table 'Table1' not found on the sheet.", vbCritical
        Exit Sub
    End If

    If tbl.ListRows.Count = 0 Then
        MsgBox "There are no rows to delete in Table1.", vbExclamation
        Exit Sub
    End If

    ' Ask user how many rows to delete from the bottom
    On Error GoTo InvalidInput
    numRows = Application.InputBox("How many rows would you like to delete from the bottom of Table1?", Type:=1)
    If numRows <= 0 Then Exit Sub

    If numRows > tbl.ListRows.Count Then
        MsgBox "You are trying to delete more rows than exist in the table.", vbExclamation
        Exit Sub
    End If

    ' Delete rows from bottom up
    For i = tbl.ListRows.Count To tbl.ListRows.Count - numRows + 1 Step -1
        tbl.ListRows(i).Delete
    Next i

    MsgBox numRows & " row(s) deleted from Table1.", vbInformation
    Exit Sub

InvalidInput:
    MsgBox "Please enter a valid number.", vbExclamation
End Sub

