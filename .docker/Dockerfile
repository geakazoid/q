FROM centos:6.10

COPY ./CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum update -y
RUN yum install -y mysql-devel ImageMagick ImageMagick-devel
RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash
RUN /bin/bash -l -c "source /etc/profile.d/rvm.sh"
RUN /bin/bash -l -c "rvm install 1.8.7-p374"
RUN /bin/bash -l -c "rvm rubygems 1.3.7 --force"
RUN /bin/bash -l -c "gem install mongrel -v 1.1.5"
RUN /bin/bash -l -c "gem install rake -v 0.8.7"
RUN /bin/bash -l -c "gem install rails -v 2.3.18"
RUN /bin/bash -l -c "gem install fastercsv -v 1.5.5"
RUN /bin/bash -l -c "gem install json -v 1.7.5"
RUN /bin/bash -l -c "gem install rack -v 1.1.6"
RUN /bin/bash -l -c "gem install spreadsheet -v 1.1.4"
RUN /bin/bash -l -c "gem install mysql -v 2.7 -- --with-mysql-config"
RUN /bin/bash -l -c "gem install rdoc -v 2.4.2"
RUN /bin/bash -l -c "gem install decimal -v 0.1.0"
RUN mkdir /app

WORKDIR /app