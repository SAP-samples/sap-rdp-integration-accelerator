class /VPCOE/CL_PCKCOMP_BOM_EXMPL definition
  public
  inheriting from /VPCOE/CL_UPH_PROC_BASE_BOM
  final
  create public .

public section.

  methods /VPCOE/IF_UPH_ENTITY_BOM_PROC~MAP_BOM_DATA
    redefinition .
protected section.

  types:
    BEGIN OF lty_class,
        class_id TYPE clint,
      END OF lty_class .
  types:
    ltty_class TYPE STANDARD TABLE OF lty_class WITH KEY class_id .

  constants MC_RELEVANT_CLASS_NAME type STRING value 'ZMCL_PACKELEM_ATTR' ##NO_TEXT.
  data MR_TCLA_MULTOBJ type ref to ABAP_BOOL .

  methods MAP_BOM_ITEMS
    importing
      !IT_BOM_ITEMS type /VPCOE/T_UPH_WRAP_BOM_ITEM
      !IV_PREVIOUS_ITEM_AMOUNT type I optional
      !IO_ACT_PACKCOMP type ref to /VPCOE/CL_UPH_ENT_PCKG_CMP_HDR .
  methods IS_VALID_PACKCOMP_ITEM
    importing
      !IV_BOM_MATERIAL type MATNR
      !IV_BOM_MATL_TYPE type MTART
    returning
      value(RV_RESULT) type ABAP_BOOL .
private section.

  methods DETERMINE_MATCLAS_VALIDITY
    importing
      !IV_MATERIAL type MATNR
      !IV_BOM_ITEM_VALID_FROM type DATUV
    returning
      value(RV_RESULT) type DATUV .
ENDCLASS.



CLASS /VPCOE/CL_PCKCOMP_BOM_EXMPL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /VPCOE/CL_PCKCOMP_BOM_EXMPL->/VPCOE/IF_UPH_ENTITY_BOM_PROC~MAP_BOM_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_BOM_DATA                    TYPE        /VPCOE/T_UPH_WRAP_BOM_HDR
* | [<-()] RT_ENTITY_DATA                 TYPE        /VPCOE/UPH_ENTITY_DATA
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD /vpcoe/if_uph_entity_bom_proc~map_bom_data.
    DATA lo_packcomp TYPE REF TO /vpcoe/cl_uph_ent_pckg_cmp_hdr.

    " loop all BOM header data
    LOOP AT it_bom_data INTO DATA(lo_bom_data).

      CLEAR lo_packcomp.

      DATA(ls_cmp_hdr_data) = VALUE /vpcoe/s_uph_ent_pack_cmp_hdr( source = ms_parameters-source_id ).
      ls_cmp_hdr_data-displayid           = |{ lo_bom_data->get_material( ) }-{
                                               lo_bom_data->get_plant( ) }-{
                                               lo_bom_data->get_bom_usage( ) }-{
                                               lo_bom_data->get_bom_alternative_number( ) }-{
                                               lo_bom_data->get_valid_from( ) }|.

      ls_cmp_hdr_data-description         = |{ lo_bom_data->get_material_description( ) }|.
      ls_cmp_hdr_data-basequantity        = lo_bom_data->get_base_amount( ).
      ls_cmp_hdr_data-baseunitofmeasureid = lo_bom_data->get_base_uom( ).
      ls_cmp_hdr_data-consumersalesunit   = lo_bom_data->get_material_base_uom( ).

      DATA(lt_products) = VALUE /vpcoe/t_uph_entity_data( ( NEW /vpcoe/cl_uph_ent_pckg_product(
                                                                      is_data = VALUE #( productid  = lo_bom_data->get_material( )
                                                                                         valid_from = lo_bom_data->get_valid_from( )
                                                                                         valid_to   = lo_bom_data->get_valid_to( )
                                                                                         supplier   = ''
                                                                                         business_process_direction = 'ALL' ) ) ) ).

      lo_packcomp = NEW /vpcoe/cl_uph_ent_pckg_cmp_hdr( is_cmp_hdr_data  = ls_cmp_hdr_data
                                                        it_cmp_item_data = VALUE #( )
                                                        it_products      = lt_products ).

      " map BOM items
      map_bom_items( it_bom_items    = lo_bom_data->get_items( )
                     io_act_packcomp = lo_packcomp ).

      IF lo_packcomp->get_items( ) IS NOT INITIAL.

        INSERT lo_packcomp INTO TABLE rt_entity_data.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method /VPCOE/CL_PCKCOMP_BOM_EXMPL->DETERMINE_MATCLAS_VALIDITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_MATERIAL                    TYPE        MATNR
