Attribute VB_Name = "Module5"
Sub AutoFitColumnsAndRows_RemoveFilters_PositionButtons()
    Dim ws As Worksheet
    Dim shp As Shape
    Dim lastCol As Long
    Dim lastRow As Long
    Dim tbl As ListObject
    Dim targetLeft As Double, targetTop As Double, targetHeight As Double
    Dim targetGroup As Shape

    ' Set the worksheet
    Set ws = ThisWorkbook.Sheets("Tracking Report") ' Adjust if needed

    ' Remove filters from Table1 if it exists
    On Error Resume Next
    Set tbl = ws.ListObjects("Table1")
    On Error GoTo 0

    If Not tbl Is Nothing Then
        On Error Resume Next
        If tbl.ShowAutoFilter Then
            tbl.AutoFilter.ShowAllData ' Clears filters
        End If
        On Error GoTo 0
    End If

    ' Autofit used columns and rows
    On Error Resume Next
    lastCol = ws.Cells.Find(What:="*", SearchOrder:=xlByColumns, SearchDirection:=xlPrevious).Column
    lastRow = ws.Cells.Find(What:="*", SearchOrder:=xlByRows, SearchDirection:=xlPrevious).row
    On Error GoTo 0

    If lastCol > 0 Then
        ws.Columns("A:" & Split(ws.Cells(1, lastCol).Address, "$")(1)).AutoFit
    End If

    If lastRow > 0 Then
        ws.Rows("1:" & lastRow).AutoFit
    End If

    ' Find the shape group (assumes there's only one group)
    For Each shp In ws.Shapes
        If shp.Type = msoGroup Then
            Set targetGroup = shp
            Exit For
        End If
    Next shp

    ' Dynamically reposition the grouped buttons to align with Column K and Rows 2–8
    If Not targetGroup Is Nothing Then
        With ws
            targetLeft = .Columns("K").Left
            targetTop = .Rows("3").Top
            targetHeight = .Rows("3:7").Height

            With targetGroup
                .Top = targetTop
                .Left = targetLeft
                .Height = targetHeight
                .Placement = xlFreeFloating ' Avoid resizing/moving unexpectedly
            End With
        End With
    End If

    MsgBox "Filters cleared, layout autofit, and grouped buttons repositioned to Column K.", vbInformation
End Sub

