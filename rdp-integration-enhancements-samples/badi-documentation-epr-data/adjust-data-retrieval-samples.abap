class /VPCOE/CL_ADJUST_API_EXAMPLE definition
  public
  final
  create public .

public section.

  interfaces /VPCOE/IF_ADJ_DATA_RETRIEVAL .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS /VPCOE/CL_ADJUST_API_EXAMPLE IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_ADJUST_API_EXAMPLE->/VPCOE/IF_ADJ_DATA_RETRIEVAL~ADJUST_BUILD_WHERE_FOR_VARIANT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CODE                        TYPE        /VPCOE/DE_VARIANTS
* | [--->] IV_SRV_GRP                     TYPE        /VPCOE/DE_SERVICE_GROUP
* | [--->] IV_SRV_ID                      TYPE        /VPCOE/DE_SERVICE_ID
* | [--->] IV_API_TYPE                    TYPE        /VPCOE/DE_API_TYPE
* | [--->] IO_LOG                         TYPE REF TO /VPCOE/CL_RDP_LOG
* | [--->] IV_MODE                        TYPE        /VPCOE/DE_MODE
* | [<-->] CV_WHERE                       TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD /vpcoe/if_adj_data_retrieval~adjust_build_where_for_variant.

  IF    iv_api_type = /vpcoe/cl_common_helper=>sc_api_type-rdp
    AND iv_srv_grp  = /vpcoe/cl_common_helper=>sc_grp_id-material_doc
    AND iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-material_doc.

    CASE iv_code.
      WHEN /vpcoe/cl_rdp_material_doc=>sc_variants-gr_prod .
        REPLACE `ms1~shkzg = 'H'` IN cv_where WITH `ms1~shkzg = 'S'`.

      WHEN /vpcoe/cl_rdp_material_doc=>sc_variants-gi_prod.
        cv_where = `ms1~aufnr <> ' ' AND ms1~matnr <> ' ' AND ms1~umwrk = ' ' AND ms1~lifnr =  ' ' AND ms1~` &&
                   `kunnr = ' ' AND ( ms1~shkzg = 'H' AND t156~xstbw = ' ' OR ms1~shkzg = 'S' AND t156~xstbw = 'X' )`.

    ENDCASE.
  ENDIF.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_ADJUST_API_EXAMPLE->/VPCOE/IF_ADJ_DATA_RETRIEVAL~ADJUST_DATA_RETRIEVAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SRV_GRP                     TYPE        /VPCOE/DE_SERVICE_GROUP
