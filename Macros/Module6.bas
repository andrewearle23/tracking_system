Attribute VB_Name = "Module6"
Sub RefreshDataAndGenerateEmailPrompt()
    Dim wb As Workbook
    Dim conn As WorkbookConnection
    Dim lo As ListObject
    Dim ws As Worksheet
    Dim qt As QueryTable
    Dim dataSheet As Worksheet
    Dim password As String

    Set wb = ThisWorkbook
    Set ws = wb.Sheets("Group Summary")
    password = "Track"

    ' --- Unprotect Data Validation sheet if protected ---
    On Error Resume Next
    Set dataSheet = wb.Sheets("Data Validation")
    If Not dataSheet Is Nothing Then
        If dataSheet.ProtectContents Then
            dataSheet.Unprotect password:=password
        End If
    End If
    On Error GoTo 0

    ' --- Refresh all workbook connections ---
    On Error Resume Next
    For Each conn In wb.Connections
        conn.OLEDBConnection.BackgroundQuery = False ' force sync refresh
        conn.Refresh
    Next conn
    On Error GoTo 0

    ' --- Refresh all QueryTables and ListObject QueryTables on Group Summary ---
    On Error Resume Next
    For Each qt In ws.QueryTables
        qt.Refresh BackgroundQuery:=False
    Next qt

    For Each lo In ws.ListObjects
        If Not lo.QueryTable Is Nothing Then
            lo.QueryTable.BackgroundQuery = False
            lo.QueryTable.Refresh BackgroundQuery:=False
        End If
    Next lo
    On Error GoTo 0

    ' --- Wait for refreshes to complete ---
    Application.StatusBar = "Waiting for data to refresh..."
    Application.CalculateUntilAsyncQueriesDone
    Application.Wait Now + TimeValue("0:00:02") ' 2-second buffer
    Application.StatusBar = False

    ' --- Re-protect Data Validation sheet ---
    On Error Resume Next
    If Not dataSheet Is Nothing Then
        dataSheet.Protect password:=password, UserInterfaceOnly:=True
    End If
    On Error GoTo 0

    ' --- Prompt user to generate the email ---
    If MsgBox("Data refreshed successfully." & vbNewLine & _
              "Would you like to generate the email now?", _
              vbQuestion + vbYesNo, "Generate Email?") = vbYes Then
        GenerateEmail
    Else
        MsgBox "You can generate the email later by running the GenerateEmail macro.", vbInformation
    End If
End Sub


Sub GenerateEmail()
    Dim wb As Workbook
    Dim tempWb As Workbook
    Dim ws As Worksheet
    Dim tempPath As String, cleanFile As String
    Dim mailTo As String, mailCC As String, mailSubject As String, mailPO As String
    Dim outlookApp As Object, outlookMail As Object
    Dim cell As Range
    Dim i As Long
    Dim mailingSheet As Worksheet
    Dim subjectParts As String
    Dim orderTbl As ListObject, groupTbl As ListObject
    Dim htmlBody As String
    Dim links As Variant
    Dim link As Variant

    Set wb = ThisWorkbook
    Set mailingSheet = wb.Sheets("Mailing List")

    ' Ensure Tracking Report sheet exists
    On Error Resume Next
    Set ws = wb.Sheets("Tracking Report")
    On Error GoTo 0
    If ws Is Nothing Then
        MsgBox "Sheet 'Tracking Report' not found.", vbCritical
        Exit Sub
    End If

    ' Copy 'Tracking Report' sheet to a new workbook
    ws.Copy
        Set tempWb = ActiveWorkbook
    Set tempWs = tempWb.Sheets(1) ' FIXED: set the temp worksheet

' Ungroup shapes and remove form control buttons only
Dim shapeItem As Shape
Dim shapeIndex As Long

' Ungroup any grouped shapes
For shapeIndex = tempWs.Shapes.Count To 1 Step -1
    If tempWs.Shapes(shapeIndex).Type = msoGroup Then
        tempWs.Shapes(shapeIndex).Ungroup
    End If
Next shapeIndex

' Delete form control buttons (type 7 = Button)
For shapeIndex = tempWs.Shapes.Count To 1 Step -1
    Set shapeItem = tempWs.Shapes(shapeIndex)
    If shapeItem.Type = msoFormControl Then
        If shapeItem.FormControlType = xlButtonControl Then
            shapeItem.Delete
        End If
    End If
Next shapeIndex

    ' Remove specific columns from Table1
    On Error Resume Next
    Set tbl = tempWs.ListObjects("Table1")
    If Not tbl Is Nothing Then
        For i = tbl.ListColumns.Count To 1 Step -1
            colName = tbl.ListColumns(i).Name
            If colName = "Date: POD's Received" Or colName = "POD Status" Then
                tbl.ListColumns(i).Delete
            End If
        Next i
    End If
    On Error GoTo 0

    ' Break all external links in the temp workbook
    links = tempWb.LinkSources(Type:=xlLinkTypeExcelLinks)
    If Not IsEmpty(links) Then
        Application.DisplayAlerts = False
        For Each link In links
            tempWb.BreakLink Name:=link, Type:=xlLinkTypeExcelLinks
        Next link
        Application.DisplayAlerts = True
    End If

    ' Save as clean .xlsx file (no macros, only Tracking Report)
    tempPath = Environ$("temp") & "\"
    cleanFile = tempPath & "Tracking_Report_" & Format(Now, "yyyymmdd_hhmmss") & ".xlsx"
    Application.DisplayAlerts = False
    tempWb.SaveAs Filename:=cleanFile, FileFormat:=xlOpenXMLWorkbook
    tempWb.Close False
    Application.DisplayAlerts = True

    ' Build mailing list
    On Error Resume Next
    For Each cell In mailingSheet.ListObjects("Mail_List").ListColumns(1).DataBodyRange
        If Trim(cell.Value) <> "" Then mailTo = mailTo & cell.Value & ";"
    Next cell
    For Each cell In mailingSheet.ListObjects("IMail_List").ListColumns(1).DataBodyRange
        If Trim(cell.Value) <> "" Then mailCC = mailCC & cell.Value & ";"
    Next cell
    On Error GoTo 0

