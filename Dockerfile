FROM ruby:2.5.3

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Add dev user
RUN useradd -ms /bin/bash dev
RUN echo dev:password | chpasswd && usermod -aG sudo dev

# add nodejs and yarn dependencies for the frontend
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# --allow-unauthenticated needed for yarn package
RUN apt-get update && apt-get upgrade -y && \
  apt-get install --no-install-recommends -y ca-certificates nodejs yarn \
  build-essential libpq-dev libreoffice imagemagick unzip ghostscript vim \
  ffmpeg \
  clamav-freshclam clamav-daemon libclamav-dev tmux sudo \
  qt5-default libqt5webkit5-dev xvfb xauth openjdk-8-jre --fix-missing --allow-unauthenticated

# fetch clamav local database
# initial update of av databases
RUN mkdir -p /var/lib/clamav && \
  wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
  wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
  wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
  chown clamav:clamav /var/lib/clamav/*.cvd

# install FITS for file characterization
RUN mkdir -p /opt/fits && \
  curl -fSL -o /opt/fits-1.0.5.zip http://projects.iq.harvard.edu/files/fits/files/fits-1.0.5.zip && \
  cd /opt && unzip fits-1.0.5.zip && chmod +X fits-1.0.5/fits.sh

# Install Redis
RUN mkdir -p /opt/redis && cd /opt/redis && wget http://download.redis.io/releases/redis-4.0.3.tar.gz && \
tar xzvf redis-4.0.3.tar.gz && \
cd redis-4.0.3 && make && make install
# RUN echo never > /sys/kernel/mm/transparent_hugepage/enabled

# Install gems
USER dev
WORKDIR /home/dev
RUN git clone https://github.com/uclibs/ucrate.git
WORKDIR /home/dev/ucrate
RUN gem install bundler
RUN bundle install
USER root
RUN chown -R dev /home/dev/ucrate
USER dev
CMD git pull && bundle install & clear && printf "**********************************\nEnter this command: source script/docker.sh migrate\nAfter the previous command has finished, simply go to localhost:3000 in any browser\nTo exit press Ctrl + D\n**********************************\n" && bash