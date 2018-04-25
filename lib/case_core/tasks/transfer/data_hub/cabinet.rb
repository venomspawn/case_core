# frozen_string_literal: true

require_relative 'base/db'

module CaseCore
  module Tasks
    class Transfer
      class DataHub
        # Класс объектов, предоставляющих возможность работы с базой данных
        # `cabinet`
        class Cabinet < Base::DB
          require_relative 'cabinet/ecm_documents'
          require_relative 'cabinet/vicarious_authorities'

          # Префикс URN
          IDENTITY_DOC_URN_PREFIX =
            'urn:metastore:fragments.gosuslugi.type_zayavitel.'.freeze

          # Названия документов, удостоверяющих личность
          IDENTITY_DOC_URN_NAMES = %w[
            PasportgrRF
            Zagran_pasport_grazhd
            dulz
            udostovVoen
            voenbilet
            VremudlichgrRF
            svid
            PasportIn
            Vid_na_zhitelstvo
            Razresh_vremen_prozh
            udbezhenca
            SvidUbezh
          ].freeze

          # URN документов, удостоверяющих личность
          IDENTITY_DOC_URNS =
            IDENTITY_DOC_URN_NAMES
            .map { |s| "#{IDENTITY_DOC_URN_PREFIX}#{s}" }
            .freeze

          # URN документа, удостоверяющего полномочия
          VICARIOUS_AUTHORITY_URN =
            'urn:metastore:fragments.MFC.Dokument_poln_predstav'.freeze

          # Ассоциативный массив, в котором идентификаторам записей заявителей
          # сопоставлены ассоциативные массивы с информацией о заявителях
          # @return [Hash]
          #   ассоциативный массив с информацией о заявителях
          attr_reader :ecm_people

          # Ассоциативный массив, в котором идентификаторам записей заявителей
          # сопоставлены ассоциативные массивы с информацией о контактных
          # данных
          # @return [Hash]
          #   ассоциативный массив с информацией о контактных данных
          attr_reader :ecm_contacts

          # Ассоциативный массив, в котором идентификаторам папок заявителей
          # сопоставлены списки ассоциативных массивов с информацией о
          # документах
          # @return [Hash]
          #   ассоциативный массив с информацией о документах
          attr_reader :ecm_documents

          # Ассоциативный массив, в котором идентификаторам записей заявителей
          # сопоставлены ассоциативные массивы с информацией об адресах их
          # регистрации
          # @return [Hash]
          #   ассоциативный массив с информацией об адресах регистрации
          attr_reader :ecm_addresses

          # Ассоциативный массив, в котором идентификаторам записей заявителей
          # сопоставлены ассоциативные массивы с информацией об их фактических
          # адресах
          # @return [Hash]
          #   ассоциативный массив с информацией о фактических адресах
          attr_reader :ecm_factual_addresses

          # Ассоциативный массив, в котором спискам из идентификаторов записей
          # заявителя и представителя соответствует ассоциативный массив с
          # информацией о последней доверенности
          # @return [Hash]
          #   ассоциативный массив с информацией о доверенностях
          attr_reader :vicarious_authorities

          # Инициализирует объект класса
          # Инициализирует объект класса
          def initialize
            settings = DataHub.settings
            host = settings.cab_host
            name = settings.cab_name
            user = settings.cab_user
            pass = settings.cab_pass
            super(:mysql2, host, name, user, pass)
            initialize_collections
          end

          private

          # Инициализирует коллекции данных
          def initialize_collections
            initialize_ecm_people
            initialize_ecm_contacts
            initialize_ecm_documents
            initialize_ecm_addresses
            initialize_ecm_factual_addresses
            initialize_vicarious_authorities
          end

          # Список названий столбцов, извлекаемых из таблицы `ecm_people`
          ECM_PEOPLE_COLUMNS = %i[
            id
            birth_date
            birth_place
            last_name
            first_name
            middle_name
            inn
            ogrn
            snils
            organization_id
            private_folder_id
          ].freeze

          # Инициализирует коллекцию данных о заявителях
          def initialize_ecm_people
            data = db[:ecm_people].select(*ECM_PEOPLE_COLUMNS)
            @ecm_people = data.as_hash(:id)
          end

          # Инициализирует коллекцию данных о контактных данных
          def initialize_ecm_contacts
            @ecm_contacts = db[:ecm_contacts].as_hash(:person_id)
          end

          # Инициализирует коллекцию данных о документах
          def initialize_ecm_documents
            @ecm_documents = ECMDocuments.data(db)
          end

          # Инициализирует коллекцию данных об адресах регистрации
          def initialize_ecm_addresses
            @ecm_addresses = db[:ecm_addresses].as_hash(:person_id)
          end

          # Инициализирует коллекцию данных о фактических адресах
          def initialize_ecm_factual_addresses
            data = db[:ecm_factual_addresses]
            @ecm_factual_addresses = data.as_hash(:person_id)
          end

          # Инициализирует коллекцию данных о доверенностях
          def initialize_vicarious_authorities
            @vicarious_authorities =
              VicariousAuthorities.data(db, ecm_people, ecm_documents)
          end
        end
      end
    end
  end
end
