# BAdI Documentation: /VPCOE/BADI_PCKF_CUSTOM

The Business Add-In (BAdI) **/VPCOE/BADI_PCKF_CUSTOM** is assigned to the enhancement spot **/VPCOE/ES_PCKF_CUSTOM** and is used during the download and processing of packaging fee data from the SAP Responsible Design and Production (RDP) API. The main purpose of this BAdI is to provide an extensibility mechanism that allows customers to implement custom logic for the retrieval and posting of packaging fee data.

## Entity Types and Entity Processor

Before delving into the details of this extension mechanism, it’s important to understand the concept of **Entity Types** and their respective **Entity Processor** implementations.

### Entity Types

The **Packaging Fee API** of SAP Responsible Design and Production (RDP) provides different entities:

- **Packaging Fee (PCKG_FEE)**
- **Applicable Business Partners (APL_BUSP)**

These entities are referred to as **Entity Types**. The processing of the corresponding entity data for each Entity Type is handled by an **Entity Processor class**.

### Entity Processor Class

An **Entity Processor class** must implement the interface **/VPCOE/IF_PCKF_ENTITY_PROC** and contains the following essential methods:

- **INIT_PROCESSOR**: Initializes the Entity Processor.
- **PREPARE_RETRIEVE**: Implements preparation steps for entity data retrieval.
- **RETRIEVE_PACKAGE**: Retrieves the entity data from the corresponding RDP API.
- **TRANSFER_PACKAGE**: Transfers the retrieved entity data to its target (e.g., converting Packaging Fee data into ERP pricing conditions).

For each Entity Type, there is a base class available in the system that must be extended for custom logic:

- **/VPCOE/CL_PCKF_PROC_PCKG_FEE**: Base class for **PCKG_FEE**.
- **/VPCOE/CL_PCKF_PROC_APPL_PART**: Base class for **APL_BUSP**.

The data retrieval process (methods **PREPARE_RETRIEVE** and **RETRIEVE_PACKAGE**) is already implemented in these base classes. However, to implement custom conversion logic (e.g., converting Packaging Fee data to ERP pricing conditions), you need to derive from **/VPCOE/CL_PCKF_PROC_PCKG_FEE** and override the **TRANSFER** method.

## BAdI Methods

The BAdI **/VPCOE/BADI_PCKF_CUSTOM** is already defined and active in the standard system. It includes the following methods from the interface **/VPCOE/IF_PCKF_CUSTOM**:

### `get_entity_processor`
- This method determines which **Entity Processor** should be used for the corresponding **Entity Type**.
- The BAdI allows customers to exchange the processor, for example, when a custom conversion of Packaging Fee data to ERP Pricing Conditions is required.
- If no custom implementation is provided, the base class **Entity Processor** is used.

### `get_target_endpoint_dest`
- This method returns the endpoint destination of the RDP source system.
- If defined, the returned value is displayed as the default RFC source in the retrieval report selection screen.
- If no value is returned, the default destination **VPCOE_RDP_PCKF** is used.

## BAdI Implementation

The BAdI implementation must be defined by the user; it is **not** provided by SAP. As an example, the class **/VPCOE/CL_EXMPL_PCKF_CUSTOM** is linked as a sample BAdI implementation.

For more information about settings for a BAdI, such as filters, single or multiple uses, refer to the **Spot Element Definitions** tab in the BAdI Builder (transaction **SE18**).

## Retrieval and Posting of Packaging Fee Data

### Prerequisites
- The BAdI must be implemented to provide the **Entity Processor** instance (either custom class or base class) for the **Entity Types** **PCKG_FEE** and **APL_BUSP**.
- The **RFC destination** and **OAuth configuration** must be set up in the system to access the RDP API.

### Reports for Retrieval and Posting

The following reports are defined in the system for retrieving and posting Packaging Fee and Applicable Business Partner entity data:

- **/VPCOE/R_PCKF_RETRIEVAL** (transaction **/VPCOE/PCKF_RETRIEVAL**): This report retrieves Packaging Fee and Applicable Business Partner entity data from the RDP API. The retrieved data is stored for later (asynchronous) processing by the posting report.
  
- **/VPCOE/R_PCKF_POSTING** (transaction **/VPCOE/PCKF_POSTING**): This report handles the conversion and posting of retrieved Packaging Fee and Applicable Business Partner entity data into ERP Pricing Conditions.

When either of these reports is executed, the BAdI is invoked, and as a result, an instance of the appropriate **Entity Processor** implementation (whether custom or base class) must be returned.

---

For further assistance, please refer to the relevant SAP documentation or contact SAP support.

