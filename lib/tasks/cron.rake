namespace :cron do

  desc 'Update scheduling data in Shopify'
  task :update_schedule => :environment do
    ScheduleWorker.perform
  end

  desc 'Update crontab'
  task :update_crontab => :environment do
    exec 'whenever --update-cron sscheduler && crontab -l'
  end

  desc 'Clear crontab'
  task :clear_crontab => :environment do
    exec 'whenever --clear-cron sscheduler && crontab -l'
  end
end

