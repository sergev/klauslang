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

%description
Klaus is a Russian-based educational programming language,
development environment and a set of training courses
for schoolchildren and students.

%description -l ru_RU.UTF-8
Клаус - язык программирования по-русски, среда разработки
и набор учебных курсов для школьников и студентов.

Source: %url/file/downloadAll?branch=v%_ver&format=tar.bz2

BuildRequires: fpc >= 3.2.2
BuildRequires: fpc-src
BuildRequires: libgtk+2-devel
BuildRequires: lazarus >= 3.4

%prep
rm -rf %buildroot
mkdir %buildroot

mkdir -p %buildroot/opt/klauslang/amd64
cp %_pwd/../compiled/klaus %buildroot/opt/klauslang/amd64/
cp %_pwd/../compiled/klaus-ide %buildroot/opt/klauslang/amd64/

mkdir -p %buildroot/opt/klauslang/samples
cp -r %_pwd/../samples/* %buildroot/opt/klauslang/samples/

mkdir -p %buildroot/opt/klauslang/test
cp -r %_pwd/../test/* %buildroot/opt/klauslang/test/

mkdir -p %buildroot/opt/klauslang/doc
cp -r %_pwd/../doc/* %buildroot/opt/klauslang/doc/

mkdir -p %buildroot/opt/klauslang/practicum
cp -r %_pwd/../practicum/*.klaus-course %buildroot/opt/klauslang/practicum/

mkdir %buildroot/usr
rsync -r %_pwd/../src/assets/klauslang/usr/ %buildroot/usr/

mkdir -p %buildroot/usr/bin
touch %buildroot/usr/bin/klaus
touch %buildroot/usr/bin/klaus-ide

cp %_pwd/../installer/what-s-new.txt %buildroot/opt/klauslang/

%files
/opt/klauslang/amd64/*
/opt/klauslang/samples/*
/opt/klauslang/test/*
/opt/klauslang/doc/*
/opt/klauslang/practicum/*.klaus-course
/usr/*
/opt/klauslang/what-s-new.txt
%ghost /usr/bin/klaus
%ghost /usr/bin/klaus-ide

%post
ln -sf /opt/klauslang/amd64/klaus /usr/bin/klaus
ln -sf /opt/klauslang/amd64/klaus-ide /usr/bin/klaus-ide
