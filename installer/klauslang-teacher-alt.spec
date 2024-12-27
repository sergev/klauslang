Name: klauslang-teacher
Version: %_ver
Release: 1
Packager: Konstantin Zakharoff <mail@czaerlag.ru>
Vendor: Konstantin Zakharoff
Summary: Klaus training course editor
Summary(ru_RU.UTF-8): Клаус - редактор учебных курсов

License: GPLv3+
Url: https://gitflic.ru/project/czaerlag/klauslang
Vcs: https://gitflic.ru/project/czaerlag/klauslang.git
Group: Education

BuildArch: x86_64
Requires: klauslang = %_ver

%description
Klaus training course editor - for teachers and methodologists.

%description -l ru_RU.UTF-8
Редактор учебных курсов Клаус - для учителей и методологов.

%prep
rm -rf %buildroot
mkdir %buildroot

mkdir -p %buildroot/opt/klauslang/amd64
cp %_pwd/../compiled/klaus-course-edit %buildroot/opt/klauslang/amd64/

mkdir %buildroot/usr
rsync -r %_pwd/../src/assets/klauslang-teacher/usr/ %buildroot/usr/

mkdir -p %buildroot/usr/bin
touch %buildroot/usr/bin/klaus-course-edit

%files
/opt/klauslang/amd64/*
/usr/*
%ghost /usr/bin/klaus-course-edit

%post
ln -sf /opt/klauslang/amd64/klaus-course-edit /usr/bin/klaus-course-edit
