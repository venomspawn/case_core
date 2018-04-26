# frozen_string_literal: true

# Файл загрузки и настройки переноса данных

require "#{$lib}/tasks/transfer"

CaseCore::Tasks::Transfer::DataHub.configure do |settings|
  # Cabinet
  settings.set :cab_host, ENV['CC_CAB_HOST']
  settings.set :cab_name, ENV['CC_CAB_NAME']
  settings.set :cab_user, ENV['CC_CAB_USER']
  settings.set :cab_pass, ENV['CC_CAB_PASS']
  # CaseManager
  settings.set :cm_host, ENV['CC_CM_HOST']
  settings.set :cm_name, ENV['CC_CM_NAME']
  settings.set :cm_user, ENV['CC_CM_USER']
  settings.set :cm_pass, ENV['CC_CM_PASS']
  # MFC
  settings.set :mfc_host, ENV['CC_MFC_HOST']
  settings.set :mfc_name, ENV['CC_MFC_NAME']
  settings.set :mfc_user, ENV['CC_MFC_USER']
  settings.set :mfc_pass, ENV['CC_MFC_PASS']
  # OrgStruct
  settings.set :os_host, ENV['CC_OS_HOST']
  settings.set :os_name, ENV['CC_OS_NAME']
  settings.set :os_user, ENV['CC_OS_USER']
  settings.set :os_pass, ENV['CC_OS_PASS']
end
