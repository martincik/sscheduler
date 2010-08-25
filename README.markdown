# Cron

Cron jobs are set in file 'config/schedule.rb'.

### Update crontab
    rake cron:update_crontab

### Clear crontab
    rake cron:clear_crontab

### Run once proccess for update products on shopify's stories
    rake cron:update_schedule

# Start

### Login informations

- shop url:     http://zdenal.myshopify.com/
- admin url:    https://zdenal.myshopify.com/admin
    email:      ladislav.martincik@gmail.com
    password:   sscheduler

*If after login You get redirect to developer login page, just put to url again admin url.
It should work.*

- developer url: https://zdenal.myshopify.com/services/partners/auth/login
    email:      nevralaz@gmail.com
    password:   sscheduler

### Shopify developer app settings
In left menu within subsection 'Apps' click on 'sscheduler'. Now You should see
App details in below-right side. 'Api Key' and 'Shared Secret' code you need set
in config/shopify.yml (there is 3 environments so You can have app for dev. testing and
production mode like in database.yml).

After click 'Edit App', will see detail, where You can set settings of app,
like: name, return url to your app after user autheticate/install app*,
name of link shown in shopify, where should show link, read/write permission of app and etc.

*ALL IS DEFAULT SET FOR APP RUNNING ON LOCALHOST.*

*For create new instance of app is there button 'create button'.*

### Development running
After set your DB etc. Just run localhost and then You will see login page. Fill
url of shop 'zdenal'. Then You should be redirect directly to sscheduler. It is,
because we have already installed app in shop.

If You dont have installed in app shop, after fill url shop will see login
page to admin account(see above). This login page is shown only if You are not loggined
in admin account or haven't store login in cookies.

Next page is asking for install app to Your shop. After click install You are redirected
directly to app.

*Installed app is shown in administration account in menu 'Apps'.*

### Cron

*More about CRON is in section CRON above.*

# Interesting

When I put command for create some model with DateTime, DB save it in UTC format.
Then when I put command find for the same model with the same DateTime, SQL request
have DateTime in setted time zone. In environment.rb I have set config.time_zone = 'Prague'.

    time = Time.now (time zone is setted for example to 'Prague' and return 2010-08-18 14:38:17)

    ScheduledProduct.create({:from_time => time})
    sql: INSERT INTO `scheduled_products` (`from_time`) VALUES('2010-08-18 12:38:17')

    ScheduledProduct.find(:all, :conditions => ["from_time < :time",{:time => time}] )
    sql:  SELECT * FROM `scheduled_products` WHERE (from_time <= '2010-08-18 14:38:15')

Next interesting thing is, that You can see in task rake time:zones:all have UTC zone
GMT+00:00 and Prague GMT+01:00. But try do in console:

    Time.zone = 'Prague'
    Time.zone.now
    Time.zone.now.utc (or Time.now.utc)

You can see 4 hours different.