For i = 3 To 8
    If Not IsError(mailingSheet.Range("F" & i).Value) Then
        If VarType(mailingSheet.Range("F" & i).Value) = vbString Or _
           VarType(mailingSheet.Range("F" & i).Value) = vbVariant Then
            If Trim(mailingSheet.Range("F" & i).Value) <> "" Then
                subjectParts = subjectParts & mailingSheet.Range("F" & i).Value & " - "
            End If
        End If
    End If
Next i

    If Right(subjectParts, 3) = " - " Then subjectParts = Left(subjectParts, Len(subjectParts) - 3)
    mailSubject = subjectParts

    mailPO = mailingSheet.Range("F5").Value

    ' Build the body using Order_Summary and Group_Summary tables
    Set orderTbl = wb.Sheets("Group Summary").ListObjects("Order_Summary")
    Set groupTbl = wb.Sheets("Group Summary").ListObjects("Group_Summary")

    htmlBody = "<html><body style='font-family:Calibri Light; font-size:11pt;'>" & _
               "<p>Good day All,<br><br>" & _
               "Please see attached the updated tracking report for PO <b>" & mailPO & "</b>, summarised below:</p>"

        htmlBody = htmlBody & TableToHTML(orderTbl) & "<br><br>" & TableToHTML(groupTbl)

    ' Check Demurrage table
    Dim demurrageTbl As ListObject
    Dim demRow As ListRow
    Dim demColIndex As Long
    Dim hasDemurrage As Boolean

    On Error Resume Next
    Set demurrageTbl = wb.Sheets("Demurrage Schedule").ListObjects("Demurrage_Schedule")
    On Error GoTo 0

    If Not demurrageTbl Is Nothing Then
        ' Find the column number for "Demurrage"
        For i = 1 To demurrageTbl.ListColumns.Count
            If Trim(demurrageTbl.ListColumns(i).Name) = "Demurrage" Then
                demColIndex = i
                Exit For
            End If
        Next i

        ' Loop rows to check for any demurrage > 0
        For Each demRow In demurrageTbl.ListRows
            If IsNumeric(demRow.Range.Cells(1, demColIndex).Value) Then
                If demRow.Range.Cells(1, demColIndex).Value > 0 Then
                    hasDemurrage = True
                    Exit For
                End If
            End If
        Next demRow
    End If

    ' If any demurrage exists, add it to email
    If hasDemurrage Then
        htmlBody = htmlBody & "<br><br><p><b>Please take note of the following standing time charges:</b></p>" & _
                   TableToHTML(demurrageTbl)
    End If

    htmlBody = htmlBody & "</body></html>"


    ' Create Outlook mail
    Set outlookApp = CreateObject("Outlook.Application")
    Set outlookMail = outlookApp.CreateItem(0)

    With outlookMail
        .To = mailTo
        .CC = mailCC
        .Subject = mailSubject
        .htmlBody = htmlBody
        .Attachments.Add cleanFile
        .Display
    End With
    
    outlookApp.ActiveWindow.WindowState = 2
    outlookApp.ActiveWindow.Activate

    MsgBox "Tracking Report Email ready to go, please check all in order before sending off.", vbInformation
    
    ' ? Re-enable worksheet events in case they were disabled earlier
    Application.EnableEvents = True
End Sub


Function TableToHTML(tbl As ListObject) As String
    Dim html As String
    Dim row As ListRow
    Dim col As ListColumn
    Dim r As Range
    Dim i As Long
    Dim demurrageTotal As Double
    Dim demColIndex As Long
    Dim hasDemurrageCol As Boolean

    html = "<table border='1' cellpadding='5' cellspacing='0' " & _
           "style='border-collapse:collapse; font-family:Calibri Light; font-size:11pt;'>"

    ' Header with color
    html = html & "<tr style='background-color:#00AEEF; color:white;'>"
    For i = 1 To tbl.ListColumns.Count
        html = html & "<th>" & tbl.ListColumns(i).Name & "</th>"
        If Trim(tbl.ListColumns(i).Name) = "Demurrage" Then
            demColIndex = i
            hasDemurrageCol = True
        End If
    Next i
    html = html & "</tr>"

    ' Data rows
    For Each row In tbl.ListRows
        html = html & "<tr>"
        For i = 1 To tbl.ListColumns.Count
            Set r = row.Range.Cells(1, i)
            html = html & "<td>" & r.Text & "</td>"

            ' Sum demurrage if numeric
            If hasDemurrageCol And i = demColIndex Then
                If IsNumeric(r.Value) Then
                    demurrageTotal = demurrageTotal + r.Value
                End If
            End If
        Next i
        html = html & "</tr>"
    Next row

    ' Subtotal row
    If hasDemurrageCol And demurrageTotal > 0 Then
        html = html & "<tr style='font-weight:bold;'>"
        For i = 1 To tbl.ListColumns.Count
            If i = demColIndex Then
                html = html & "<td>USD " & Format(demurrageTotal, "#,##0.00") & "</td>"
            ElseIf i = 1 Then
                html = html & "<td>Total Demurrage:</td>"
            Else
                html = html & "<td></td>"
            End If
        Next i
        html = html & "</tr>"
    End If

    html = html & "</table>"

    TableToHTML = html
End Function
