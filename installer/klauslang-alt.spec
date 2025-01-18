Name: klauslang
Version: %_ver
Release: 1
Packager: Konstantin Zakharoff <mail@czaerlag.ru>
Vendor: Konstantin Zakharoff
Summary: Klaus programming language and environment
Summary(ru_RU.UTF-8): Клаус - язык программирования и среда разработки

License: GPLv3+
Url: https://gitflic.ru/project/czaerlag/klauslang
Vcs: https://gitflic.ru/project/czaerlag/klauslang.git
Group: Education

BuildArch: x86_64

# https://gitflic.ru/project/czaerlag/klauslang/file/downloadAll?format=tar.bz2&branch=v%version
Source: %name.tar.bz2

BuildRequires: fpc >= 3.2.2
BuildRequires: fpc-src
BuildRequires: libgtk+2-devel
BuildRequires: lazarus >= 3.4

%description
Klaus is a Russian-based educational programming language,
development environment and a set of training courses
for schoolchildren and students.

%description -l ru_RU.UTF-8
Клаус - язык программирования по-русски, среда разработки
и набор учебных курсов для школьников и студентов.

%prep
%setup -c

%build
cd ./installer
./compile.sh Linux
