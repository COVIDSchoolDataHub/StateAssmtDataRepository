Attribute VB_Name = "Module3"
Sub AdjustSheets()
    Dim ws As Worksheet
    Dim aValue As String
    
    For Each ws In ThisWorkbook.Worksheets
        ' Store the value in cell A2
        aValue = ws.Range("A2").Value
        
        ' Insert a new column at column A
        ws.Columns(1).Insert Shift:=xlToRight, CopyOrigin:=xlFormatFromLeftOrAbove
        
        ' Set the header for the new column
        ws.Range("A1:A3").Value = "Subject"
        
        ' Copy the value into the new column (from fourth row to the end of the sheet)
        ws.Range("A4:A" & ws.Cells(ws.Rows.count, "B").End(xlUp).Row).Value = aValue
        
        ' Delete the first three rows
        ws.Rows("1:3").Delete Shift:=xlUp
    Next ws
End Sub

