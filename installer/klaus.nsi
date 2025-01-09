RequestExecutionLevel admin

!define PRODUCT_NAME "�����"
!include "version.nsi"
!define PRODUCT_PUBLISHER "���������� �������"
!define PRODUCT_WEB_SITE "https://gitflic.ru/project/czaerlag/klauslang"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\klaus-ide.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\klauslang"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

!include "FileAssoc.nsh"
!include "WordFunc.nsh"

!include "MUI.nsh"

!define MUI_ABORTWARNING
!define MUI_ICON "..\src\assets\klaus.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\LICENSE.TXT"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\x64\klaus-ide.exe"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Russian"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "..\build\v${PRODUCT_VERSION}\klauslang_${PRODUCT_VERSION}_x64.exe"
InstallDir "$PROGRAMFILES64\klauslang"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" "InstallDir"
ShowInstDetails show
ShowUnInstDetails show

Section "�����" SEC_Main
  SectionInstType RO
  SetShellVarContext all
  
  SetOutPath "$INSTDIR\x64"
  File "..\compiled\klaus.exe"
  File "..\compiled\klaus-ide.exe"

  CreateDirectory "$SMPROGRAMS\�����"
  CreateShortCut "$SMPROGRAMS\�����\�����.lnk" "$INSTDIR\x64\klaus-ide.exe"
  !insertmacro APP_ASSOCIATE "klaus" "klauslang.Source" "�������� ��� �����" \
    "$INSTDIR\x64\klaus-ide.exe,1" "�������" "$INSTDIR\x64\klaus-ide.exe $\"%1$\""

  SetOutPath "$INSTDIR"
  File "what-s-new.txt"

  SetOutPath "$INSTDIR\doc"
  File /r "..\doc\*"
SectionEnd

Section "�������" SEC_Samples
  SetShellVarContext all

  SetOutPath "$INSTDIR\samples"
  File /r "..\samples\*"

  SetOutPath "$INSTDIR\test"
  File /r "..\test\*"
SectionEnd

Section "���������" SEC_Practicum
  SetShellVarContext all

  SetOutPath "$INSTDIR\practicum"
  File /r "..\practicum\*.klaus-course"
SectionEnd

Section /o "�������� ����������" SEC_CourseEdit
  SetShellVarContext all

  SetOutPath "$INSTDIR\x64"
  File "..\compiled\klaus-course-edit.exe"

  SetOutPath "$INSTDIR\practicum"
  File /r "..\practicum\*.zip"

  CreateShortCut "$SMPROGRAMS\�����\�������� ������ �����.lnk" "$INSTDIR\x64\klaus-course-edit.exe"
  !insertmacro APP_ASSOCIATE "klaus-course" "klauslang.TrainingCourse" "������� ���� �����" \
    "$INSTDIR\x64\klaus-course-edit.exe,0" "�������" "$INSTDIR\x64\klaus-course-edit.exe $\"%1$\""
SectionEnd

Section -Post
  SetShellVarContext all
  
  !insertmacro UPDATEFILEASSOC
  
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\x64\klaus-ide.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "InstallDir" "$INSTDIR"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\x64\klaus-ide.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"

  ReadRegStr $R0 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"
  ${WordAdd} $R0 ";" "+$INSTDIR\x64" $R1
  nsExec::Exec 'setx /m PATH "$R1"'
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_Main} "�������� ���������� �����"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_Samples} "������� ��������� ���� � �������� �������"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_Practicum} "�������� ����� �� ���������������� �� ������"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CourseEdit} "�������� ������� ������ ����� � ������� ����� (��� �������� � ����������)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "�������� ��������� $(^Name) ���� ������� ���������."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "�� ������� � ���, ��� ������� ������� $(^Name) � ��� ���������� ���������?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  SetShellVarContext all

  !insertmacro APP_UNASSOCIATE "klaus" "klauslang.Source"
  !insertmacro APP_UNASSOCIATE "klaus-course" "klauslang.TrainingCourse"

  RMDir /r "$SMPROGRAMS\�����"
  Delete "$INSTDIR\what-s-new.txt"
  RMDir /r "$INSTDIR\x64"
  RMDir /r "$INSTDIR\doc"
  RMDir /r "$INSTDIR\samples"
  RMDir /r "$INSTDIR\practicum"
  RMDir /r "$INSTDIR\test"
  Delete "$INSTDIR\uninst.exe"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  !insertmacro UPDATEFILEASSOC
  
  ReadRegStr $R0 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"
  ${WordAdd} $R0 ";" "-$INSTDIR\x64" $R1
  nsExec::Exec 'setx /m PATH "$R1"'
  
  SetAutoClose true
SectionEnd