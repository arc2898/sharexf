; ShareXF — Copyright (C) 2026 inukaasith. GPL-3.0, see LICENSE.
; NSIS hooks for electron-builder (installer/build.js). The installer runs elevated (per-machine),
; so it adds the same firewall rules the app's Fix button would (firewall.js), for every network
; profile so a standard account on a Public network never needs Fix; the uninstaller removes them. A helper (or our adb server) left running would lock its .exe, so it is stopped first.
; Stopped while it drove another computer, its pointer would stay blank (HideCursor.cs): the
; user's cursors are reloaded after it (SPI_SETCURSORS, SPIF_SENDCHANGE).

!macro customInit
  nsExec::Exec 'taskkill /f /im sharexf-winhelper.exe'
  nsExec::Exec 'taskkill /f /im sharexf-winhelper-multi.exe'
  nsExec::Exec 'taskkill /f /im sharexf-calls.exe'
  System::Call 'user32::SystemParametersInfoW(i 0x57, i 0, i 0, i 2)'
  nsExec::Exec '"$INSTDIR\resources\app\windows\vendor\adb\adb.exe" kill-server'
!macroend

!macro customUnInit
  nsExec::Exec 'taskkill /f /im sharexf-winhelper.exe'
  nsExec::Exec 'taskkill /f /im sharexf-winhelper-multi.exe'
  nsExec::Exec 'taskkill /f /im sharexf-calls.exe'
  System::Call 'user32::SystemParametersInfoW(i 0x57, i 0, i 0, i 2)'
  nsExec::Exec '"$INSTDIR\resources\app\windows\vendor\adb\adb.exe" kill-server'
!macroend

; In place of electron-builder's "ShareXF is running, close it" check, before the old version's
; uninstaller and the file copy: a running ShareXF is closed rather than asked about, and the old
; app folder goes, so every file is the new version's (none left over from earlier releases).
!macro customCheckAppRunning
  nsExec::Exec 'taskkill /f /t /im ShareXF.exe'
  nsExec::Exec 'taskkill /f /im sharexf-winhelper.exe'
  nsExec::Exec 'taskkill /f /im sharexf-winhelper-multi.exe'
  nsExec::Exec 'taskkill /f /im sharexf-calls.exe'
  System::Call 'user32::SystemParametersInfoW(i 0x57, i 0, i 0, i 2)'
  Sleep 500
  RMDir /r "$INSTDIR\resources\app"
!macroend

!macro customInstall
  ; Renamed from ShareXF: its rules (and its Program Files folder's exe) go.
  nsExec::Exec 'netsh advfirewall firewall delete rule name="ShareXF"'
  nsExec::Exec 'netsh advfirewall firewall delete rule name="ShareXF (TCP 47800)"'
  nsExec::Exec 'netsh advfirewall firewall delete rule name="ShareXF" program="$INSTDIR\ShareXF.exe"'
  nsExec::Exec 'netsh advfirewall firewall add rule name="ShareXF" dir=in action=allow program="$INSTDIR\ShareXF.exe" profile=any enable=yes'
  ; This PC also listens (PC ↔ PC host), so the port gets its own rule.
  nsExec::Exec 'netsh advfirewall firewall delete rule name="ShareXF (TCP 47800)"'
  nsExec::Exec 'netsh advfirewall firewall add rule name="ShareXF (TCP 47800)" dir=in action=allow protocol=TCP localport=47800 program="$INSTDIR\ShareXF.exe" profile=any enable=yes'
  ; A phone: adb finds its wireless debugging over mDNS (phone-bridge.js).
  nsExec::Exec 'netsh advfirewall firewall delete rule name="ShareXF (adb)"'
  nsExec::Exec 'netsh advfirewall firewall add rule name="ShareXF (adb)" dir=in action=allow program="$INSTDIR\resources\app\windows\vendor\adb\adb.exe" profile=any enable=yes'
  ; The phone as a drive goes through Windows' WebDAV client (phonedrive.js), which refuses files
  ; over 50 MB unless this says otherwise: 4 GB, its maximum (read when WebClient next starts).
  nsExec::Exec 'reg add HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters /v FileSizeLimitInBytes /t REG_DWORD /d 4294967295 /f'
  ; Calls on this PC (callaudio.js): Windows adds the calls' sparse package (an identity for
  ; sharexf-calls.exe) only when it trusts its certificate, self-signed: trusted for app packages
  ; only (TrustedPeople, not a root). The app registers the package per user when Calls needs it.
  IfFileExists "$INSTDIR\resources\app\windows-helper\bin\sharexf-calls.cer" 0 +2
  nsExec::Exec 'certutil -f -addstore TrustedPeople "$INSTDIR\resources\app\windows-helper\bin\sharexf-calls.cer"'
!macroend

!macro customUnInstall
  ; Camera › Virtual camera (vcam.js): the camera and its media source, but not on an update (the
  ; new version keeps them, so it needs no administrator prompt again).
  ${ifNot} ${isUpdated}
    nsExec::Exec '"$INSTDIR\resources\app\windows-helper\bin\sharexf-vcam.exe" remove'
    nsExec::Exec 'cmd /c for %f in ("%ProgramData%\ShareXF\vcam\sharexf-vcam-*.dll") do "%SystemRoot%\System32\regsvr32.exe" /u /s "%f"'
    ; $APPDATA for all users: ProgramData
    SetShellVarContext all
    RMDir /r "$APPDATA\ShareXF\vcam"
  ${endIf}
  ; Calls on this PC: its package (this user's) and its certificate.
  nsExec::Exec 'powershell -NoProfile -NonInteractive -Command "Get-AppxPackage -Name ShareXF.Calls | Remove-AppxPackage"'
  nsExec::Exec 'certutil -delstore TrustedPeople ShareXF'
  nsExec::Exec 'netsh advfirewall firewall delete rule name="ShareXF" program="$INSTDIR\ShareXF.exe"'
  nsExec::Exec 'netsh advfirewall firewall delete rule name="ShareXF (TCP 47800)"'
  nsExec::Exec 'netsh advfirewall firewall delete rule name="ShareXF (adb)"'
  ; The pinned Mac apps' Start menu folder is per user (the app makes it in Roaming).
  SetShellVarContext current
  RMDir /r "$APPDATA\Microsoft\Windows\Start Menu\Programs\ShareXF Apps"
  RMDir /r "$APPDATA\Microsoft\Windows\Start Menu\Programs\ShareXF Apps"
  ; Explorer › Send to › "<peer> (ShareXF)" (sendto.js).
  Delete "$APPDATA\Microsoft\Windows\SendTo\* (ShareXF).lnk"
  Delete "$APPDATA\Microsoft\Windows\SendTo\* (ShareXF).lnk"
  ; Explorer's right-click › ShareXF (explorer.js) and the sharexf: links (a toast's Copy)
  DeleteRegKey HKCU "Software\Classes\*\shell\ShareXF"
  DeleteRegKey HKCU "Software\Classes\Directory\shell\ShareXF"
  DeleteRegKey HKCU "Software\Classes\Directory\Background\shell\ShareXF"
  DeleteRegKey HKCU "Software\Classes\sharexf"
  SetShellVarContext all
!macroend
