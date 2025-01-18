
Release: 1
Name: klauslang
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

%package -n %name-teacher
Summary: Klaus training course editor
Summary(ru_RU.UTF-8): Клаус - редактор учебных курсов
Group: Education
Requires: klauslang = %version

%description -n %name-teacher
Klaus training course editor - for teachers and methodologists.
Practicum task soultions source code.

%description -n %name-teacher -l ru_RU.UTF-8
Редактор учебных курсов Клаус - для учителей и методистов.
Исходный код решений задач Практикума.

%prep
%setup -c

%build
cd ./installer
./compile.sh Linux
cd ..

%install
cd ./installer
./install.sh klauslang %buildroot
./install.sh klauslang-teacher %buildroot
rm -f %buildroot/usr/bin/klaus
rm -f %buildroot/usr/bin/klaus-ide
rm -f %buildroot/usr/bin/klaus-course-edit
touch %buildroot/usr/bin/klaus
touch %buildroot/usr/bin/klaus-ide
touch %buildroot/usr/bin/klaus-course-edit
cd ..

%files -n %name
/opt/klauslang/amd64/klaus
/opt/klauslang/amd64/klaus-ide
/opt/klauslang/samples/*
/opt/klauslang/test/*
/opt/klauslang/doc/*
/opt/klauslang/practicum/*.klaus-course
/usr/share/applications/klaus-ide.desktop
/usr/share/mime/packages/klauslang-mime.xml
/usr/share/icons/*
/opt/klauslang/what-s-new.txt
%ghost /usr/bin/klaus
%ghost /usr/bin/klaus-ide

%files -n %name-teacher
/opt/klauslang/amd64/klaus-course-edit
/opt/klauslang/practicum/*.zip
/usr/share/applications/klaus-course-edit.desktop
/usr/share/mime/packages/klauslang-teacher-mime.xml
%ghost /usr/bin/klaus-course-edit

%post -n %name
ln -sf /opt/klauslang/amd64/klaus /usr/bin/klaus
ln -sf /opt/klauslang/amd64/klaus-ide /usr/bin/klaus-ide

%post -n %name-teacher
ln -sf /opt/klauslang/amd64/klaus-course-edit /usr/bin/klaus-course-edit
