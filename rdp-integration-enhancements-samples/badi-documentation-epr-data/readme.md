# BAdI Definition and Usage Documentation

## Purpose
This Business Add-In (BAdI) is used to facilitate customer-specific logic for the integration of various data into the SAP Responsible Design and Production (RDP) cloud. It is invoked by specific reports that send different types of data to the RDP cloud. The BAdI allows customization of data retrieval, attribute mapping, and value transformation based on customer-specific requirements.

## Reports Utilizing This BAdI

The following reports utilize this BAdI to send data to the RDP cloud:

- **/VPCOE/BATCH_TO_RDP** – Send Batch data to the RDP cloud
- **/VPCOE/CONFIGURATION_TO_RDP** – Send Configuration data to the RDP cloud
- **/VPCOE/CUSTOMER_TO_RDP** – Send Customer data to the RDP cloud
- **/VPCOE/DELIVERY_TO_RDP** – Send Delivery data to the RDP cloud
- **/VPCOE/INCOTERMS_TO_RDP** – Send Incoterms data to the RDP cloud
- **/VPCOE/INVENTORY_TO_RDP** – Send Inventory data to the RDP cloud
- **/VPCOE/MAT_DOC_TO_RDP** – Send Material data to the RDP cloud
- **/VPCOE/ORG_DATA_TO_RDP** – Send Organization data to the RDP cloud
- **/VPCOE/PRODUCT_TO_RDP** – Send Product data to the RDP cloud
- **/VPCOE/SUPPLIER_TO_RDP** – Send Supplier data to the RDP cloud

When one of these reports is executed, this BAdI is triggered, and a customer-specific implementation is invoked to handle data retrieval, attribute mapping, and value transformation.

## Requirements

For more details about the standard settings of this BAdI, including filters and usage (single or multiple implementations), refer to the **Spot Element Definitions** tab in the BAdI Builder (transaction SE18).

## BAdI Methods

The BAdI definition, which is active within the Integration Accelerator package, contains the following methods from the interface **/VPCOE/IF_ADJ_DATA_RETRIEVAL**:

- **/VPCOE/IF_ADJ_DATA_RETRIEVAL~SKIP_SELECTION**  
  Allows bypassing standard VPCOE data selection logic. If used, data selection must be handled within **ADJUST_DATA_RETRIEVAL**.

- **/VPCOE/IF_ADJ_DATA_RETRIEVAL~ADJUST_DATA_RETRIEVAL**  
  Enables customer-specific data selection and adjustments to the extracted raw data.

- **/VPCOE/IF_ADJ_DATA_RETRIEVAL~ADJUST_JSON**  
  Modifies the JSON payload before sending data to RDP, based on customer-specific requirements.

- **/VPCOE/IF_ADJ_DATA_RETRIEVAL~ADJUST_MAPPING**  
  Customizes or overwrites the standard VPCOE mapping from source data to the JSON structure.

- **/VPCOE/IF_ADJ_DATA_RETRIEVAL~GET_EXT_DATA**  
  Retrieves extension data for Product, Customer, or Supplier as needed.

- **/VPCOE/IF_ADJ_DATA_RETRIEVAL~ADJUST_TEXT_MAPPING**  
  Customizes the mapping of text-based attributes within the JSON structure.

- **/VPCOE/IF_ADJ_DATA_RETRIEVAL~ADJUST_BUILD_WHERE_FOR_VARIANT**  
  Allows customization of WHERE conditions for data selection, especially relevant for Material Document replication.

- **/VPCOE/IF_ADJ_DATA_RETRIEVAL~DEFINE_MOVEMENT_TYPE**  
  Enables users to define custom movement type logic, overriding the default assignment based on specific business rules (valid only for movement type 303 and 305).

## BAdI Implementations

The BAdI implementation must be provided by the user and is not delivered as standard by SAP. 

For reference, a sample implementation can be found in the class **/VPCOE/CL_ADJUST_API_EXAMPLE**.

---
