
rake redmine:plugins:migrate RAILS_ENV=production
插件: redmine_knowledgebase 　  　    redmine_xls_export

任务仪表盘:  git clone https://github.com/netaustin/redmine_task_board.git

图表格:　git clone git://github.com/bradbeattie/redmine-graphs-plugin.git redmine_graphs
项目进度图: git clone https://github.com/stgeneral/redmine-progressive-projects-list.git progressive_projects_list

项目监控:  git clone https://github.com/alexmonteiro/Redmine-Monitoring-Controlling.git  redmine_monitoring_controlling

周期性循环任务: git clone https://github.com/nutso/redmine-plugin-recurring-tasks.git recurring_tasks

图片粘贴：　git clone https://github.com/peclik/clipboard_image_paste.git

导出excel:　git clone https://github.com/two-pack/redmine_xls_export.git


工时管理软件:　git clone https://github.com/maxrossello/redmine_app__space.git redmine_app__space
                        git clone https://github.com/maxrossello/redmine_app_timesheets.git redmine_app_timesheets
                        RAILS_ENV=production rake redmine:plugins:migrate




　  　         redmine_monitoring_controlling  redmine_xls_export
ezlibrarian            recurring_tasks            redmine-graphs-plugin  redmine_task_board





## 2016 .06 .15 添加工时报表

统计 分配给每个人问题的预计工时 及实际花费的工时
Issue.where(assigned_to: ).sum(:estimated_hours)
TimeEntry.where(user_id: ).sum(:hours)