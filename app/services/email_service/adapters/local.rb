module EmailService
  module Adapters
    class Local
      def list_email_identities
        { email_identities: [{}] }
      end

      def get_email_identity(_identity)
        {}
      end

      def create_email_identity(_identity)
        {}
      end

      def delete_email_identity(_identity)
        OpenStruct.new(successful?: true)
      end
    end
  end
end
