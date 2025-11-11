Attribute VB_Name = "Module3"
Sub AddRowsToTable1()
    Dim tbl As ListObject
    Dim ws As Worksheet
    Dim numRows As Long
    Dim i As Long
    Dim newRow As ListRow
    Dim loadColIndex As Long

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

    ' Determine the column index for "Load #"
    loadColIndex = 0
    For i = 1 To tbl.ListColumns.Count
        If tbl.ListColumns(i).Name = "Load #" Then
            loadColIndex = i
            Exit For
        End If
    Next i

    If loadColIndex = 0 Then
        MsgBox "'Load #' column not found in Table1.", vbCritical
        Exit Sub
    End If

    ' Ask user for number of rows to add
    On Error GoTo InvalidInput
    numRows = Application.InputBox("How many rows would you like to add to Table1?", Type:=1)
    If numRows <= 0 Then Exit Sub

    ' Add rows and update "Load #" column
    For i = 1 To numRows
        Set newRow = tbl.ListRows.Add
        newRow.Range(1, loadColIndex).Value = tbl.ListRows.Count ' Update with current row number in the table
    Next i

    MsgBox numRows & " row(s) added to Table1.", vbInformation
    Exit Sub

InvalidInput:
    MsgBox "Please enter a valid number.", vbExclamation
End Sub

