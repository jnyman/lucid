# encoding: utf-8
require "rubygems"
require "bundler/gem_tasks"

$:.unshift(File.dirname(__FILE__) + '/lib')
Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

task :release => 'api:doc'
task :default => [:spec, :lucid]

require 'rake/clean'
CLEAN.include %w(**/*.{log,pyc,rbc,tgz} doc)
