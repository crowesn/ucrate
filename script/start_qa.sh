#!/bin/bash
if [ ! -f "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/static/scholar-qa.variables" ]; then
    echo "Missing scholar-qa.variables file in static"
else 
    cp "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/static/scholar-qa.variables" ../.env.production.local
fi

source "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/script/kill_sidekiq.sh"
yes | cp -rf "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"/public/assets/banner_image-*.jpg "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"/public/assets/banner_image.jpg

# Create symlinks for log files
touch /mnt/common/scholar-logs/libschqwl1_production.log
rm -f "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/log/production.log"
ln -s /mnt/common/scholar-logs/libschqwl1_production.log "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/log/production.log"
touch /mnt/common/scholar-logs/libschqwl1_sidekiq.log
rm -f "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/log/sidekiq.log"
ln -s /mnt/common/scholar-logs/libschqwl1_sidekiq.log "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/log/sidekiq.log"

ln -s /srv/apps/scholar_capistrano/current /srv/apps/curate_uc 2> /dev/null
ln -s /srv/apps/scholar-avatars "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/shared/public/systems/avatars" 2> /dev/null
ln -s /srv/apps/scholar-public-uploads "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/shared/public/uploads/" 2> /dev/null
ln -s /mnt/common/branding "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/shared/public/branding" 2> /dev/null
/bin/date +"%m-%d-%Y %r" > "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/config/deploy_timestamp"
touch "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/tmp/restart.txt"
source "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/script/restart_sidekiq.sh" production 8 no
echo "The deploy to `hostname` is finished" | mail -s "Scholar@UC deploy finished (`hostname`)" scholar@uc.edu