CLASS lcl_exmpl_pckg_fee DEFINITION CREATE PUBLIC
   INHERITING FROM /vpcoe/cl_pckf_proc_pckg_fee.

  PUBLIC SECTION.
    METHODS /vpcoe/if_pckf_entity_proc~transfer_package REDEFINITION.

  PRIVATE SECTION.

    CONSTANTS:
      mc_condition_type_zrdp   TYPE kscha VALUE 'ZRDP',
      mc_condition_type_zesp   TYPE kscha VALUE 'ZESP',
      mc_condition_type_zest   TYPE kscha VALUE 'ZEST',
      mc_condition_type_zcon   TYPE kscha VALUE 'ZCON',
      mc_condition_type_zese   TYPE kscha VALUE 'ZESE',
      mc_procdir_inbound       TYPE /vpcoe/pckf_proc_drctn VALUE 'INBOUND',
      mc_procdir_outbound      TYPE /vpcoe/pckf_proc_drctn VALUE 'OUTBOUND',

      mc_kc_sales_country      TYPE string VALUE 'SD-01',
      mc_kc_sales_general      TYPE string VALUE 'SD-02',
      mc_kc_sales_material     TYPE string VALUE 'SD-03',
      mc_kc_sales_additional   TYPE string VALUE 'SD-04',
      mc_kc_purch_material     TYPE string VALUE 'MM-01',
      mc_kc_purch_general      TYPE string VALUE 'MM-02',
      mc_kc_customer_independent        TYPE string VALUE 'SD-05',
      mc_kc_customer_dependent    TYPE string VALUE 'SD-06'.

    DATA:
      mv_test_mode TYPE abap_bool.

    METHODS upsert_pricing_condition
      IMPORTING
                !iv_condition_type     TYPE kscha DEFAULT mc_condition_type_zrdp
                !ir_ent_pckg_fee       TYPE REF TO /vpcoe/cl_pckf_ent_pckg_fee
                !is_ent_org_data       TYPE /vpcoe/s_pckf_ent_org_data OPTIONAL
                !is_ent_supplier       TYPE /vpcoe/s_pckf_ent_suplr OPTIONAL
                !iv_fee_qty            TYPE kbetr OPTIONAL
                !iv_use_additional_fee TYPE abap_bool DEFAULT abap_false
                !iv_customer           TYPE string OPTIONAL
      RETURNING VALUE(rv_error)        TYPE abap_bool.

    METHODS pricing_condition_exists
      IMPORTING
                !iv_condition_type TYPE kscha
                !ir_ent_pckg_fee   TYPE REF TO /vpcoe/cl_pckf_ent_pckg_fee
                !is_ent_org_data   TYPE /vpcoe/s_pckf_ent_org_data OPTIONAL
                !is_ent_supplier   TYPE /vpcoe/s_pckf_ent_suplr OPTIONAL
                !iv_customer       TYPE string OPTIONAL
      RETURNING VALUE(rv_exists)   TYPE abap_bool.

    METHODS update_pricing_condition
      IMPORTING
                !iv_condition_type     TYPE kscha
                !ir_ent_pckg_fee       TYPE REF TO /vpcoe/cl_pckf_ent_pckg_fee
                !is_ent_org_data       TYPE /vpcoe/s_pckf_ent_org_data OPTIONAL
                !is_ent_supplier       TYPE /vpcoe/s_pckf_ent_suplr OPTIONAL
                !iv_fee_qty            TYPE kbetr OPTIONAL
                !iv_use_additional_fee TYPE abap_bool
                !iv_customer           TYPE string OPTIONAL
      RETURNING VALUE(rv_error)        TYPE abap_bool.

    METHODS create_pricing_condition
      IMPORTING
                !iv_condition_type     TYPE kscha
                !ir_ent_pckg_fee       TYPE REF TO /vpcoe/cl_pckf_ent_pckg_fee
                !is_ent_org_data       TYPE /vpcoe/s_pckf_ent_org_data OPTIONAL
                !is_ent_supplier       TYPE /vpcoe/s_pckf_ent_suplr OPTIONAL
                !iv_fee_qty            TYPE kbetr OPTIONAL
                !iv_use_additional_fee TYPE abap_bool
                !iv_customer            TYPE string OPTIONAL
      RETURNING VALUE(rv_error)        TYPE abap_bool.

    METHODS update_mclass_es_plastictax
      IMPORTING
                !ir_ent_pckg_fee TYPE REF TO /vpcoe/cl_pckf_ent_pckg_fee
      RETURNING VALUE(rv_error)  TYPE abap_bool.

    METHODS get_key_combination
      IMPORTING !ir_ent_pckg_fee          TYPE REF TO /vpcoe/cl_pckf_ent_pckg_fee
                !is_ent_org_data          TYPE /vpcoe/s_pckf_ent_org_data OPTIONAL
                !is_ent_supplier          TYPE /vpcoe/s_pckf_ent_suplr OPTIONAL
                !iv_condition_type        TYPE kscha OPTIONAL
      EXPORTING
                et_messages               TYPE /vpcoe/t_uph_msg
      RETURNING VALUE(rv_key_combination) TYPE string.

    METHODS date_to_external
      IMPORTING
                !iv_date         TYPE dats
      RETURNING VALUE(rv_result) TYPE bdc_fval.

    METHODS convert_to_external
      IMPORTING
                !iv_data         TYPE any
                !iv_max_decimals TYPE i OPTIONAL
      RETURNING VALUE(rv_result) TYPE bdc_fval.

    METHODS determ_purchase_org
      IMPORTING
                !is_ent_org_data TYPE /vpcoe/s_pckf_ent_org_data
      RETURNING VALUE(rv_result) TYPE ekorg.