* | [--->] IV_BOM_ITEM_VALID_FROM         TYPE        DATUV
* | [<-()] RV_RESULT                      TYPE        DATUV
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD determine_matclas_validity.

    TYPES:
      BEGIN OF ltys_datuv,
        datuv TYPE datuv,
      END OF ltys_datuv,
      lty_t_datuv TYPE STANDARD TABLE OF ltys_datuv WITH DEFAULT KEY.

    DATA lt_result TYPE lty_t_datuv.

    "Check if multiple objects is active
    IF mr_tcla_multobj IS NOT BOUND.

      SELECT SINGLE multobj FROM tcla WHERE klart = '001' INTO @DATA(lv_multobj).
      mr_tcla_multobj = NEW abap_bool(  ).
      mr_tcla_multobj->* = lv_multobj.
    ENDIF.

    IF mr_tcla_multobj->* = abap_true.

      SELECT SINGLE cuobj FROM inob
        WHERE klart = '001' AND obtab  = 'MARA' AND objek = @iv_material
      INTO @DATA(lv_internal_matnr).                    "#EC CI_NOORDER

      IF lv_internal_matnr IS NOT INITIAL.
        SELECT DISTINCT ausp~datuv FROM ausp
         INNER JOIN inob ON ausp~objek = inob~cuobj
         INNER JOIN kssk ON kssk~objek = inob~cuobj AND kssk~mafid = 'O' AND kssk~klart = '001'
         INNER JOIN ksml ON ausp~atinn = ksml~imerk AND ksml~lkenz = ''
         INNER JOIN klah ON ksml~clint = klah~clint AND klah~clint = kssk~clint
          WHERE ausp~klart = '001'
             AND ausp~lkenz = ''
             AND ausp~objek = @lv_internal_matnr
             AND klah~class = @mc_relevant_class_name
             AND ausp~datuv <= @iv_bom_item_valid_from
           ORDER BY ausp~datuv DESCENDING
           INTO TABLE @lt_result.
      ENDIF.

    ELSE.

      SELECT DISTINCT ausp~datuv FROM ausp
      INNER JOIN kssk ON kssk~objek = ausp~objek AND kssk~mafid = 'O' AND kssk~klart = '001'
      INNER JOIN ksml ON ausp~atinn = ksml~imerk AND ksml~lkenz = ''
      INNER JOIN klah ON ksml~clint = klah~clint AND klah~clint = kssk~clint
      WHERE ausp~klart = '001'
        AND ausp~lkenz = ''
        AND ausp~objek = @iv_material
        AND klah~class = @mc_relevant_class_name
        AND ausp~datuv <= @iv_bom_item_valid_from
      ORDER BY ausp~datuv DESCENDING
      INTO TABLE @lt_result.

    ENDIF.

    IF lt_result IS NOT INITIAL.
      DATA(lv_datuv) = lt_result[ 1 ]-datuv.
      rv_result = COND #( WHEN lv_datuv = '00000000' THEN '00010101' ELSE lv_datuv ).
    ELSE.
      rv_result = iv_bom_item_valid_from.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method /VPCOE/CL_PCKCOMP_BOM_EXMPL->IS_VALID_PACKCOMP_ITEM
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_BOM_MATERIAL                TYPE        MATNR
* | [--->] IV_BOM_MATL_TYPE               TYPE        MTART
* | [<-()] RV_RESULT                      TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD is_valid_packcomp_item.

    TYPES:
      BEGIN OF ltys_clint,
        clint TYPE clint,
      END OF ltys_clint,
      lty_t_clint TYPE STANDARD TABLE OF ltys_clint WITH DEFAULT KEY.

    DATA: lt_result TYPE lty_t_clint.

    IF iv_bom_matl_type = 'VERP'.

      "Check class type multiple object customizing is active
      IF mr_tcla_multobj IS NOT BOUND.

        SELECT SINGLE multobj FROM tcla WHERE klart = '001' INTO @DATA(lv_multobj).
        mr_tcla_multobj = NEW abap_bool(  ).
        mr_tcla_multobj->* = lv_multobj.
      ENDIF.

      "If yes, set Internal ID from table INOB as matnr.
      IF mr_tcla_multobj->* = abap_true.

        SELECT SINGLE cuobj FROM inob
          WHERE
            klart = '001' AND obtab = 'MARA' AND objek = @iv_bom_material
          INTO @DATA(lv_internal_matnr).                "#EC CI_NOORDER

        IF lv_internal_matnr IS NOT INITIAL.

          SELECT DISTINCT kssk~clint FROM kssk
           INNER JOIN klah ON kssk~clint = klah~clint
           WHERE
            klah~class = @mc_relevant_class_name AND kssk~objek = @lv_internal_matnr
            INTO TABLE @lt_result.
        ENDIF.

      ELSE.

        SELECT DISTINCT kssk~clint FROM kssk
        INNER JOIN klah ON kssk~clint = klah~clint
        WHERE
        klah~class = @mc_relevant_class_name AND kssk~objek = @iv_bom_material
          INTO TABLE @lt_result.

      ENDIF.

      IF lt_result IS NOT INITIAL.
        rv_result = abap_true.
      ELSE.
        rv_result = abap_false.
      ENDIF.
    ELSE.
      rv_result = abap_false.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method /VPCOE/CL_PCKCOMP_BOM_EXMPL->MAP_BOM_ITEMS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_BOM_ITEMS                   TYPE        /VPCOE/T_UPH_WRAP_BOM_ITEM
