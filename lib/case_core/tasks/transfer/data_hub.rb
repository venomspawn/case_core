# frozen_string_literal: true

CaseCore.need 1

require_relative 'data_hub/cabinet'
require_relative 'data_hub/case_manager'
require_relative 'data_hub/mfc'
require_relative 'data_hub/org_struct'

module CaseCore
  module Tasks
    class Transfer
      # Класс объектов, предоставляющих доступ к данным
      class DataHub
        extend Settings::Configurable

        # Cabinet
        settings_names :cab_host, :cab_name, :cab_user, :cab_pass

        # CaseManager
        settings_names :cm_host, :cm_name, :cm_user, :cm_pass

        # MFC
        settings_names :mfc_host, :mfc_name, :mfc_user, :mfc_pass

        # OrgStruct
        settings_names :os_host, :os_name, :os_user, :os_pass

        attr_reader :cab
        attr_reader :cm
        attr_reader :mfc
        attr_reader :os

        # Инициализирует объект класса
        def initialize
          @cab = Cabinet.new
          @cm  = CaseManager.new
          @mfc = MFC.new
          @os  = OrgStruct.new
        end

        # Возвращает ассоциативный массив с информацией о карточке оператора с
        # предоставленным идентификатором записи в `mfc`. Если информацию о
        # карточке невозможно найти, возвращает пустой ассоциативный массив.
        # @param [String] operator_id
        #   идентификатор записи оператора в `mfc`
        # @return [Hash]
        #   результирующий ассоциативный массив
        def operator_employee(operator_id)
          ecm_person = mfc.ecm_people[operator_id] || {}
          org_struct_id = ecm_person[:org_struct_id]&.to_i
          os.employees[org_struct_id] || {}
        end

        # Возвращает ассоциативный массив с информацией об офисе оператора с
        # предоставленным идентификатором записи в `mfc`. Если информацию об
        # офисе невозможно найти, возвращает пустой ассоциативный массив.
        # @param [String] operator_id
        #   идентификатор записи оператора в `mfc`
        # @return [Hash]
        #   результирующий ассоциативный массив
        def operator_office(operator_id)
          employee = operator_employee(operator_id)
          office_id = employee[:office_id]
          os.offices[office_id] || {}
        end

        # Возвращает ассоциативный массив с информацией об адресе офиса
        # оператора с предоставленным идентификатором записи в `mfc`. Если
        # информацию об адресе невозможно найти, возвращает пустой
        # ассоциативный массив.
        # @param [String] operator_id
        #   идентификатор записи оператора в `mfc`
        # @return [Hash]
        #   результирующий ассоциативный массив
        def operator_office_address(operator_id)
          employee = operator_employee(operator_id)
          office_id = employee[:office_id]
          os.addresses[office_id] || {}
        end

        # Возвращает ассоциативный массив с информацией об услуге, чья цель
        # имеет предоставленный RGUID. Если информацию об услуге невозможно
        # найти, возвращает пустой ассоциативный массив.
        # @param [String] target_service_rguid
        #   RGUID цели услуги
        # @return [Hash]
        #   результирующий ассоциативный массив
        def target_service_service(target_service_rguid)
          target_service = mfc.ld_target_services[target_service_rguid] || {}
          service_id = target_service[:service_id]
          mfc.ld_services[service_id] || {}
        end

        # Возвращает ассоциативный массив с информацией о паспорте услуги, чья
        # цель имеет предоставленный RGUID. Если информацию об услуге
        # невозможно найти, возвращает пустой ассоциативный массив.
        # @param [String] target_service_rguid
        #   RGUID цели услуги
        # @return [Hash]
        #   результирующий ассоциативный массив
        def target_service_passport(target_service_rguid)
          service = target_service_service(target_service_rguid)
          passport_id = service[:passport_id]
          mfc.ld_passports[passport_id] || {}
        end

        # Возвращает ассоциативный массив с информацией о ведомстве, в которое
        # отправлен реестр передаваемой корреспонденции с предоставленным
        # идентификатором записи. Если информацию о ведомстве невозможно найти,
        # возвращает пустой ассоциативный массив.
        # @param [Integer] register_id
        #   идентификатор записи реестра передаваемой корреспонденции
        # @return [Hash]
        #   результирующий ассоциативый массив
        def register_institution(register_id)
          register = cm.registers[register_id] || {}
          institution_rguid = register[:institution_rguid]
          mfc.ld_institutions[institution_rguid] || {}
        end

        # Возвращает ассоциативный массив с информацией об офисе ведомства, в
        # которое отправлен реестр передаваемой корреспонденции с
        # предоставленным идентификатором записи. Если информацию об адресе
        # офиса ведомства невозможно найти, возвращает пустой ассоциативный
        # массив.
        # @param [Integer] register_id
        #   идентификатор записи реестра передаваемой корреспонденции
        # @return [Hash]
        #   результирующий ассоциативный массив
        def register_office(register_id)
          register = cm.registers[register_id] || {}
          office_id = register[:office_id]&.to_i
          mfc.ld_offices[office_id] || {}
        end

        # Возвращает ассоциативный массив с информацией об адресе офиса
        # ведомства, в которое отправлен реестр передаваемой корреспонденции с
        # предоставленным идентификатором записи. Если информацию об адресе
        # офиса ведомства невозможно найти, возвращает пустой ассоциативный
        # массив.
        # @param [Integer] register_id
        #   идентификатор записи реестра передаваемой корреспонденции
        # @return [Hash]
        #   результирующий ассоциативный массив
        def register_office_address(register_id)
          register = cm.registers[register_id] || {}
          office_id = register[:office_id]&.to_i
          mfc.ld_addresses[office_id] || {}
        end

        # Возвращает ассоциативный массив с информацией о содержимом документа,
        # удостоверяющего личность. Если эту информацию невозможно найти,
        # возвращает пустой ассоциативный массив.
        # @param [String] applicant_id
        #   идентификатор записи заявителя
        # @return [Hash]
        #   результирующий ассоциативный массив
        def applicant_identity_doc_content(applicant_id)
          applicant = cab.ecm_people[applicant_id] || {}
          folder_id = applicant[:private_folder_id]
          documents = cab.ecm_documents[folder_id] || []
          Cabinet::IDENTITY_DOC_URNS.each do |urn|
            documents.each do |document|
              return document[:content] if document[:schema_urn].include?(urn)
            end
          end
          {}
        end

        # Возвращает ассоциативный массив с информацией об организации
        # заявителя. Если информацию об организации невозможно найти,
        # возвращает пустой ассоциативный массив.
        # @param [String] applicant_id
        #   идентификатор записи заявителя
        # @return [Hash]
        #   результирующий ассоциативный массив
        def applicant_organization(applicant_id)
          applicant = cab.ecm_people[applicant_id] || {}
          organization_id = applicant[:organization_id]
          cab.ecm_organizations[organization_id] || {}
        end

        # Возвращает, является ли заявитель физическим лицом
        # @param [String] applicant_id
        #   идентификатор записи заявителя
        # @return [Boolean]
        #   является ли заявитель физическим лицом
        def applicant_individual?(applicant_id)
          applicant = cab.ecm_people[applicant_id] || {}
          applicant[:organization_id].nil?
        end

        # Возвращает, является ли заявитель индивидуальным предпринимателем
        # @param [String] applicant_id
        #   идентификатор записи заявителя
        # @return [Boolean]
        #   является ли заявитель индивидуальным предпринимателем
        def applicant_entrepreneur?(applicant_id)
          organization = applicant_organization(applicant_id)
          organization[:type] == 'B'
        end

        # Возвращает, является ли заявитель юридическим лицом
        # @param [String] applicant_id
        #   идентификатор записи заявителя
        # @return [Boolean]
        #   является ли заявитель юридическим лицом
        def applicant_organization?(applicant_id)
          organization = applicant_organization(applicant_id)
          organization[:type] == 'L'
        end

        # Возвращает полное имя заявителя
        # @param [String] applicant_id
        #   идентификатор записи заявителя
        # @return [String]
        #   полное имя заявителя
        def applicant_full_name(applicant_id)
          applicant = cab.ecm_people[applicant_id] || {}
          parts = applicant.values_at(:last_name, :first_name, :middle_name)
          parts.select(&:present?).join(' ')
        end
      end
    end
  end
end
