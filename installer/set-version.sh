#!/bin/bash
#
# This will set a new version number for the project.
# The *.ver.rc files will be written and compiled into *.res
# within every ../src/<project-name> directory.
#
# The new version number (e.g. 1.2.3) must be passed in $1
#
# windres must exist on the path.

set -e
set -u

IFS='.'
read -ra vi <<< "$1"

echo "1 VERSIONINFO
 FILEVERSION ${vi[0]}, ${vi[1]}, ${vi[2]}, 1
 PRODUCTVERSION ${vi[0]}, ${vi[1]}, ${vi[2]}, 0
 FILEFLAGSMASK 0x3f
 FILEOS 0x40004
 FILETYPE 0x1
{
  BLOCK \"StringFileInfo\"
  {
    BLOCK \"041904E3\"
    {
      VALUE \"Comments\", L\"\x0421 \x0431\x043b\x0430\x0433\x043e\x0434\x0430\x0440\x043d\x043e\x0441\x0442\x044c\x044e \x0414\x043c\x0438\x0442\x0440\x0438\x044e \x0422\x0430\x0440\x0430\x0441\x0435\x0432\x0438\x0447\x0443 \x0438 \x0410\x043d\x043d\x0435 \x041c\x0438\x0445\x0435\x0435\x0432\x043e\x0439\"
      VALUE \"CompanyName\", L\"\x041a\x043e\x043d\x0441\x0442\x0430\x043d\x0442\x0438\x043d \x0417\x0430\x0445\x0430\x0440\x043e\x0432\"
      VALUE \"FileDescription\", L\"\x0421\x0440\x0435\x0434\x0430 \x0440\x0430\x0437\x0440\x0430\x0431\x043e\x0442\x043a\x0438 \x041a\x043b\x0430\x0443\x0441\"
      VALUE \"InternalName\", \"klauside\"
      VALUE \"LegalCopyright\", L\"\x041f\x0440\x043e\x0433\x0440\x0430\x043c\x043c\x0430 \x0440\x0430\x0441\x043f\x0440\x043e\x0441\x0442\x0440\x0430\x043d\x044f\x0435\x0442\x0441\x044f \x0431\x0435\x0441\x043f\x043b\x0430\x0442\x043d\x043e \x043f\x043e \x0421\x0442\x0430\x043d\x0434\x0430\x0440\x0442\x043d\x043e\x0439 \x043e\x0431\x0449\x0435\x0441\x0442\x0432\x0435\x043d\x043d\x043e\x0439 \x043b\x0438\x0446\x0435\x043d\x0437\x0438\x0438 GNU GPLv3 \x0438\x043b\x0438 \x0431\x043e\x043b\x0435\x0435 \x043f\x043e\x0437\x0434\x043d\x0435\x0439 \x0432\x0435\x0440\x0441\x0438\x0438: https://www.gnu.org/licenses/gpl-3.0.html\"
      VALUE \"LegalTrademarks\", L\"\x0420\x0435\x043f\x043e\x0437\x0438\x0442\x043e\x0440\x0438\x0439 \x043f\x0440\x043e\x0435\x043a\x0442\x0430: https://gitflic.ru/project/czaerlag/klauslang\"
      VALUE \"OriginalFilename\", \"klaus-ide\"
      VALUE \"ProductName\", L\"\x041a\x043b\x0430\x0443\x0441\"
      VALUE \"ProductVersion\", \"${vi[0]}.${vi[1]}.${vi[2]}\"
      VALUE \"FileVersion\", \"${vi[0]}.${vi[1]}.${vi[2]}.1\"
    }
  }
  BLOCK \"VarFileInfo\"
  {
    VALUE \"Translation\", 0x419, 1251
  }
}" > ../src/ide/klauside.ver.rc

windres ../src/ide/klauside.ver.rc ../src/ide/klauside.ver.res