* | [--->] IV_PREVIOUS_ITEM_AMOUNT        TYPE        I(optional)
* | [--->] IO_ACT_PACKCOMP                TYPE REF TO /VPCOE/CL_UPH_ENT_PCKG_CMP_HDR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD map_bom_items.
    " Recursive mapping of BOM items to packaging compositions and composition components

    LOOP AT it_bom_items INTO DATA(lo_bom_item).

      DATA(lv_item_category) = lo_bom_item->get_item_category( ).
      DATA(lv_material) = lo_bom_item->get_material( ).
      DATA(lv_material_type) = lo_bom_item->get_material_type( ).

      IF lv_item_category <> 'L' OR lv_material IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lt_bom_sub_items) = lo_bom_item->get_items( ).

      IF lt_bom_sub_items IS NOT INITIAL.

        " go map sub BOM items
        map_bom_items( it_bom_items            = lt_bom_sub_items
                       io_act_packcomp         = io_act_packcomp ).
      ELSE.

        IF  is_valid_packcomp_item( iv_bom_material = lo_bom_item->get_material( ) iv_bom_matl_type = lv_material_type ).

          DATA(ls_packcomp_item_data) = VALUE /vpcoe/s_uph_ent_pack_cmp_item( ).

          ls_packcomp_item_data-packagingelementdisplayid = |{ lv_material }|.
          " get the correct material classification assignment valid from date
          DATA(lv_packcomp_item_valid_from) = determine_matclas_validity( iv_material            = lv_material
                                                                          iv_bom_item_valid_from = lo_bom_item->get_item_valid_from( ) ).

          ls_packcomp_item_data-packagingelementversion = |{ lv_packcomp_item_valid_from(4) }-{ lv_packcomp_item_valid_from+4(2) }-{ lv_packcomp_item_valid_from+6(2) }|.

          IF lo_bom_item->is_alternative_item( ).
            ls_packcomp_item_data-quantity = lo_bom_item->get_item_calculated_amount( ) * ( lo_bom_item->get_alt_item_usage_probability( ) / 100 ).
          ELSE.
            ls_packcomp_item_data-quantity = lo_bom_item->get_item_calculated_amount( ).
          ENDIF.

          ls_packcomp_item_data-quantityunitofmeasureid   = lo_bom_item->get_item_uom( ).

          DATA(lv_levelcode)                              = lo_bom_item->get_item_sort_string( ).
          ls_packcomp_item_data-levelcode                 = COND #( WHEN lv_levelcode IS INITIAL
                                                                    THEN '10'
                                                                    ELSE lv_levelcode ).

          ls_packcomp_item_data-eprgroup  = ''.
          ls_packcomp_item_data-wwfgroup  = ''.
          ls_packcomp_item_data-usage     = ''.

          " check dimension of item UoM
          CALL FUNCTION 'DIMENSION_CHECK'
            EXPORTING
              dimid                  = 'AAAADL'
              msehi                  = lo_bom_item->get_item_uom( )
            EXCEPTIONS
              dimension_check_failed = 1
              unit_not_valid         = 2
              OTHERS                 = 3.
          IF sy-subrc = 0.
            " set count since item UoM has no dimension
            ls_packcomp_item_data-count  = lo_bom_item->get_item_amount( ).
          ENDIF.

          DATA(lo_packcomp_item) = NEW /vpcoe/cl_uph_ent_pckg_cmp_itm( is_data = ls_packcomp_item_data ).

          DATA(lt_cmp_item_data) = io_act_packcomp->get_items( ).
          INSERT lo_packcomp_item INTO TABLE lt_cmp_item_data.
          io_act_packcomp->set_items( lt_cmp_item_data ).

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.