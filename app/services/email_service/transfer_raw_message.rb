module EmailService
  class TransferRawMessage
    include ActionView::Helpers::SanitizeHelper

    attr_accessor :from, :to, :previous_owner, :service_name

    def initialize(from:, to:, previous_owner:, service_name:)
      @from = from
      @to = to
      @previous_owner = previous_owner
      @service_name = service_name
    end

    def to_s
      <<~RAW_MESSAGE
        From: #{@from}
        To: #{@to}
        Subject: #{subject}
        Content-Type: multipart/mixed; boundary="NextPart"

        --NextPart
        Content-Type: multipart/alternative; boundary="AltPart"

        --AltPart
        Content-Type: text/html; charset=utf-8
        Content-Transfer-Encoding: base64

        #{Base64.encode64(raw_body)}

        --NextPart--
      RAW_MESSAGE
    end

    private

    def subject
      I18n.t('default_values.transfer_ownership_email.subject')
    end

    def raw_body
      <<~RAW_MESSAGE
            <html>
          <body style="font-family: Helvetica, Arial, sans-serif;font-size: 16px;margin: 0;color:#0b0c0c;">

            <!-- govuk banner -->
            <table role="presentation" width="100%" style="border-collapse: collapse;min-width: 100%;width: 100% !important;" cellpadding="0" cellspacing="0" border="0">
                <tr>
                    <td width="100%" height="53" bgcolor="#0b0c0c">
                        <!--[if (gte mso 9)|(IE)]>
                            <table role="presentation" width="580" align="center" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;width: 580px;">
                            <tr>
                            <td>
                        <![endif]-->
                        <table role="presentation" width="100%" style="border-collapse: collapse;max-width: 580px;" cellpadding="0" cellspacing="0" border="0" align="center">
                            <tr>
                                <td width="70" bgcolor="#0b0c0c" valign="middle">
                                    <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;">
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <img
                                                  src="https://static.notifications.service.gov.uk/images/govuk-logotype-tudor-crown.png"
                                                  alt=""
                                                  height="32"
                                                  border="0"
                                                  style="Margin-top: 2px;"
                                                >
                                            </td>
                                            <td style="font-size: 28px; line-height: 1.315789474; Margin-top: 4px; padding-left: 10px;">
                                                <span style="
                                                font-family: Helvetica, Arial, sans-serif;
                                                font-weight: 700;
                                                color: #ffffff;
                                                text-decoration: none;
                                                vertical-align:top;
                                                display: inline-block;
                                                ">#{@service_name}</span>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <!--[if (gte mso 9)|(IE)]>
                            </td>
                            </tr>
                            </table>
                        <![endif]-->
                    </td>
                </tr>
            </table>
            <table
                role="presentation"
                class="content"
                align="center"
                cellpadding="0"
                cellspacing="0"
                border="0"
                style="border-collapse: collapse;max-width: 580px; width: 100% !important;"
                width="100%"
                >
                <tr>
                    <td width="10" height="10" valign="middle"></td>
                    <td>
                        <!--[if (gte mso 9)|(IE)]>
                            <table role="presentation" width="560" align="center" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;width: 560px;">
                            <tr>
                            <td height="10">
                        <![endif]-->
                        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;">
                            <tr>
                                <td bgcolor="#1D70B8" width="100%" height="10"></td>
                            </tr>
                        </table>
                        <!--[if (gte mso 9)|(IE)]>
                            </td>
                            </tr>
                            </table>
                        <![endif]-->
                    </td>
                    <td width="10" valign="middle" height="10"></td>
                </tr>
            </table>
            <!-- end govuk banner -->

            <table
                role="presentation"
                class="content"
                align="center"
                cellpadding="0"
                cellspacing="0"
                border="0"
                style="border-collapse: collapse;max-width: 580px; width: 100% !important;"
                width="100%"
                >
                <tr>
                    <td width="10" valign="middle"><br /></td>
                    <td style="font-family: Helvetica, Arial, sans-serif; font-size: 19px; line-height: 1.315789474; max-width: 560px;">
                        <!--[if (gte mso 9)|(IE)]>
                            <table role="presentation" width="560" align="center" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;width: 560px;">
                            <tr>
                            <td style="font-family: Helvetica, Arial, sans-serif; font-size: 19px; line-height: 1.315789474;">
                        <![endif]-->

                        #{body}

                        <!--[if (gte mso 9)|(IE)]>
                            </td>
                            </tr>
                            </table>
                        <![endif]-->
                    </td>
                    <td width="10" valign="middle"><br /></td>
                </tr>
                <tr>
                    <td height="30"><br /></td>
                </tr>
            </table>
          </body>
        </html>

      RAW_MESSAGE
    end

    def body
      I18n.t('default_values.transfer_ownership_email.body',
             service_name:,
             previous_owner:,
             href_signin: I18n.t('default_values.transfer_ownership_email.href_signin'),
             href_contact: I18n.t('default_values.transfer_ownership_email.href_contact'))
    end
  end
end