ENDCLASS.

CLASS lcl_exmpl_pckg_fee IMPLEMENTATION.

  METHOD /vpcoe/if_pckf_entity_proc~transfer_package.

    DATA: lv_error              TYPE abap_bool,
          lv_description        TYPE string,
          lt_customer_exemption TYPE TABLE OF /vpcoe/s_pckf_custom_exemp.

    "Get test mode parameter value
    /vpcoe/if_pckf_entity_proc~get_parameter_value( EXPORTING iv_name = /vpcoe/if_pckf_entity_proc=>gc_parameters-test_mode IMPORTING ev_value = mv_test_mode ).

    "Transfer the packaging fee entities to pricing conditions
    LOOP AT it_entity_data INTO DATA(lr_entity_data).

      DATA(lr_pckf_data) = CAST /vpcoe/cl_pckf_ent_pckg_fee( lr_entity_data ).

      DATA(lt_orgdata) = lr_pckf_data->get_organizationdata( ).
      DATA(lt_suppliers) = lr_pckf_data->get_suppliers( ).

      IF lr_pckf_data->get_conai_extension( ) IS NOT INITIAL.
        lv_description = |{ lr_pckf_data->get_conai_extension( )-packagingcode }-{ lr_pckf_data->get_conai_extension( )-reportfractionname }|.
      ELSE.
        lv_description = ''.
      ENDIF.

      CLEAR lv_error.

      DATA(lt_customer_exemption_row) = NEW /vpcoe/cl_cstm_exemp_cache( )->/vpcoe/if_pckf_cache~get_entities( iv_entity_type = /vpcoe/if_pckf_entity_data=>gc_entities-gc_ent_cstm_exemp ).
      LOOP AT lt_customer_exemption_row ASSIGNING FIELD-SYMBOL(<ls_customer_exemption>).
        DATA(ls_customer_exemption) = CAST /vpcoe/cl_pckf_ent_cstm_exemp( <ls_customer_exemption> ).
        lt_customer_exemption = VALUE #( BASE lt_customer_exemption ( ls_customer_exemption->get_data( ) ) ).
      ENDLOOP.
      SORT lt_customer_exemption.
      DELETE ADJACENT DUPLICATES FROM lt_customer_exemption COMPARING ALL FIELDS.

      CASE lr_pckf_data->get_business_process_direction( ).

        WHEN mc_procdir_outbound.

          "Process outbound packaging fee (SD sales)

          "Organizational data exists?
          IF lt_orgdata IS INITIAL.
            lv_error = upsert_pricing_condition( ir_ent_pckg_fee = lr_pckf_data ).

            IF lv_error = abap_true.
              rv_error_flg = abap_true.
            ENDIF.
          ELSE.

            LOOP AT lt_orgdata INTO DATA(ls_orgdata).
              lv_error = upsert_pricing_condition( ir_ent_pckg_fee = lr_pckf_data is_ent_org_data = ls_orgdata ).

              IF lv_error = abap_true.
                rv_error_flg = abap_true.
              ENDIF.

              IF lr_pckf_data->get_extension( ) IS NOT INITIAL.
                lv_error = upsert_pricing_condition( iv_condition_type     = mc_condition_type_zesp
                                                     ir_ent_pckg_fee       = lr_pckf_data
                                                     is_ent_org_data       = ls_orgdata
                                                     iv_fee_qty            = lr_pckf_data->get_extension( )-inhouseproductionchargeablefee
                                                     iv_use_additional_fee = abap_true ).

                IF lv_error = abap_true.
                  rv_error_flg = abap_true.
                ENDIF.

                lv_error = upsert_pricing_condition( iv_condition_type     = mc_condition_type_zest
                                                     ir_ent_pckg_fee       = lr_pckf_data
                                                     is_ent_org_data       = ls_orgdata
                                                     iv_fee_qty            = lr_pckf_data->get_extension( )-inhouseprodnstatisticalfee
                                                     iv_use_additional_fee = abap_true ).
              ENDIF.

              IF lr_pckf_data->get_conai_extension( ) IS NOT INITIAL.


                IF line_exists( lt_customer_exemption[ report_fraction = lr_pckf_data->get_conai_extension( )-reportfraction
                                                       report_category = lr_pckf_data->get_reportcategoryid( ) ] ).
                  "create customer dependent pricing condition
                  LOOP AT lt_customer_exemption  ASSIGNING FIELD-SYMBOL(<ls_exemption>)
                    WHERE report_fraction = lr_pckf_data->get_conai_extension( )-reportfraction
                      AND report_category = lr_pckf_data->get_reportcategoryid( ).

                    lv_error = upsert_pricing_condition(
                             iv_condition_type     = mc_condition_type_zese
                             ir_ent_pckg_fee       = lr_pckf_data
                             is_ent_org_data       = ls_orgdata
                             iv_fee_qty            = CONV #( <ls_exemption>-exemption_percent )
                             iv_customer           = <ls_exemption>-customer
                             iv_use_additional_fee = abap_false ).
                  ENDLOOP.

                ELSE.
                  "create customer independent pricing condition
                  lv_error = upsert_pricing_condition(
                             iv_condition_type = mc_condition_type_zcon
                             ir_ent_pckg_fee   = lr_pckf_data
                             is_ent_org_data   = ls_orgdata
                             iv_fee_qty        = lr_pckf_data->get_conai_extension( )-feepertonne
                             iv_use_additional_fee = abap_false ).
                ENDIF.

                IF lv_error = abap_true.
                  rv_error_flg = abap_true.
                ENDIF.
              ENDIF.

            ENDLOOP.
          ENDIF.

          "Set Spain Plastic tax characteristics at material classification (if needed)
          lv_error = update_mclass_es_plastictax( ir_ent_pckg_fee = lr_pckf_data ).

          IF lv_error = abap_true.
            rv_error_flg = abap_true.
          ENDIF.

        WHEN mc_procdir_inbound.

          "Process inbound packaging fee (MM purchasing)

          "the Company Code from Org data is used to determine the purchasing organization
          LOOP AT lt_orgdata INTO ls_orgdata.

            "No supplier data exists
            IF lt_suppliers IS INITIAL.

              lv_error = upsert_pricing_condition( ir_ent_pckg_fee = lr_pckf_data is_ent_org_data = ls_orgdata ).
              IF lv_error = abap_true.
                rv_error_flg = abap_true.
              ENDIF.

            ELSE.

              "Supplier data exists
              LOOP AT lt_suppliers REFERENCE INTO DATA(lr_supplier).

                LOOP AT lt_orgdata INTO ls_orgdata.
                  lv_error = upsert_pricing_condition( ir_ent_pckg_fee = lr_pckf_data is_ent_org_data = ls_orgdata is_ent_supplier = lr_supplier->* ).

                  IF lv_error = abap_true.
                    rv_error_flg = abap_true.
                  ENDIF.
                ENDLOOP.

              ENDLOOP.

              "In case of fallback fee, write in addition without supplier
              IF lr_pckf_data->is_fallback_fee( ) = abap_true.