* | [--->] IV_SRV_ID                      TYPE        /VPCOE/DE_SERVICE_ID
* | [--->] IV_API_TYPE                    TYPE        /VPCOE/DE_API_TYPE
* | [--->] IS_SEL_OPT                     TYPE        DATA(optional)
* | [--->] IV_LEVEL                       TYPE        /VPCOE/LEVEL(optional)
* | [--->] IV_CODE                        TYPE        /VPCOE/DE_MAT_DOC_VARIANTS(optional)
* | [--->] IO_LOG                         TYPE REF TO /VPCOE/CL_RDP_LOG(optional)
* | [--->] IV_MODE                        TYPE        /VPCOE/DE_MODE(optional)
* | [--->] IV_SESSION_ID                  TYPE        RAW16(optional)
* | [<-->] CT_DATA                        TYPE        DATA
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD /vpcoe/if_adj_data_retrieval~adjust_data_retrieval.

  DATA: lt_data       TYPE /vpcoe/cl_rdp_customer_data=>gty_t_customer,
        lt_data_local TYPE /vpcoe/cl_rdp_customer_data=>gty_t_customer,
        ls_sel_opt    TYPE /vpcoe/cl_rdp_customer_data=>gty_s_sel_opt.

  IF    iv_api_type = /vpcoe/cl_common_helper=>sc_api_type-rdp
    AND iv_srv_grp  = /vpcoe/cl_common_helper=>sc_grp_id-customer
    AND iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-customer
    AND iv_level    = /vpcoe/cl_common_helper=>sc_level-customer.

    DATA: lt_tax_number TYPE /VPCOE/TT_TAX_NUMBER.

    lt_data = ct_data.

    "select available tax number in systrem and base note 775919.
    SELECT tfktaxnumtype_t~taxtype, text
        FROM tfktaxnumtype_t
        INNER JOIN /vpcoe/taxnumtyp ON tfktaxnumtype_t~taxtype = /vpcoe/taxnumtyp~taxtype
        WHERE spras = 'E'
        INTO TABLE @DATA(lt_tax).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      IF <ls_data>-name CN 'SAP'.
        <ls_data>-name =  <ls_data>-name && '/VPCoE'.
      ENDIF.

      IF <ls_data>-house_number IS INITIAL AND <ls_data>-street IS NOT INITIAL.
        SPLIT <ls_data>-street AT space INTO <ls_data>-house_number <ls_data>-street.
      ENDIF.

      IF <ls_data>-contact_person_first_name IS INITIAL AND <ls_data>-id = 'TEST_CS_VS' OR <ls_data>-id = 'TESTBPDR'.
        <ls_data>-contact_person_first_name = 'Sap'.
      ENDIF.

      IF <ls_data>-contact_person_last_name IS INITIAL AND <ls_data>-id = 'TEST_CS_VS' OR <ls_data>-id = 'TESTBPDR'.
        <ls_data>-contact_person_first_name = 'Admin'.
      ENDIF.

      CLEAR: lt_tax_number.

      Loop at <ls_data>-tax_numbers ASSIGNING FIELD-SYMBOL(<ls_tax_number>).
        IF NOT line_exists( lt_tax[ taxtype = <ls_tax_number>-tax_number_type ] ).
            CONTINUE.
        ENDIF.
        lt_tax_number = VALUE #( BASE lt_tax_number ( <ls_tax_number> ) ).
      ENDLOOP.

      <ls_data>-tax_numbers = lt_tax_number.

    ENDLOOP.

    ct_data = lt_data.

  ELSEIF  iv_api_type = /vpcoe/cl_common_helper=>sc_api_type-rdp
      AND iv_srv_grp  = /vpcoe/cl_common_helper=>sc_grp_id-delivery
      AND iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-delivery
      AND iv_level    = /vpcoe/cl_common_helper=>sc_level-dlvr_bckgrnd.

    DATA: ls_sel_opt_del     TYPE /vpcoe/s_selopt_delivery,
          lv_ship_to_party   TYPE string,
          lv_where_for_dates TYPE string,
          lt_delivery        TYPE   /vpcoe/t_delivery_hdr,
          lv_package_size    TYPE /vpcoe/de_package_size.

    lv_package_size = '2147483647'.

    CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
      EXPORTING
        input  = 'SH'
      IMPORTING
        output = lv_ship_to_party.

    IF ls_sel_opt-crt_date IS NOT INITIAL AND ls_sel_opt_del-chng_date IS INITIAL.
      lv_where_for_dates  =  '( likp~erdat IN @is_sel_opt-crt_date )'.
    ELSEIF ls_sel_opt_del-crt_date IS INITIAL AND ls_sel_opt_del-chng_date IS NOT INITIAL.
      lv_where_for_dates =  '( likp~aedat IN @is_sel_opt-chng_date )'.
    ELSE.
      lv_where_for_dates =  '( likp~erdat IN @is_sel_opt-crt_date OR likp~aedat IN @is_sel_opt-chng_date )'.
    ENDIF.

    MOVE-CORRESPONDING is_sel_opt TO ls_sel_opt_del.

    SELECT DISTINCT likp~vbeln     AS id,
                likp~lfart     AS type,
                likp~vkorg     AS sales_organization,
                likp~kunnr     AS ship_to_party,
                likp~erdat     AS create_date,
                likp~aedat     AS change_date,
                likp~wadat_ist AS actual_goods_movement_date,
                likp~inco1     AS incoterms,
                CASE WHEN adrc~country IS NOT NULL THEN adrc~country
                ELSE CASE WHEN kna1~land1 IS NOT NULL THEN kna1~land1
                ELSE kna_sh~land1 END
                END AS ship_to_country,
                CASE WHEN adrc~region  IS NOT NULL THEN adrc~region
                ELSE CASE WHEN kna1~regio IS NOT NULL THEN kna1~regio
                ELSE kna_sh~regio END
                END AS ship_to_region
            FROM likp JOIN vbuk ON likp~vbeln = vbuk~vbeln
                       LEFT JOIN lips ON likp~vbeln = lips~vbeln
                       LEFT JOIN kna1 ON likp~kunnr = kna1~kunnr
                       LEFT JOIN kna1 AS kna_sh ON likp~kunag = kna1~kunnr
                      JOIN vbpa ON likp~vbeln = vbpa~vbeln
                      JOIN adrc ON vbpa~adrnr = adrc~addrnumber
               WHERE likp~lfart    IN @ls_sel_opt_del-document_type
                AND likp~vkorg     IN @ls_sel_opt_del-sales_org
                AND likp~kunnr     IN @ls_sel_opt_del-ship_to_party
                AND likp~vbeln     IN @ls_sel_opt_del-vbeln
                AND adrc~country   IN @ls_sel_opt_del-country
                AND adrc~region    IN @ls_sel_opt_del-region
                AND likp~wadat_ist IN @ls_sel_opt_del-actual_goods_movement_date
                AND (lv_where_for_dates)
                AND (    ( likp~vbtyp = 'J' AND vbpa~parvw  = @lv_ship_to_party )
                      OR ( likp~vbtyp = 'T' AND vbpa~parvw  = @lv_ship_to_party )
                      OR ( likp~vbtyp <> 'J' AND likp~vbtyp <> 'T' ) )
                AND likp~spe_loekz = @abap_false
         INTO CORRESPONDING FIELDS OF TABLE @lt_delivery
           CONNECTION r/3*rdp
                PACKAGE SIZE @lv_package_size.
    ENDSELECT.

    ct_data = lt_delivery.

  ELSEIF  iv_api_type = /vpcoe/cl_common_helper=>sc_api_type-rdp
