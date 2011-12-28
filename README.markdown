# Start

### Shopify developer app settings

In left menu within subsection 'Apps' click on 'sscheduler'. Now You should see
App details in below-right side. 'Api Key' and 'Shared Secret' code you need set
in config/shopify.yml (there is 3 environments so You can have app for dev. testing and
production mode like in database.yml).

After click 'Edit App', will see detail, where you can set settings for app,
like: name, return url to your app after user autheticate/install app*,
name of link shown in shopify, where should show link, read/write permission of app and etc.

*ALL IS DEFAULT SET FOR APP RUNNING ON LOCALHOST.*

*For create new instance of app there is button 'create' button.*

### Development running

After you setup your DB etc. Just run localhost and then you will see login page. Fill in
url of shop 'zdenal'. Then You should be redirect directly to sscheduler. It is,
because we have already installed app in shop.

If you don't have installed in app shop, after filling in url shop will show login
page to admin account(see above). This login page is shown only if you are not logged
in admin account or haven't store login in cookies.

Next page is asking for install app to your shop. After click install you are redirected
directly to app.

*Installed app is shown in administration account in menu 'Apps'.*

# Cron

Cron jobs are set in file 'config/schedule.rb'.

### Update crontab
    rake cron:update_crontab

### Clear crontab
    rake cron:clear_crontab

### Run once proccess for update products on shopify's stories
    rake cron:update_schedule
