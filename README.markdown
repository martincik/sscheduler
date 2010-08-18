# Cron

Cron jobs are set in file 'config/schedule.rb'.

### Update crontab
    rake cron:update_crontab

### Clear crontab
    rake cron:clear_crontab

### Run once proccess for update products on shopify's stories
    rake cron:update_schedule

### Interesting

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

