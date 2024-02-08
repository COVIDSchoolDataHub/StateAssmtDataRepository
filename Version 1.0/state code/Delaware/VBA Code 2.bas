Attribute VB_Name = "Module2"
Sub RenameSheets()
    Dim ws As Worksheet
    Dim count As Integer
    
    count = 1
    
    For Each ws In ThisWorkbook.Worksheets
        ws.Name = "Sheet" & count
        count = count + 1
    Next ws
End Sub

