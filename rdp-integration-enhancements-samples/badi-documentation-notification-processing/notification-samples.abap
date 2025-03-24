CLASS /vpcoe/cl_fb_notification DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /vpcoe/if_notifictn_processing .
    INTERFACES if_badi_interface .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /VPCOE/CL_FB_NOTIFICATION IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_FB_NOTIFICATION->/VPCOE/IF_NOTIFICTN_PROCESSING~NOTIFICATION_CHANGE_BODY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_PAYLOAD                     TYPE        /VPCOE/S_JSN_CLOUD(optional)
* | [--->] IO_LOG                         TYPE REF TO /VPCOE/CL_RDP_LOG(optional)
* | [<-->] CT_MESSAGE                     TYPE        BCSY_TEXT
* | [<-->] CV_SUBJECT                     TYPE        SO_OBJ_DES
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD /vpcoe/if_notifictn_processing~notification_change_body.

    cv_subject = |VPCoE:{ is_payload-service_id }, { is_payload-response_status }( { is_payload-response_message } )|.

    ct_message = VALUE #( ( line = `***This is an automated generated email***` )
                          ( line = `Hello Colleagues,` )
                          ( line = |Sending process was failed for { is_payload-service_id }.| )
                          ( line = |Response status: { is_payload-response_status }.| )
                          ( line = |Response message: { is_payload-response_message }.| )
                          ( line = |Session ID: { is_payload-session_id }.| ) ).

    IF io_log IS BOUND AND io_log->check( ).
      INSERT VALUE #( line = `Messages from the Log:` ) INTO TABLE ct_message.

      io_log->get_messages(
        IMPORTING
          et_messages = DATA(lt_log_msgs) ).

      LOOP AT lt_log_msgs ASSIGNING FIELD-SYMBOL(<ls_log_msg>).
        IF <ls_log_msg>-id IS NOT INITIAL.
          MESSAGE ID <ls_log_msg>-id TYPE <ls_log_msg>-type NUMBER <ls_log_msg>-number
             WITH <ls_log_msg>-message_v1 <ls_log_msg>-message_v2 <ls_log_msg>-message_v3 <ls_log_msg>-message_v4
                INTO /vpcoe/cl_rdp_log=>sv_msg_text.
          INSERT VALUE #( line = /vpcoe/cl_rdp_log=>sv_msg_text ) INTO TABLE ct_message.
        ELSE.
          INSERT VALUE #( line = <ls_log_msg>-message ) INTO TABLE ct_message.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_FB_NOTIFICATION->/VPCOE/IF_NOTIFICTN_PROCESSING~NOTIFICATION_CHANGE_SENDER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_PAYLOAD                     TYPE        /VPCOE/S_JSN_CLOUD(optional)
* | [<-->] CV_SENDER                      TYPE        ADR6-SMTP_ADDR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD /vpcoe/if_notifictn_processing~notification_change_sender.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_FB_NOTIFICATION->/VPCOE/IF_NOTIFICTN_PROCESSING~NOTIFICATION_OVERWRITE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_PAYLOAD                     TYPE        /VPCOE/S_JSN_CLOUD
* | [--->] IO_LOG                         TYPE REF TO /VPCOE/CL_RDP_LOG(optional)
* | [<-->] CV_SKIP                        TYPE        ABAP_BOOL (default =ABAP_FALSE)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD /vpcoe/if_notifictn_processing~notification_overwrite.
  ENDMETHOD.
ENDCLASS.