Attribute VB_Name = "Module5"
Sub AppendSheets()

    Dim ws As Worksheet
    Dim wsMaster As Worksheet
    Dim LastRowMaster As Long
    Dim CopyRange As Range

    'Set the master sheet (where all data is appended)
    Set wsMaster = ThisWorkbook.Sheets(1)

    'Loop through all worksheets in the workbook
    For Each ws In ThisWorkbook.Worksheets

        'Avoid copying the master sheet onto itself
        If ws.Name <> wsMaster.Name Then

            'Find the last row of the master sheet
            LastRowMaster = wsMaster.Cells(wsMaster.Rows.count, "A").End(xlUp).Row

            'Set the range you want to copy (without headers)
            Set CopyRange = ws.Range("A2", LastCell(ws))

            'Copy the set range to the master sheet, starting from the last empty row
            CopyRange.Copy wsMaster.Cells(LastRowMaster + 1, 1)

        End If

    Next ws

End Sub

Function LastCell(ws As Worksheet) As Range
    Dim LastRow As Long, LastCol As Integer
    On Error Resume Next
    LastRow = ws.Cells.Find(What:="*", _
                            After:=ws.Range("A1"), _
                            Lookat:=xlPart, _
                            LookIn:=xlFormulas, _
                            SearchOrder:=xlByRows, _
                            SearchDirection:=xlPrevious, _
                            MatchCase:=False).Row
    LastCol = ws.Cells.Find(What:="*", _
                            After:=ws.Range("A1"), _
                            Lookat:=xlPart, _
                            LookIn:=xlFormulas, _
                            SearchOrder:=xlByColumns, _
                            SearchDirection:=xlPrevious, _
                            MatchCase:=False).Column
    Set LastCell = ws.Cells(LastRow, LastCol)
    On Error GoTo 0
End Function


