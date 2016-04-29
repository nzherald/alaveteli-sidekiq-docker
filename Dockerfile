FROM ruby
MAINTAINER Caleb Tutty

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive
ENV RAILS_ENV production

# Update
RUN apt-get update && apt-get upgrade -y

# Install required packages
RUN apt-get -y install supervisor ca-certificates git postgresql-client build-essential catdoc elinks \
  gettext ghostscript gnuplot-nox imagemagick unzip \
  libicu-dev libmagic-dev libmagickwand-dev libmagickcore-dev libpq-dev libxml2-dev libxslt1-dev links \
  sqlite3 lockfile-progs mutt pdftk poppler-utils \
  postgresql-client tnef unrtf uuid-dev wkhtmltopdf wv xapian-tools \
  redis-server supervisor

# Clone develop branch
RUN git clone https://github.com/nzherald/alaveteli.git --branch sidekiq /opt/alaveteli

# Add yaml configuration which take environment variables
ADD assets/database.yml /opt/alaveteli/config/database.yml
ADD assets/general.yml /opt/alaveteli/config/general.yml
ADD assets/newrelic.yml /opt/alaveteli/config/newrelic.yml

WORKDIR /opt/alaveteli

# Due to some firewalls blocking git://
RUN git config --global url."https://".insteadOf git://

RUN git submodule init && git submodule update

RUN bundle install --without development debug test --deployment --retry=10
ADD assets/setup.sh /opt/setup.sh

# supervisor.conf
ADD assets/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 9292

CMD /opt/setup.sh