*                lv_error = upsert_pricing_condition( ir_ent_pckg_fee = lr_pckf_data is_ent_org_data = ls_orgdata ).
                IF lv_error = abap_true.
                  rv_error_flg = abap_true.
                ENDIF.

              ENDIF.

            ENDIF.

            IF lr_pckf_data->get_conai_extension( ) IS NOT INITIAL.


                IF line_exists( lt_customer_exemption[ report_fraction = lr_pckf_data->get_conai_extension( )-reportfraction
                                                       report_category = lr_pckf_data->get_reportcategoryid( ) ] ).
                  "create customer dependent pricing condition
                  LOOP AT lt_customer_exemption  ASSIGNING <ls_exemption>
                    WHERE report_fraction = lr_pckf_data->get_conai_extension( )-reportfraction
                      AND report_category = lr_pckf_data->get_reportcategoryid( ).

                  lv_error = upsert_pricing_condition(
                             iv_condition_type     = mc_condition_type_zese
                             ir_ent_pckg_fee       = lr_pckf_data
                             is_ent_org_data       = ls_orgdata
                             iv_fee_qty            = CONV #( <ls_exemption>-exemption_percent )
                             iv_use_additional_fee = abap_false ).
                  ENDLOOP.

                ELSE.
                  "create customer independent pricing condition
                  lv_error = upsert_pricing_condition(
                             iv_condition_type = mc_condition_type_zcon
                             ir_ent_pckg_fee   = lr_pckf_data
                             is_ent_org_data   = ls_orgdata
                             iv_fee_qty        = lr_pckf_data->get_conai_extension( )-feepertonne
                             iv_use_additional_fee = abap_false ).
                ENDIF.

                IF lv_error = abap_true.
                  rv_error_flg = abap_true.
                ENDIF.
              ENDIF.
          ENDLOOP.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD upsert_pricing_condition.

    DATA lv_error TYPE abap_bool.

    CLEAR rv_error.

    IF pricing_condition_exists( iv_condition_type = iv_condition_type ir_ent_pckg_fee = ir_ent_pckg_fee is_ent_org_data = is_ent_org_data is_ent_supplier = is_ent_supplier ) = abap_true.
      lv_error = update_pricing_condition( iv_condition_type = iv_condition_type ir_ent_pckg_fee = ir_ent_pckg_fee is_ent_org_data = is_ent_org_data is_ent_supplier = is_ent_supplier iv_fee_qty = iv_fee_qty iv_use_additional_fee = iv_use_additional_fee
                                           iv_customer = iv_customer ).
    ELSE.
      lv_error = create_pricing_condition( iv_condition_type = iv_condition_type ir_ent_pckg_fee = ir_ent_pckg_fee is_ent_org_data = is_ent_org_data is_ent_supplier = is_ent_supplier iv_fee_qty = iv_fee_qty iv_use_additional_fee = iv_use_additional_fee
                                           iv_customer = iv_customer ).
    ENDIF.

    IF lv_error = abap_true.
      rv_error = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD pricing_condition_exists.

    DATA lt_bdcdata               TYPE TABLE OF bdcdata.
    DATA lt_bdcmsgcoll            TYPE TABLE OF bdcmsgcoll.
    DATA lv_tcode TYPE tcode.

    CLEAR rv_exists.

    DATA(lv_keycombination) = get_key_combination( iv_condition_type = iv_condition_type ir_ent_pckg_fee = ir_ent_pckg_fee is_ent_org_data = is_ent_org_data is_ent_supplier = is_ent_supplier ).
    IF lv_keycombination IS INITIAL.
      RETURN.
    ENDIF.

    lv_tcode = COND #( WHEN ir_ent_pckg_fee->get_business_process_direction( ) EQ mc_procdir_outbound THEN 'VK13' ELSE 'MEK3' ).

    APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '0100' dynbegin = 'X' ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'RV13A-KSCHL' fval = iv_condition_type ) TO lt_bdcdata.
    APPEND VALUE #( program  = 'SAPLV14A' dynpro   = '0100' dynbegin = 'X' ) TO lt_bdcdata.

    CASE lv_keycombination.
      WHEN mc_kc_sales_country.

        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(01)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(03)' fval = '' ) TO lt_bdcdata.


        APPEND VALUE #( program  = 'RV13A999' dynpro   = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003' fval = is_ent_org_data-division ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F004' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F005-LOW' fval = ir_ent_pckg_fee->get_reportcategorycountry( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro = '1999' dynbegin = 'X' ) TO lt_bdcdata.

      WHEN mc_kc_sales_general.

        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(02)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'RV13A004' dynpro   = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003-LOW' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro = '1004' dynbegin = 'X' ) TO lt_bdcdata.

      WHEN mc_kc_sales_material.

        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(03)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(03)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'RV13A005' dynpro   = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F004-LOW' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro = '1005' dynbegin = 'X' ) TO lt_bdcdata.

      WHEN mc_kc_sales_additional.

        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'RV13A004' dynpro = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003-LOW' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'SAPMV13A' dynpro = '1004' dynbegin = 'X' ) TO lt_bdcdata.

      WHEN mc_kc_purch_material.

        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(01)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = '' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'RV13A018' dynpro   = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_supplier-supplier ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003' fval = determ_purchase_org( is_ent_org_data = is_ent_org_data ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F004-LOW' fval = '0' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro = '1018' dynbegin = 'X' ) TO lt_bdcdata.

      WHEN mc_kc_purch_general.

        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(02)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'RV13A049' dynpro   = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = determ_purchase_org( is_ent_org_data = is_ent_org_data ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = '0' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003-LOW' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro = '1049' dynbegin = 'X' ) TO lt_bdcdata.
      WHEN mc_kc_customer_independent.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'RV13A820' dynpro = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-companycode ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002-LOW' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'SAPMV13A' dynpro = '1820' dynbegin = 'X' ) TO lt_bdcdata.
      WHEN mc_kc_customer_dependent.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'RV13A971' dynpro = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-companycode ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003-LOW' fval = iv_customer ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'SAPMV13A' dynpro = '1971' dynbegin = 'X' ) TO lt_bdcdata.
    ENDCASE.

    APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '/ENDE' ) TO lt_bdcdata.

    CALL TRANSACTION lv_tcode
           USING lt_bdcdata
           MODE   'N'
           MESSAGES INTO lt_bdcmsgcoll.

    IF sy-subrc = 0.

      rv_exists = abap_true.

      "check if there is message: no condition exists
      READ TABLE lt_bdcmsgcoll WITH KEY msgid = 'VK' msgnr = '021' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        rv_exists = abap_false.
      ENDIF.

    ELSE.
      rv_exists = abap_false.
    ENDIF.

  ENDMETHOD.

  METHOD create_pricing_condition.

    DATA lt_bdcdata               TYPE TABLE OF bdcdata.
    DATA lt_bdcmsgcoll            TYPE TABLE OF bdcmsgcoll.
    DATA lv_tcode TYPE tcode.
    DATA lv_fee TYPE kbetr.

    CLEAR rv_error.

    DATA(lv_keycombination) = get_key_combination( iv_condition_type = iv_condition_type ir_ent_pckg_fee = ir_ent_pckg_fee is_ent_org_data = is_ent_org_data is_ent_supplier = is_ent_supplier ).

    IF lv_keycombination IS INITIAL.
      rv_error = abap_true.

      "mark packaging fee entry as failed
      ir_ent_pckg_fee->set_failed( abap_true ).

      RETURN.
    ENDIF.

    lv_tcode = COND #( WHEN ir_ent_pckg_fee->get_business_process_direction( ) EQ mc_procdir_outbound THEN 'VK11' ELSE 'MEK1' ).
    lv_fee   = COND #( WHEN iv_use_additional_fee EQ abap_true THEN iv_fee_qty ELSE ir_ent_pckg_fee->get_totalfee( ) ).

    APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '0100' dynbegin = 'X' ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ANTA' ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'RV13A-KSCHL' fval = iv_condition_type ) TO lt_bdcdata.

    APPEND VALUE #( program  = 'SAPLV14A' dynpro   = '0100' dynbegin = 'X' ) TO lt_bdcdata.

    CASE lv_keycombination.
      WHEN mc_kc_sales_country.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(01)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(03)' fval = '' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '1999' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-VKORG' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-VTWEG' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-SPART' fval = is_ent_org_data-division ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-MATNR' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-LAND1(01)' fval = ir_ent_pckg_fee->get_reportcategorycountry( ) ) TO lt_bdcdata.

      WHEN mc_kc_sales_general.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(02)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '1004' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-VKORG' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-VTWEG' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-MATNR(01)' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.

      WHEN mc_kc_sales_material.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(03)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(03)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '1005' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-VKORG' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-VTWEG' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-MATNR(01)' fval = ir_ent_pckg_fee->get_productid( ) )  TO lt_bdcdata.

      WHEN mc_kc_sales_additional.

        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'SAPMV13A' dynpro = '1004' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-VKORG' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-VTWEG' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-MATNR(01)' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.

      WHEN mc_kc_purch_material.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(01)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = '' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '1018' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-LIFNR' fval = is_ent_supplier-supplier ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-EKORG' fval = determ_purchase_org( is_ent_org_data = is_ent_org_data ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-MATNR' fval = ir_ent_pckg_fee->get_productid( ) )  TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-ESOKZ(01)' fval = '0' ) TO lt_bdcdata.

        IF is_ent_supplier-is_excluded_from_report_config = abap_true.
          lv_fee = 0.
        ENDIF.

      WHEN mc_kc_purch_general.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(02)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '1049' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-EKORG' fval = determ_purchase_org( is_ent_org_data = is_ent_org_data ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-ESOKZ' fval = '0' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-MATNR(01)' fval = ir_ent_pckg_fee->get_productid( ) )  TO lt_bdcdata.
      WHEN mc_kc_customer_independent.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'SAPMV13A' dynpro = '1820' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-BUKRS' fval = is_ent_org_data-companycode ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-MATNR(01)' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
      WHEN mc_kc_customer_dependent.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'SAPMV13A' dynpro = '1971' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-BUKRS' fval = is_ent_org_data-companycode ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-MATNR' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'KOMG-KUNNR(01)' fval = iv_customer ) TO lt_bdcdata.

    ENDCASE.

    APPEND VALUE #( fnam = 'RV13A-DATAB(01)' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'RV13A-DATBI(01)' fval = date_to_external( ir_ent_pckg_fee->get_validto( ) ) ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'KONP-KBETR(01)' fval = convert_to_external( iv_data = lv_fee iv_max_decimals = 2 ) ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'KONP-KONWA(01)' fval = convert_to_external( ir_ent_pckg_fee->get_currency( ) ) ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'KONP-KPEIN(01)' fval = convert_to_external( iv_data = ir_ent_pckg_fee->get_referencequantity( ) iv_max_decimals = 0 ) ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'KONP-KMEIN(01)' fval = convert_to_external( iv_data = 'EA' ) ) TO lt_bdcdata.

    IF mv_test_mode = abap_true.
      APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '/EABR' ) TO lt_bdcdata.
    ELSE.
      APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=SICH' ) TO lt_bdcdata.
    ENDIF.

    DATA(lv_mode) = COND #( WHEN mv_test_mode = abap_true THEN 'E' ELSE 'N' ).

    CALL TRANSACTION lv_tcode
           USING lt_bdcdata
           MODE  lv_mode
           MESSAGES INTO lt_bdcmsgcoll.

    IF sy-subrc = 0.
      rv_error = abap_false.
    ELSE.
      rv_error = abap_true.

      "mark packaging fee entry as failed
      ir_ent_pckg_fee->set_failed( abap_true ).
      ir_ent_pckg_fee->set_messages( lt_bdcmsgcoll ).

    ENDIF.

  ENDMETHOD.

  METHOD update_pricing_condition.

    DATA lt_bdcdata               TYPE TABLE OF bdcdata.
    DATA lt_bdcmsgcoll            TYPE TABLE OF bdcmsgcoll.
    DATA lv_tcode TYPE tcode.
    DATA lv_fee TYPE kbetr.

    CLEAR rv_error.

    DATA(lv_keycombination) = get_key_combination( iv_condition_type = iv_condition_type ir_ent_pckg_fee = ir_ent_pckg_fee is_ent_org_data = is_ent_org_data is_ent_supplier = is_ent_supplier ).

    IF lv_keycombination IS INITIAL.
      rv_error = abap_true.

      "mark packaging fee entry as failed
      ir_ent_pckg_fee->set_failed( abap_true ).

      RETURN.
    ENDIF.

    lv_tcode = COND #( WHEN ir_ent_pckg_fee->get_business_process_direction( ) EQ mc_procdir_outbound THEN 'VK12' ELSE 'MEK2' ).
    lv_fee   = COND #( WHEN iv_use_additional_fee EQ abap_true THEN iv_fee_qty ELSE ir_ent_pckg_fee->get_totalfee( ) ).

    APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '0100' dynbegin = 'X' ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ANTA' ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'RV13A-KSCHL' fval = iv_condition_type ) TO lt_bdcdata.
    APPEND VALUE #( program  = 'SAPLV14A' dynpro   = '0100' dynbegin = 'X' ) TO lt_bdcdata.

    CASE lv_keycombination.
      WHEN mc_kc_sales_country.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(01)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(03)' fval = '' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'RV13A999' dynpro   = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003' fval = is_ent_org_data-division ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F004' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F005-LOW' fval = ir_ent_pckg_fee->get_reportcategorycountry( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.
        APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '1999' dynbegin = 'X' ) TO lt_bdcdata.

      WHEN mc_kc_sales_general.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(02)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'RV13A004' dynpro   = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003-LOW' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '1004' dynbegin = 'X' ) TO lt_bdcdata.

      WHEN mc_kc_sales_material.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(03)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(03)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'RV13A005' dynpro   = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F004-LOW' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro = '1005' dynbegin = 'X' ) TO lt_bdcdata.

      WHEN mc_kc_sales_additional.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'RV13A004' dynpro = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-salesorganization ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = is_ent_org_data-distributionchannel ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003-LOW' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'SAPMV13A' dynpro = '1004' dynbegin = 'X' ) TO lt_bdcdata.

      WHEN mc_kc_purch_material.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(01)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = '' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'RV13A018' dynpro   = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_supplier-supplier )  TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = ir_ent_pckg_fee->get_productid( ) )  TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003' fval = determ_purchase_org( is_ent_org_data = is_ent_org_data ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F004-LOW' fval = '0' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '1018' dynbegin = 'X' ) TO lt_bdcdata.

        IF is_ent_supplier-is_excluded_from_report_config = abap_true.
          lv_fee = 0.
        ENDIF.

      WHEN mc_kc_purch_general.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(02)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = '' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(02)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'RV13A049' dynpro   = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = determ_purchase_org( is_ent_org_data = is_ent_org_data ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = '0' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003-LOW' fval = ir_ent_pckg_fee->get_productid( ) )  TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program  = 'SAPMV13A' dynpro   = '1049' dynbegin = 'X' ) TO lt_bdcdata.

      WHEN mc_kc_customer_independent.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'RV13A820' dynpro = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-companycode ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002-LOW' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.
        APPEND VALUE #( program = 'SAPMV13A' dynpro = '1820' dynbegin = 'X' ) TO lt_bdcdata.
      WHEN mc_kc_customer_dependent.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = 'WEIT' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'RV130-SELKZ(01)' fval = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'RV13A971' dynpro = '1000' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F001' fval = is_ent_org_data-companycode ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F002' fval = ir_ent_pckg_fee->get_productid( ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'F003-LOW' fval = iv_customer ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SEL_DATE' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=ONLI' ) TO lt_bdcdata.

        APPEND VALUE #( program = 'SAPMV13A' dynpro = '1971' dynbegin = 'X' ) TO lt_bdcdata.

    ENDCASE.

    APPEND VALUE #( fnam = 'RV13A-DATAB(01)' fval = date_to_external( ir_ent_pckg_fee->get_validfrom( ) ) ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'RV13A-DATBI(01)' fval = date_to_external( ir_ent_pckg_fee->get_validto( ) ) ) TO lt_bdcdata.
    APPEND VALUE #( fnam = 'KONP-KBETR(01)' fval = convert_to_external( iv_data = lv_fee iv_max_decimals = 2 ) ) TO lt_bdcdata.

    IF mv_test_mode = abap_true.
      APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '/EABR' ) TO lt_bdcdata.
    ELSE.
      APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=SICH' ) TO lt_bdcdata.
    ENDIF.

    DATA(lv_mode) = COND #( WHEN mv_test_mode = abap_true THEN 'E' ELSE 'N' ).

    CALL TRANSACTION lv_tcode
           USING lt_bdcdata
           MODE   lv_mode
           MESSAGES INTO lt_bdcmsgcoll.

    IF sy-subrc = 0.
      rv_error = abap_false.
    ELSE.
      rv_error = abap_true.

      "mark packaging fee entry as failed
      ir_ent_pckg_fee->set_failed( abap_true ).
      ir_ent_pckg_fee->set_messages( lt_bdcmsgcoll ).

    ENDIF.

  ENDMETHOD.

  METHOD update_mclass_es_plastictax.

    DATA: lt_characteristics  TYPE /vpcoe/if_pckf_matclass_dac=>gtyt_characteristic_value,
          lv_changenum        TYPE aennr,
          lv_changedesc       TYPE aetxt,
          lv_changenum_exists TYPE abap_bool,
          lv_changenum_valid  TYPE abap_bool,
          lv_error            TYPE abap_bool,
          lv_ecn_date         TYPE c LENGTH 6,
          lt_messages         TYPE /vpcoe/t_uph_msg.

    CLEAR rv_error.

    DATA(ls_extension) = ir_ent_pckg_fee->get_extension( ).
    DATA(lv_reference_quantity) = ir_ent_pckg_fee->get_referencequantity( ).

    CHECK ls_extension IS NOT INITIAL.

    IF lv_reference_quantity <> 0.

      APPEND INITIAL LINE TO lt_characteristics REFERENCE INTO DATA(lr_characteristics).
      lr_characteristics->characteristic = 'ZRDP_ES_PLASTIC'.
      lr_characteristics->value = ls_extension-plasticweightinkg / lv_reference_quantity.
      lr_characteristics->data_type = /vpcoe/if_pckf_matclass_dac=>cs_characteristic_type-num.

      APPEND INITIAL LINE TO lt_characteristics REFERENCE INTO lr_characteristics.
      lr_characteristics->characteristic = 'ZRDP_ES_NONRECYCLED_PLASTIC'.
      lr_characteristics->value = ls_extension-nonrecycledplasticinkg / lv_reference_quantity.
      lr_characteristics->data_type = /vpcoe/if_pckf_matclass_dac=>cs_characteristic_type-num.
    ENDIF.

    LOOP AT ls_extension-exemptions INTO DATA(ls_exemption).
      APPEND INITIAL LINE TO lt_characteristics REFERENCE INTO lr_characteristics.
      lr_characteristics->characteristic = 'ZRDP_ES_EXEMPTION'.
      lr_characteristics->value = ls_exemption-code.
      lr_characteristics->data_type = /vpcoe/if_pckf_matclass_dac=>cs_characteristic_type-char.
    ENDLOOP.

    APPEND INITIAL LINE TO lt_characteristics REFERENCE INTO lr_characteristics.
    lr_characteristics->characteristic = 'ZRDP_ES_PRODORDER_CHECK'.
    IF ls_extension-productionordercheck = abap_true.
      lr_characteristics->value = 'Y'.
    ELSEIF ls_extension-productionordercheck = abap_undefined.
      lr_characteristics->value = ''.
    ELSE.
      lr_characteristics->value = 'N'.
    ENDIF.
    lr_characteristics->data_type = /vpcoe/if_pckf_matclass_dac=>cs_characteristic_type-char.

    APPEND INITIAL LINE TO lt_characteristics REFERENCE INTO lr_characteristics.
    lr_characteristics->characteristic = 'ZRDP_ES_PACKMAT_TAX'.
    lr_characteristics->value = ls_extension-taxforpackagingasmaterial.
    lr_characteristics->data_type = /vpcoe/if_pckf_matclass_dac=>cs_characteristic_type-num.

    DATA(lv_valid_from) = ir_ent_pckg_fee->get_validfrom( ).

    WRITE lv_valid_from TO lv_ecn_date YYMMDD.
    lv_changedesc = |ESPTX_{ lv_ecn_date }|.

    mo_matclass_dac->check_change_number(
      EXPORTING
        iv_description = lv_changedesc
      IMPORTING
        ev_changenum   = lv_changenum
        ev_exists      = lv_changenum_exists
        ev_valid       = lv_changenum_valid
    ).

    IF mv_test_mode = abap_true.
      RETURN.
    ENDIF.

    IF lv_changenum_exists = abap_false.

      mo_matclass_dac->create_change_number(
        EXPORTING
          iv_valid_from  = lv_valid_from
          iv_description = lv_changedesc
          iv_commit      = abap_true
        IMPORTING
          ev_changenum   = lv_changenum
          ev_failed      = lv_error
          et_messages    = lt_messages
      ).

      IF lv_error = abap_true.

        mo_logger->add_messages( lt_messages ).

        "mark packaging fee entry as failed
        ir_ent_pckg_fee->set_failed( abap_true ).

        rv_error = abap_true.
        RETURN.
      ENDIF.

    ELSEIF lv_changenum_valid = abap_false.
      rv_error = abap_true.
      RETURN.
    ENDIF.

    mo_matclass_dac->update_classification(
      EXPORTING
        iv_material        = ir_ent_pckg_fee->get_productid( )
        iv_changenum       = lv_changenum
        iv_class           = 'ZRDP_ES_PLASTICTAX'
        it_characteristics = lt_characteristics
        iv_commit          = abap_true
      IMPORTING
        ev_failed          = lv_error
        et_messages        = lt_messages
    ).

    IF lv_error = abap_true.

      mo_logger->add_messages( lt_messages ).

      "mark packaging fee entry as failed
      ir_ent_pckg_fee->set_failed( abap_true ).

      rv_error = abap_true.
      RETURN.
    ENDIF.

  ENDMETHOD.

  METHOD get_key_combination.

    CLEAR rv_key_combination.

    IF ir_ent_pckg_fee->get_productid( ) IS INITIAL.
      RETURN.
    ENDIF.

    IF ir_ent_pckg_fee->get_validfrom( ) IS INITIAL OR ir_ent_pckg_fee->get_validto( ) IS INITIAL.
      RETURN.
    ENDIF.

    CASE ir_ent_pckg_fee->get_business_process_direction( ).
      WHEN mc_procdir_outbound.

        IF is_ent_org_data IS NOT INITIAL.
          IF iv_condition_type = mc_condition_type_zest OR iv_condition_type = mc_condition_type_zesp.
            rv_key_combination = mc_kc_sales_additional.
            RETURN.
          ENDIF.
          IF iv_condition_type = mc_condition_type_zcon.
            rv_key_combination = mc_kc_customer_independent.
            RETURN.
          ENDIF.
          IF iv_condition_type = mc_condition_type_zese.
            rv_key_combination = mc_kc_customer_dependent.
            RETURN.
          ENDIF.
          IF ir_ent_pckg_fee->get_reportcategorycountry( ) IS NOT INITIAL
              AND is_ent_org_data-distributionchannel IS NOT INITIAL
              AND is_ent_org_data-division IS NOT INITIAL.

            rv_key_combination = mc_kc_sales_country.

          ELSEIF is_ent_org_data-distributionchannel IS NOT INITIAL.

            rv_key_combination = mc_kc_sales_general.

          ENDIF.

        ENDIF.

      WHEN mc_procdir_inbound.

        IF iv_condition_type = mc_condition_type_zcon or iv_condition_type = mc_condition_type_zese.
          rv_key_combination = mc_kc_customer_independent.
          RETURN.
        ENDIF.

        IF is_ent_supplier IS NOT INITIAL.
          rv_key_combination = mc_kc_purch_material.
        ELSE.
          rv_key_combination = mc_kc_purch_general.
        ENDIF.

    ENDCASE.

  ENDMETHOD.

  METHOD date_to_external.
    CLEAR rv_result.

    IF iv_date IS NOT INITIAL.

      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          date_internal = iv_date
        IMPORTING
          date_external = rv_result.

    ENDIF.

  ENDMETHOD.

  METHOD convert_to_external.

    CLEAR rv_result.
    IF iv_data IS NOT INITIAL.
      IF iv_max_decimals IS NOT SUPPLIED.
        WRITE iv_data TO rv_result LEFT-JUSTIFIED NO-GROUPING.
      ELSE.
        WRITE iv_data TO rv_result LEFT-JUSTIFIED NO-GROUPING DECIMALS iv_max_decimals.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD determ_purchase_org.
* Determine purchasing organziation by given company code and lookup into assignment table
    CLEAR rv_result.

    CHECK is_ent_org_data-companycode IS NOT INITIAL.

    SELECT ekorg FROM t024e WHERE bukrs = @is_ent_org_data-companycode INTO TABLE @DATA(lt_t024e).
    IF sy-subrc = 0.
      IF lt_t024e IS NOT INITIAL.
        "return the first assigned purchasing organization
        rv_result = lt_t024e[ 1 ].
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.