*  AND iv_srv_grp  = /VPCOE/CL_rdp_CUSTOM_HELPER=>sc_grp_id-pfm_inventory
  AND iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-inventory.

    DATA: ls_sel_opt_inv TYPE /vpcoe/s_selopt_inventory,
          lt_inventory   TYPE  /vpcoe/cl_rdp_inventory=>gty_t_stock_data_rdp,
          lt_stocks      TYPE STANDARD TABLE OF /vpcoe/inventory,
          lt_bukrs       TYPE TABLE OF t001k,
          lt_mara        TYPE TABLE OF mara.

    MOVE-CORRESPONDING is_sel_opt TO ls_sel_opt_inv.

    SELECT plant,
       product,
       productgroup,
       companycode,
       SUM( stockquantityinbaseunit ) AS stockquantityinbaseunit,
       baseunitofmeasure,
       calendarmonth,
       calendaryear
  FROM /vpcoe/inventory
    INTO CORRESPONDING FIELDS OF TABLE @lt_stocks
      WHERE uname = @sy-uname
      AND productgroup IN @ls_sel_opt_inv-prod_gr
    GROUP BY plant, product, productgroup, companycode, baseunitofmeasure, calendarmonth, calendaryear.

    IF sy-subrc = 0.
      lt_inventory = VALUE #( FOR <ls_stock> IN lt_stocks ( plant                       = <ls_stock>-plant
                                                            product                     = <ls_stock>-product
                                                            company_code                = <ls_stock>-companycode
                                                            stock_quantity_in_base_unit = <ls_stock>-stockquantityinbaseunit
                                                            base_unit_of_measure        = <ls_stock>-baseunitofmeasure
                                                            period-calendar_month       = <ls_stock>-calendarmonth
                                                            period-calendar_year        = <ls_stock>-calendaryear ) ).
    ENDIF.

  ELSEIF iv_srv_grp      = /vpcoe/cl_rdp_helper=>sc_grp_id-material_doc
         AND iv_api_type = /vpcoe/cl_common_helper=>sc_api_type-rdp
         AND iv_srv_id   = /vpcoe/cl_rdp_helper=>sc_service_id-material_doc
         AND iv_level    = /vpcoe/cl_rdp_helper=>sc_level-hdr.

    DATA: lt_material_document TYPE /vpcoe/cl_rdp_material_doc=>gty_t_material_data.

    DATA(lo_mat_doc_cust) = NEW /vpcoe/cl_rdp_helper( iv_api_type = iv_api_type
                                                      iv_srv_grp  = iv_srv_grp
                                                      iv_srv_id   = iv_srv_id ).

    DATA(lo_mat_doc_handler) = NEW /vpcoe/cl_rdp_material_doc( iv_package_size = lo_mat_doc_cust->get_package_size( )
                                                          iv_source       = lo_mat_doc_cust->get_source_id( )
                                                          iv_api_type     = iv_api_type ).

    DATA: ls_mat_doc_sel_opt TYPE /vpcoe/s_selopt_mat_doc,
          lo_structure_type  TYPE REF TO cl_abap_structdescr.


    lo_structure_type ?= cl_abap_typedescr=>describe_by_data( is_sel_opt ).

    IF lo_structure_type->absolute_name = '\TYPE=/VPCOE/S_SELOPT_MAT_DOC'.

      ls_mat_doc_sel_opt = is_sel_opt.

      SELECT DISTINCT
            ms1~mblnr      AS id,
            ms1~zeile      AS item,
            ms1~line_id    AS line,
            ms1~mjahr      AS year,
            ms1~budat_mkpf AS posting_date,
            ms1~cpudt_mkpf AS creation_date,
            ms1~cputm_mkpf AS creation_time,
            ms1~werks      AS plant,
            ms1~lgort      AS lgort,
            ms1~umwrk      AS issuing_or_receiving_plant,
            ms1~matbf      AS stock_material,
            ms1~sobkz      AS inventory_stock_type,
            ms1~bukrs      AS company_code,
            ms1~meins      AS base_unit_of_measure,
            ms1~menge      AS quantity_in_base_unit,
            CASE WHEN ms1~shkzg = 'H' THEN - ms1~menge
                                      ELSE ms1~menge
                       END AS materialstockchangeqtybaseunit,
            ms1~erfme      AS entry_unit,
            ms1~erfmg      AS quantity_in_entry_unit,
            ms1~lfbnr      AS invtry_mgmt_reference_document,
            ms1~xblnr_mkpf AS reference_document,
            ms1~kdauf      AS sales_order,
            ms1~ebeln      AS purchase_order,
            ms1~aufnr      AS production_order,
            ms1~vbeln_im   AS delivery,
            ms1~bwart      AS goods_movement_type,
            ms1~matnr      AS product,
            ms1~ummat      AS issg_or_rcvg_product_id,
            ms1~charg      AS batch,
            ms1~hsdat      AS manufacture_date,
            ms1~umcha      AS issg_or_rcvg_batch_id,
            ms1~lifnr      AS supplier,
            ms1~kunnr      AS customer,
            ms1~wempf      AS goods_recipient_name,
            ms1~kzbew      AS reference_document_type,
            ms1~vgart_mkpf AS transaction_type,
            ms1~umlgo      AS storage_location,
            ms1~shkzg      AS deb_cred_ind, """"
            CASE
              WHEN ms1~shkzg = 'S' AND t156~xstbw = ' ' OR ms1~shkzg = 'H' AND t156~xstbw = 'X' THEN 'GR'
              WHEN ms1~shkzg = 'H' AND t156~xstbw = ' ' OR ms1~shkzg = 'S' AND t156~xstbw = 'X' THEN 'GI'
                       END AS stock_change_category,
            CASE
              WHEN ms1~umwrk <> ' ' AND ms1~umwrk <> ms1~werks THEN 'T' ELSE 'F'
                       END AS is_cross_plant_transfer,
           CASE WHEN t156~xstbw = 'X' THEN 'X'
                                       ELSE '-'
                       END AS is_reversal_movement_type,
            bkpf~blart     AS accounting_document_type,
            adrc~country   AS ship_to_country,
            adrc~region    AS ship_to_region,
            ekpo~ebelp     AS ebelp,
            ekpo~adrnr     AS address,
            ekpo~pstyp     AS category,
            ekko~lifnr     AS vendor_acc_number,
            ekko~llief     AS goods_supplier,
            CASE
              WHEN ekpo~inco1 <> ' ' THEN ekpo~inco1 ELSE ekko~inco1
                       END AS incoterms,
            ekko~reswk AS supplying_or_issuing_plant,
            @iv_code AS logistic_process
         INTO CORRESPONDING FIELDS OF TABLE @lt_material_document
          CONNECTION r/3*rdp
          FROM mseg AS ms1
            LEFT JOIN t156  ON ms1~bwart = t156~bwart
            LEFT JOIN bkpf  ON ms1~mblnr = bkpf~belnr
            LEFT JOIN lfa1  ON ms1~lifnr = lfa1~lifnr
            LEFT JOIN kna1  ON ms1~kunnr = kna1~kunnr
            LEFT JOIN ekpo  ON ms1~ebeln = ekpo~ebeln AND ms1~ebelp = ekpo~ebelp
            LEFT JOIN ekko  ON ms1~ebeln = ekko~ebeln
            LEFT JOIN adrc  ON ekpo~adrnr = adrc~addrnumber AND ekpo~adrnr <> ''.
*               WHERE ms1~mblnr    IN @ls_mat_doc_sel_opt-matid
*                 AND ms1~mjahr    IN @ls_mat_doc_sel_opt-material_doc_year
*                 AND ms1~budat_mkpf IN @ls_mat_doc_sel_opt-posting_date.

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      lo_mat_doc_handler->adjust_header(
        EXPORTING
          it_r_country         = ls_mat_doc_sel_opt-country
          iv_code              = iv_code
        CHANGING
          ct_material_document = lt_material_document ).

      ct_data = lt_material_document.
    ENDIF.
  ENDIF.

  SELECT bukrs, bwkey
    FROM t001k
      FOR ALL ENTRIES IN @lt_inventory
        WHERE bwkey = @lt_inventory-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_bukrs.
  IF sy-subrc <> 0.
    CLEAR lt_bukrs.
  ENDIF.

  LOOP AT lt_inventory ASSIGNING FIELD-SYMBOL(<ls_inventory>).
    <ls_inventory>-company_code = VALUE #( lt_bukrs[ bwkey = <ls_inventory>-plant ]-bukrs OPTIONAL ).
  ENDLOOP.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_ADJUST_API_EXAMPLE->/VPCOE/IF_ADJ_DATA_RETRIEVAL~ADJUST_JSON
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SRV_GRP                     TYPE        /VPCOE/DE_SERVICE_GROUP
* | [--->] IV_SRV_ID                      TYPE        /VPCOE/DE_SERVICE_ID
* | [--->] IV_API_TYPE                    TYPE        /VPCOE/DE_API_TYPE
* | [--->] IO_LOG                         TYPE REF TO /VPCOE/CL_RDP_LOG(optional)
* | [--->] IV_LEVEL                       TYPE        /VPCOE/LEVEL(optional)
* | [<-->] CT_JSON                        TYPE        /VPCOE/CL_RDP_HTTP=>GTY_T_JSON
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD /vpcoe/if_adj_data_retrieval~adjust_json.

  IF    iv_api_type = /vpcoe/cl_common_helper=>sc_api_type-rdp
    AND iv_srv_grp  = /vpcoe/cl_common_helper=>sc_grp_id-customer
    AND iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-customer.

    LOOP AT ct_json ASSIGNING FIELD-SYMBOL(<ls_json>).
      REPLACE ALL OCCURRENCES OF ':""' IN <ls_json>-elements WITH ': null'.
    ENDLOOP.
  ENDIF.

  IF    iv_api_type = /vpcoe/cl_common_helper=>sc_api_type-rdp
    AND iv_srv_grp  = /vpcoe/cl_common_helper=>sc_grp_id-product
    AND iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-product_ext.

    LOOP AT ct_json ASSIGNING <ls_json>.
      IF iv_srv_id = /vpcoe/cl_common_helper=>sc_service_id-product_ext.
        REPLACE ALL OCCURRENCES OF '"isHazardousClpEu":""' IN <ls_json>-elements WITH '"isHazardousClpEu": false'.
        REPLACE ALL OCCURRENCES OF '"isHazardousClpEu":"X"' IN <ls_json>-elements WITH '"isHazardousClpEu": true'.
        REPLACE ALL OCCURRENCES OF '"hasNoPackaging":"X"' IN <ls_json>-elements WITH '"hasNoPackaging": true'.
        REPLACE ALL OCCURRENCES OF '"hasNoPackaging":""' IN <ls_json>-elements WITH '"hasNoPackaging": false'.
      ENDIF.

      REPLACE ALL OCCURRENCES OF ':""' IN <ls_json>-elements WITH ': null'.

    ENDLOOP.
  ENDIF.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_ADJUST_API_EXAMPLE->/VPCOE/IF_ADJ_DATA_RETRIEVAL~ADJUST_MAPPING
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SRV_GRP                     TYPE        /VPCOE/DE_SERVICE_GROUP
* | [--->] IV_SRV_ID                      TYPE        /VPCOE/DE_SERVICE_ID
* | [--->] IS_DATA                        TYPE        DATA
* | [--->] IV_API_TYPE                    TYPE        /VPCOE/DE_API_TYPE
* | [--->] IO_LOG                         TYPE REF TO /VPCOE/CL_RDP_LOG(optional)
* | [<-->] CS_DATA                        TYPE        DATA
* +--------------------------------------------------------------------------------------</SIGNATURE>
 METHOD /vpcoe/if_adj_data_retrieval~adjust_mapping.

   IF    iv_api_type = /vpcoe/cl_common_helper=>sc_api_type-rdp
     AND iv_srv_grp  = /vpcoe/cl_common_helper=>sc_grp_id-configuration
     AND iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-uom.

     ASSIGN COMPONENT 'IS_COMMERCIAL' OF STRUCTURE is_data TO FIELD-SYMBOL(<lv_src_value>).
     IF <lv_src_value> IS ASSIGNED.

       ASSIGN COMPONENT 'COMMERCIAL_FLAG' OF STRUCTURE cs_data TO FIELD-SYMBOL(<lv_trg_value>).
       IF <lv_trg_value> IS ASSIGNED.
         <lv_trg_value> = <lv_src_value>.
       ENDIF.

     ENDIF.
   ENDIF.

 ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_ADJUST_API_EXAMPLE->/VPCOE/IF_ADJ_DATA_RETRIEVAL~ADJUST_TEXT_MAPPING
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SRV_GRP                     TYPE        /VPCOE/DE_SERVICE_GROUP
* | [--->] IV_SRV_ID                      TYPE        /VPCOE/DE_SERVICE_ID
* | [--->] IT_DATA                        TYPE        DATA
* | [--->] IV_API_TYPE                    TYPE        /VPCOE/DE_API_TYPE
* | [--->] IO_LOG                         TYPE REF TO /VPCOE/CL_RDP_LOG(optional)
* | [<-->] CT_DATA                        TYPE        ANY TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD /vpcoe/if_adj_data_retrieval~adjust_text_mapping.
  DATA: lt_target_data TYPE /vpcoe/cl_rdp_config_obj=>gty_t_uom_t.

  IF    iv_api_type = /vpcoe/cl_common_helper=>sc_api_type-rdp
    AND iv_srv_grp  = /vpcoe/cl_common_helper=>sc_grp_id-configuration
    AND iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-uom.

    lt_target_data = ct_data.
    LOOP AT lt_target_data ASSIGNING FIELD-SYMBOL(<ls_trg_data>).
      <ls_trg_data>-commercial_name = <ls_trg_data>-commercial_name && '/VPCoe'.
    ENDLOOP.

    ct_data = lt_target_data.
  ENDIF.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_ADJUST_API_EXAMPLE->/VPCOE/IF_ADJ_DATA_RETRIEVAL~DEFINE_MOVEMENT_TYPE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CODE                        TYPE        /VPCOE/DE_MAT_DOC_VARIANTS
* | [<-->] CT_MOVEMENT_TYPES              TYPE        /VPCOE/CL_RDP_MATERIAL_DOC=>GTY_T_MOVEMENT_TYPES
* | [<-->] CT_STOCK_CHANGE_CAT            TYPE        /VPCOE/CL_RDP_MATERIAL_DOC=>GTY_T_MOVEMENT_TYPES
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD /vpcoe/if_adj_data_retrieval~define_movement_type.
*    "Definition of specific movement types for each variant.
*    DATA: lo_mat_doc TYPE REF TO /vpcoe/cl_rdp_material_doc,
*          lo_cust    TYPE REF TO /vpcoe/cl_rdp_helper.
*
*    lo_cust = NEW /vpcoe/cl_rdp_helper( iv_api_type = /vpcoe/cl_common_helper=>sc_api_type-rdp
*                                        iv_srv_grp  = /vpcoe/cl_common_helper=>sc_grp_id-material_doc
*                                        iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-material_doc ).
*
*    lo_mat_doc = NEW /vpcoe/cl_rdp_material_doc( iv_api_type     = /vpcoe/cl_rdp_helper=>sc_api_type-rdp
*                                                 iv_package_size = lo_cust->get_package_size( )
*                                                 iv_source       = lo_cust->get_source_id( ) ).
*    CASE iv_code.
*      WHEN lo_mat_doc->sc_variants-gr_st.
*        "Types that can be for a particular variant.
*        ct_movement_types = VALUE #( ( sign = 'I' option = 'EQ' low = 'z305' )
*                                    ( sign = 'I' option = 'EQ' low = 'z303' )
*                                    ( sign = 'I' option = 'EQ' low = 'z301' ) ).
*
*        "Types that have different behavior for determining stockChangeCategory.
*        ct_stock_change_cat = VALUE #( ( sign = 'I' option = 'EQ' low = 'z305' ) ).
*
*      WHEN lo_mat_doc->sc_variants-gi_st.
*        ct_movement_types = VALUE #( ( sign = 'I' option = 'EQ' low = '303' )
*                                    ( sign = 'I' option = 'EQ' low = '301' )  ).
*    ENDCASE.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_ADJUST_API_EXAMPLE->/VPCOE/IF_ADJ_DATA_RETRIEVAL~GET_EXT_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_API_TYPE                    TYPE        /VPCOE/DE_API_TYPE
* | [--->] IV_SRV_GRP                     TYPE        /VPCOE/DE_SERVICE_GROUP
* | [--->] IV_SRV_ID                      TYPE        /VPCOE/DE_SERVICE_ID
* | [--->] IS_SEL_OPT                     TYPE        DATA
* | [--->] IT_DATA                        TYPE        DATA(optional)
* | [--->] IV_MODE                        TYPE        /VPCOE/DE_MODE(optional)
* | [--->] IO_LOG                         TYPE REF TO /VPCOE/CL_RDP_LOG(optional)
* | [<-->] CT_EXT_DATA                    TYPE        DATA
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD /vpcoe/if_adj_data_retrieval~get_ext_data.

  DATA: lt_customer_data TYPE /vpcoe/cl_rdp_customer_data=>gty_t_customer,
        lt_suplier_data  TYPE /vpcoe/cl_rdp_supplier_data=>gty_t_supplier,
        lt_product_data  TYPE /vpcoe/cl_rdp_product_data=>gty_t_product_combined.

  DATA: lv_objek               TYPE ausp-objek,
        lt_char_value          TYPE TABLE OF clobjdat,
        lt_class               TYPE TABLE OF sclass,
        lt_product_ext_country TYPE /vpcoe/tt_product_countries.

  FIELD-SYMBOLS: <lt_customer_ext> TYPE /vpcoe/t_customer_ext,
                 <lt_supplier_ext> TYPE /vpcoe/t_supplier_ext,
                 <lt_product_ext>  TYPE /vpcoe/tt_product_ext.

  IF iv_api_type <> /vpcoe/cl_common_helper=>sc_api_type-rdp.
    RETURN.
  ENDIF.

  CASE iv_srv_grp.
    WHEN /vpcoe/cl_common_helper=>sc_grp_id-customer.
      IF iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-customer_ext.
        lt_customer_data = it_data.
        ASSIGN ct_ext_data TO <lt_customer_ext>.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT lt_customer_data ASSIGNING FIELD-SYMBOL(<ls_customer_data>).
          READ TABLE <lt_customer_ext> ASSIGNING FIELD-SYMBOL(<ls_customer_ext>) WITH KEY id = <ls_customer_data>-id.
          IF sy-subrc <> 0.
            APPEND INITIAL LINE TO <lt_customer_ext> ASSIGNING <ls_customer_ext>.
          ENDIF.

          lv_objek = <ls_customer_ext>-id.

          CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
            EXPORTING
              classtext          = 'X'
              classtype          = '011'
              features           = 'X'
              language           = sy-langu
              object             = lv_objek
              key_date           = sy-datum
              initial_charact    = 'X'
              change_service_clf = 'X'
            TABLES
              t_class            = lt_class
              t_objectdata       = lt_char_value
            EXCEPTIONS
              no_classification  = 1.

          IF sy-subrc <> 0.
            " Nothing to do
          ENDIF.

          <ls_customer_ext>-id   =  <ls_customer_data>-id.
          <ls_customer_ext>-tag  = VALUE #( lt_char_value[ atnam = 'ZRDP_CUST_EXT_ROLE' ]-ausp1 OPTIONAL ).
          <ls_customer_ext>-role = VALUE #( lt_char_value[ atnam = 'ZRDP_PROD_EXT_TAG' ]-ausp1 OPTIONAL ).

        ENDLOOP.
      ENDIF.

    WHEN /vpcoe/cl_common_helper=>sc_grp_id-product.
      IF iv_srv_id   = /vpcoe/cl_common_helper=>sc_service_id-product_ext.
        lt_product_data = it_data.
        ASSIGN ct_ext_data TO <lt_product_ext>.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT lt_product_data ASSIGNING FIELD-SYMBOL(<ls_product_data>).
          READ TABLE <lt_product_ext> ASSIGNING FIELD-SYMBOL(<ls_product_ext>) WITH KEY id = <ls_product_data>-id.
          IF sy-subrc <> 0.
            APPEND INITIAL LINE TO <lt_product_ext> ASSIGNING <ls_product_ext>.
          ENDIF.
          lv_objek = <ls_product_data>-id.

          CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
            EXPORTING
              classtext          = 'X'
              classtype          = '001'
              features           = 'X'
              language           = sy-langu
              object             = lv_objek
              key_date           = sy-datum
              initial_charact    = 'X'
              change_service_clf = 'X'
            TABLES
              t_class            = lt_class
              t_objectdata       = lt_char_value
            EXCEPTIONS
              no_classification  = 1.

          IF sy-subrc <> 0.
            " Nothing to do
          ENDIF.

          <ls_product_ext>-id                       =  <ls_product_data>-id.
          <ls_product_ext>-brand                    = VALUE #( lt_char_value[ atnam = 'ZRDP_PROD_EXT_BRAND' ]-ausp1 OPTIONAL ).
          IF <ls_product_ext>-brand IS INITIAL.
            <ls_product_ext>-brand = ''.
          ENDIF.

          <ls_product_ext>-has_no_packaging         = COND #( WHEN VALUE #( lt_char_value[ atnam = 'ZRDP_PROD_EXT_NOPACK' ]-ausp1 OPTIONAL ) IS INITIAL
                                                                      THEN abap_true
                                                                      ELSE abap_false ) .
*          <ls_product_ext>-is_dg_product_eu         = abap_true.
          <ls_product_ext>-is_hazardous_clp_eu      = abap_false.
          <ls_product_ext>-product_content          = VALUE #( lt_char_value[ atnam = 'ZRDP_PROD_EXT_CONTENT' ]-ausp1 OPTIONAL ).
          IF <ls_product_ext>-product_content IS INITIAL.
            CASE <ls_product_data>-product_group.
              WHEN ' '.
                <ls_product_ext>-product_content = 'BEV_ALC_BE'.
              WHEN '01'.
                <ls_product_ext>-product_content = 'MED_DEVICE'.
              WHEN '02'.
                <ls_product_ext>-product_content = 'NONFOOD'.
              WHEN 'YBD01'.
                <ls_product_ext>-product_content = 'FOOD_DIR'.
              WHEN 'YBZ01'.
                <ls_product_ext>-product_content = 'FOOD_MED'.
              WHEN OTHERS.
                <ls_product_ext>-product_content = 'BEV_WATER'.
            ENDCASE.
          ENDIF.

          <ls_product_ext>-reference_quantity       = VALUE #( lt_char_value[ atnam = 'ZRDP_PROD_EXT_REFQTY' ]-ausp1 OPTIONAL ).
          <ls_product_ext>-product_type_harmonized  = VALUE #( lt_char_value[ atnam = 'ZRDP_PROD_EXT_PTHARM' ]-ausp1 OPTIONAL ).
          IF <ls_product_ext>-product_type_harmonized IS INITIAL.
            <ls_product_ext>-product_type_harmonized = 'PACKMAT'.
          ENDIF.

          READ TABLE lt_product_ext_country INTO DATA(ls_product_ext_country) INDEX 1.
          IF sy-subrc <> 0.
            ls_product_ext_country-country = VALUE #( lt_char_value[ atnam = 'ZRDP_PROD_CNTRY_CNTRY' ]-ausp1 OPTIONAL ).
            IF ls_product_ext_country-inhouse_production_percent >= 0 AND ls_product_ext_country-inhouse_production_percent <= 100.
              ls_product_ext_country-inhouse_production_percent = '50'.
            ELSE.
              CLEAR ls_product_ext_country-inhouse_production_percent.
            ENDIF.
          ENDIF.
          ls_product_ext_country-country             = 'DE'.
          ls_product_ext_country-epr_product_family  = 'id3'.
          ls_product_ext_country-valid_from          = sy-datum.
          ls_product_ext_country-is_not_epr_relevant = abap_false.
          ls_product_ext_country-tag                 = 'IYSIUY765H'.
          ls_product_ext_country-has_deposit         = abap_true.
          APPEND ls_product_ext_country TO lt_product_ext_country.
          <ls_product_ext>-product_countries = lt_product_ext_country.
        ENDLOOP.
      ENDIF.

  ENDCASE.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_ADJUST_API_EXAMPLE->/VPCOE/IF_ADJ_DATA_RETRIEVAL~SKIP_SELECTION
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SRV_GRP                     TYPE        /VPCOE/DE_SERVICE_GROUP
* | [--->] IV_SRV_ID                      TYPE        /VPCOE/DE_SERVICE_ID
* | [--->] IV_API_TYPE                    TYPE        /VPCOE/DE_API_TYPE
* | [--->] IV_LEVEL                       TYPE        /VPCOE/LEVEL(optional)
* | [--->] IS_SEL_OPT                     TYPE        DATA(optional)
* | [--->] IO_LOG                         TYPE REF TO /VPCOE/CL_RDP_LOG(optional)
* | [--->] IV_MODE                        TYPE        /VPCOE/DE_MODE(optional)
* | [--->] IV_CODE                        TYPE        /VPCOE/DE_MAT_DOC_VARIANTS(optional)
* | [<-->] CV_SKIP                        TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD /vpcoe/if_adj_data_retrieval~skip_selection.
  DATA: ls_sel_opt TYPE /vpcoe/cl_rdp_customer_data=>gty_s_sel_opt.

*  IF    iv_api_type = /vpcoe/cl_rdp_helper=>sc_api_type-rdp
*    AND iv_srv_grp  = /vpcoe/cl_rdp_helper=>sc_grp_id-delivery
*    AND iv_srv_id   = /vpcoe/cl_rdp_helper=>sc_service_id-delivery.
*
*    cv_skip = abap_true.
*
*    elseIF
IF  iv_api_type = /vpcoe/cl_rdp_helper=>sc_api_type-rdp
    AND iv_srv_grp  = /vpcoe/cl_rdp_helper=>sc_grp_id-INVENTORY
    AND iv_srv_id   = /vpcoe/cl_rdp_helper=>sc_service_id-inventory.

    cv_skip = abap_true.
*
*    elseIF    iv_api_type = /vpcoe/cl_rdp_helper=>sc_api_type-rdp
*    AND iv_srv_grp  = /vpcoe/cl_rdp_helper=>sc_grp_id-material_doc
*    AND iv_srv_id   = /vpcoe/cl_rdp_helper=>sc_service_id-material_doc.
*
*    cv_skip = abap_true.
 ENDIF.

ENDMETHOD.
ENDCLASS.