#!/Users/phaffley/.rvm/wrappers/StatusInvoker/bundle exec ruby
# frozen_string_literal: true

require "daemons"
Daemons.run("schedule_invoker.rb", :dir_mode => :normal, :dir => "/tmp")