echo "1 VERSIONINFO
 FILEVERSION ${vi[0]}, ${vi[1]}, ${vi[2]}, 1
 PRODUCTVERSION ${vi[0]}, ${vi[1]}, ${vi[2]}, 0
 FILEFLAGSMASK 0x3f
 FILEOS 0x40004
 FILETYPE 0x1
{
  BLOCK \"StringFileInfo\"
  {
    BLOCK \"041904E3\"
    {
      VALUE \"Comments\", L\"\x0421 \x0431\x043b\x0430\x0433\x043e\x0434\x0430\x0440\x043d\x043e\x0441\x0442\x044c\x044e \x0414\x043c\x0438\x0442\x0440\x0438\x044e \x0422\x0430\x0440\x0430\x0441\x0435\x0432\x0438\x0447\x0443 \x0438 \x0410\x043d\x043d\x0435 \x041c\x0438\x0445\x0435\x0435\x0432\x043e\x0439\"
      VALUE \"CompanyName\", L\"\x041a\x043e\x043d\x0441\x0442\x0430\x043d\x0442\x0438\x043d \x0417\x0430\x0445\x0430\x0440\x043e\x0432\"
      VALUE \"FileDescription\", L\"\x0418\x043d\x0442\x0435\x0440\x043f\x0440\x0435\x0442\x0430\x0442\x043e\x0440 \x041a\x043b\x0430\x0443\x0441\"
      VALUE \"InternalName\", \"klauscon\"
      VALUE \"LegalCopyright\", L\"\x041f\x0440\x043e\x0433\x0440\x0430\x043c\x043c\x0430 \x0440\x0430\x0441\x043f\x0440\x043e\x0441\x0442\x0440\x0430\x043d\x044f\x0435\x0442\x0441\x044f \x0431\x0435\x0441\x043f\x043b\x0430\x0442\x043d\x043e \x043f\x043e \x0421\x0442\x0430\x043d\x0434\x0430\x0440\x0442\x043d\x043e\x0439 \x043e\x0431\x0449\x0435\x0441\x0442\x0432\x0435\x043d\x043d\x043e\x0439 \x043b\x0438\x0446\x0435\x043d\x0437\x0438\x0438 GNU GPLv3 \x0438\x043b\x0438 \x0431\x043e\x043b\x0435\x0435 \x043f\x043e\x0437\x0434\x043d\x0435\x0439 \x0432\x0435\x0440\x0441\x0438\x0438: https://www.gnu.org/licenses/gpl-3.0.html\"
      VALUE \"LegalTrademarks\", L\"\x0420\x0435\x043f\x043e\x0437\x0438\x0442\x043e\x0440\x0438\x0439 \x043f\x0440\x043e\x0435\x043a\x0442\x0430: https://gitflic.ru/project/czaerlag/klauslang\"
      VALUE \"OriginalFilename\", \"klaus\"
      VALUE \"ProductName\", L\"\x041a\x043b\x0430\x0443\x0441\"
      VALUE \"ProductVersion\", \"${vi[0]}.${vi[1]}.${vi[2]}\"
      VALUE \"FileVersion\", \"${vi[0]}.${vi[1]}.${vi[2]}.1\"
    }
  }
  BLOCK \"VarFileInfo\"
  {
    VALUE \"Translation\", 0x419, 1251
  }
}" > ../src/klaus/klauscon.ver.rc

windres ../src/klaus/klauscon.ver.rc ../src/klaus/klauscon.ver.res

echo "1 VERSIONINFO
 FILEVERSION ${vi[0]}, ${vi[1]}, ${vi[2]}, 1
 PRODUCTVERSION ${vi[0]}, ${vi[1]}, ${vi[2]}, 0
 FILEFLAGSMASK 0x3f
 FILEOS 0x40004
 FILETYPE 0x1
{
  BLOCK \"StringFileInfo\"
  {
    BLOCK \"041904E3\"
    {
      VALUE \"Comments\", L\"\x0421 \x0431\x043b\x0430\x0433\x043e\x0434\x0430\x0440\x043d\x043e\x0441\x0442\x044c\x044e \x0414\x043c\x0438\x0442\x0440\x0438\x044e \x0422\x0430\x0440\x0430\x0441\x0435\x0432\x0438\x0447\x0443 \x0438 \x0410\x043d\x043d\x0435 \x041c\x0438\x0445\x0435\x0435\x0432\x043e\x0439\"
      VALUE \"CompanyName\", L\"\x041a\x043e\x043d\x0441\x0442\x0430\x043d\x0442\x0438\x043d \x0417\x0430\x0445\x0430\x0440\x043e\x0432\"
      VALUE \"FileDescription\", L\"\x0420\x0435\x0434\x0430\x043a\x0442\x043e\x0440 \x043f\x0440\x0430\x043a\x0442\x0438\x043a\x0443\x043c\x0430 \x041a\x043b\x0430\x0443\x0441\"
      VALUE \"InternalName\", \"klauscourseedit\"
      VALUE \"LegalCopyright\", L\"\x041f\x0440\x043e\x0433\x0440\x0430\x043c\x043c\x0430 \x0440\x0430\x0441\x043f\x0440\x043e\x0441\x0442\x0440\x0430\x043d\x044f\x0435\x0442\x0441\x044f \x0431\x0435\x0441\x043f\x043b\x0430\x0442\x043d\x043e \x043f\x043e \x0421\x0442\x0430\x043d\x0434\x0430\x0440\x0442\x043d\x043e\x0439 \x043e\x0431\x0449\x0435\x0441\x0442\x0432\x0435\x043d\x043d\x043e\x0439 \x043b\x0438\x0446\x0435\x043d\x0437\x0438\x0438 GNU GPLv3 \x0438\x043b\x0438 \x0431\x043e\x043b\x0435\x0435 \x043f\x043e\x0437\x0434\x043d\x0435\x0439 \x0432\x0435\x0440\x0441\x0438\x0438: https://www.gnu.org/licenses/gpl-3.0.html\"
      VALUE \"LegalTrademarks\", L\"\x0420\x0435\x043f\x043e\x0437\x0438\x0442\x043e\x0440\x0438\x0439 \x043f\x0440\x043e\x0435\x043a\x0442\x0430: https://gitflic.ru/project/czaerlag/klauslang\"
      VALUE \"OriginalFilename\", \"klaus-course-edit\"
      VALUE \"ProductName\", L\"\x041a\x043b\x0430\x0443\x0441\"
      VALUE \"ProductVersion\", \"${vi[0]}.${vi[1]}.${vi[2]}\"
      VALUE \"FileVersion\", \"${vi[0]}.${vi[1]}.${vi[2]}.1\"
    }
  }
  BLOCK \"VarFileInfo\"
  {
    VALUE \"Translation\", 0x419, 1251
  }
}" > ../src/course-edit/klauscourseedit.ver.rc

windres ../src/course-edit/klauscourseedit.ver.rc ../src/course-edit/klauscourseedit.ver.res

echo "${vi[0]}.${vi[1]}.${vi[2]}" | tr -d '\n' > ../src/ver
