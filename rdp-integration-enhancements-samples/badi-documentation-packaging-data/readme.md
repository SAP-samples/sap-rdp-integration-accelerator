/VPCOE/BADI_UPH_CUSTOM

\___\___\___\___\___\___\___\___\___\___\___\___\___\___\___\___\____

Use

The Business Add-In (BAdI) /VPCOE/BADI_UPH_CUSTOM that is assigned to Enhancement Spot /VPCOE/BADI_UPH_CUSTOM is used during the upload of packaging related data to the API of SAP Responsible Design and Production (RDP). Its main task is to provide an extensibility mechanism to integrate customer specific implementations for extracting and processing of packaging related data.

This packaging related data is in the following called Upload Entity. An Upload Entity consists of:

· An RDP business object, for example, a packaging element with all its defined child nodes, such as, packaging fractions, product assignments and so on.

· The area of extraction, for example, Plant Maintenance (PLM) or Recipe Development (RD).

The following Upload Entities are currently defined in the system:

· PE_PLM: Packaging elements from PLM

· PC_PLM: Packaging compositions from PLM

· PC_RCP: Packaging compositions from Recipe Development

· PC_BOM: Packaging compositions from Bill of Material (BOM)

· PE_MCL: Packaging elements from Material Classification

· PCI_HU: Extract Packaging Composition Items from Handling Units

For each Upload Entity there is a corresponding report to start the data upload.

When one of these reports is executed, the mentioned BAdI is called. As a result of the call, an instance of a customer specific implementation for the extraction and processing of the Upload Entity data must be returned. This instance is called Upload Entity Processor.

Requirements

· To be able to upload packaging element or packaging composition data from PLM the according data must exist in the Environment, Health, and Safety specification database.

· For the upload of packaging composition data from recipe development the according data must exist in the Recipe Development.

· For the upload of packaging composition data from Bill of Material the according data must exist in Bill of Materials.

· For the upload of packaging element data from Material Classification the according data must exist in the classification of the material master data.

· An Upload Entity Processor implementation for the respective Upload Entity exists in the system.

· The BAdI is implemented and provides the Upload Entity Processor instance, see the provided example implementation of the BAdI.

· The RFC destination and the OAuth configuration are maintained in the system to access the RDP Push API.

For more information about the standard settings for this BAdI, such as filters, single or multiple uses, see the Spot Element Definitions tab in the BAdI Builder (transaction SE18).

BAdi Methods

The BAdI definition is active in the Integration accelerator package. It contains the following methods from interface /VPCOE/IF_UPH_CUSTOM:

· get_entity_processor:

This method returns which entity processor is used for the corresponding upload entity. The BAdI mechanism allows to exchange a processor if needed, for example, if customer specific data structures must be read.

In general, the implementation of this method will return a customer specific Upload Entity Processor implementation (that implements the IF_SURDP_UPH_ENTITY_PROC interface) for each Upload Entity type.

· get_target_endpoint_dest:

This method will return the end point destination of the target system. If this method is defined, the returned value will be displayed as the default RFC destination in the report selection screens for all the upload entities. If no specific value is returned, the default destination RDP_REPL_API is used.

BAdi Implementations

The BAdI implementation must be defined by the user and is not provided by SAP. As example see class /VPCOE/CL_EXMPL_UPH_CUSTOM .

The custom Upload Entity Processors must implement the /vpcoe/if_uph_entity_proc interface. To ease the definition of custom entity processors, there are base classes available which provide already necessary functionality:

· /VPCOE/CL_UPH_PROC_BASE_PLM for the extraction out of PLM

· /VPCOE/CL_UPH_PROC_BASE_RCP for the extraction out of Recipe Development

· /VPCOE/CL_UPH_PROC_BASE_BOM for the extraction out of Bill of Material

· /VPCOE/CL_UPH_PROC_BASE_MCL for the extraction out of Material Classification

· /VPCOE/CL_UPH_PROC_BASE_HU for the extraction out of Handling Units

Therefore, custom Upload Entity Processors should inherit from these base classes. For examples of the custom Upload Entity Processors please have a look at the following classes:

· /vpcoe/lcl_exmpl_cust_cmp_plm for packaging composition extraction out of PLM

· /vpcoe/lcl_exmpl_cust_cmp_rcp for packaging composition extraction out of Recipe Development

· /vpcoe/lcl_exmpl_cust_cmp_bom for packaging composition extraction out of Bill of Material

· /vpcoe/lcl_exmpl_cust_pe_plm for packaging element extraction out of PLM

· /vpcoe/lcl_exmpl_cust_pe_mcl for packaging element extraction out of Material Classification

· /vpcoe/cl_hu_exmpl for the extraction out of packaging composition items from handling units