Attribute VB_Name = "Module1"
Sub AdjustSheets()
    Dim ws As Worksheet
    Dim firstLine As String
    Dim secondLine As String
    Dim lineEnd As Integer
    Dim lineEnd2 As Integer
    
    For Each ws In ThisWorkbook.Worksheets
        ' Find the end of the first line in cell A1
        lineEnd = InStr(ws.Range("A1").Value, Chr(10))
        If lineEnd > 0 Then
            ' If a line end is found, take the first line
            firstLine = Left(ws.Range("A1").Value, lineEnd - 1)
            
            ' Find the end of the second line in cell A1
            lineEnd2 = InStr(lineEnd + 1, ws.Range("A1").Value, Chr(10))
            If lineEnd2 > 0 Then
                ' If a second line end is found, take the second line
                secondLine = Mid(ws.Range("A1").Value, lineEnd + 1, lineEnd2 - lineEnd - 1)
            Else
                ' If no second line end is found, take the remaining cell content
                secondLine = Mid(ws.Range("A1").Value, lineEnd + 1)
            End If
        Else
            ' If no line end is found, take the whole cell content as the first line
            ' And leave the second line empty
            firstLine = ws.Range("A1").Value
            secondLine = ""
        End If
        
        ' Insert two new columns at column A
        ws.Columns("A:B").Insert Shift:=xlToRight, CopyOrigin:=xlFormatFromLeftOrAbove
        
        ' Set the headers for the new columns
        ws.Range("A1:A3").Value = "District"
        ws.Range("B1:B3").Value = "Data"
        
        ' Copy the first and second lines into the new columns (from fourth row to the end of the sheet)
        ws.Range("A4:A" & ws.Cells(ws.Rows.count, "C").End(xlUp).Row).Value = firstLine
        ws.Range("B4:B" & ws.Cells(ws.Rows.count, "C").End(xlUp).Row).Value = secondLine
        
        ' Delete the first two rows
        ws.Rows("1:2").Delete Shift:=xlUp
    Next ws
End Sub

