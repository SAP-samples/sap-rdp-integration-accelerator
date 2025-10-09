# SAP RDP Integration Accelerator - Fixes

This document provides details on the fixes available in the **Fixes** folder. All customers must ensure they install the latest fixes to maintain compatibility and resolve known issues.

## **Available Fixes**

### 🛠**Fix: TR 900230.BMT - custom code for handling JSON objects**
#### **Issue Addressed**
- Resolved an issue where **/UI2/CL_JSON** standard class is not available or is an old version in the system. 
- this is relevant ONLY for NW version 7.4 SP15 or lower

### 🛠**Fix: TR 901380.BP7 - fix for Material Documents attribute 'purchaseOrderItem' in JSON objects**
#### **Issue Addressed**
- Resolved an issue where attribute 'purchaseOrderItem' contains empty value in JSON for Material Documents entity

### **Update: V6.0.1 – June 2025**: 

      ### **TR 901394.BP7** 

      ### ✨ Features added
      
      * Added "Valid From" filter in Product report (MARA-DATAB)
      * `basicMaterialFractionId` attribute now included to support Packaging Element API V2
      * New Packaging Element attribute `refillType` included (to support Packaging Element API V2)
      * Packaging compositions and packaging elements sample BAdI implementations support both V1 and V2 (with fallback logic)
      * Configuration made flexible for packaging material type check (previously was hardcoded as `VERP`) in material documents replication
      * Configuration for SourceId made flexible to be easily maintained in customizing view
      * Excel templates cleaned to display English-only tax number descriptions
      * Company code (`BUKRS`) added to plant structure in Organization report
      * Product replication (including delta load) now skips plant validation (products are sent even when Plant is not maintained for a specific product)
      * New version constant introduced in code indicating release version 
           
      ### 🛠 Fixes
      
      * Supplier delta load now handles no-data case (job won’t fail)
      * Pop-up in Inventory report suppressed in background execution
      * Missing space between Supplier name1 & name2 fixed in Supplier replication
      * BAdI `adjust_header` now skippable by customer implementation
      * Improved tax number logic for customers and suppliers replication (KNA1 / KNAS fallback)
           
 	### **TR 901395.BP7**
      
      * data model and example extraction implementation for packaging compositions from Spec DB/PLM has been enhanced       

      ### 📘 Documentation
      
      * New version for User guide has been updated with details on the features introduced  
      
### **Update: V6.0.2 – July 2025**: 

      ### **TR 901413.BP7** 

      ### ✨ Features added
      
	* Added "Cross Plant Valid From Date" filter in Product report (MARA-MSTDE)
 	* Secondary database connection parameter to be used when retrieving data for the Delivery and Material Documents reports
	* Improve the logic when determining ShipFromCountry field for Material Documents replication, in case plant address data is empty 

	### 📘 Documentation
      
      * New version for User guide has been updated with details on the features introduced

### **Update: V6.0.3 – July 2025**: 

      ### **TR 901420.BP7** 

      ### ✨ Features added
      
	* Multiple Material Types can now be configured for Product replication in the Application parameter section.
	* Delivery replication - 'Send related customers before'
	When enabled, delta customers related to the selected deliveries are sent before the deliveries. Details on the behavior can be found on the updated user guide.
	* Add a sample badi impl for this API call /GetPackagingCompositonsForProduct, to get all pack comp IDs that belongs to a product for a given validity period, business process direction and supplier ID
	* Improve logs and traceability by adding a new report /VPCOE/TRACE_MAINTENANCE helping customers tarcing data sent successfully or not.  
	* Handling Units reports - Handling Units replication updated to use RDP V2 APIs. 
	* Sample BAdI implementation added for RDP API /GetPackagingCompositionsForProduct
	
      ### 📘 Documentation
      
      * New version for User guide has been updated with details on the features introduced

### **Update: V6.0.4 – August 12th 2025**: 

      ### **TR 901435.BP7** 

      ### ✨ Features added
      
	* Catch Weight materials - optional
		- Introducing a new application parameter allowing customers to make optional the catch weight 	materials during delivery replication 
		- By default, the value of the application parameter is empty (false), meaning the quantities in base unit of measure will be used. 
		- Packaging compositions in RDP are defined either in the product base unit of measure or in one of the alternative UoMs that can be converted to the base UoM. Therefore, catch weight quantities are not relevant for RDP (RDP needs the quantity in the base unit of measure).
		- Unless there is a specific business reason to send catch weight materials to RDP, the quantities in the base unit of measure should be sent.

	
      ### 📘 Documentation
      
      * New version for User guide has been updated with details on the features introduced

### **Update: V6.0.5 – September 9th 2025**: 

      ### **TR 901440.BP7** 

      ### ✨ Features added
      
	* Improved logic for handling **Material Documents** that include Quality Management documents  
    * Added new filters for **Material Document report**:  
        	- Material Type  
        	- Sales Organization of Material 
	* Removed restriction limiting selection of up to 20 Material IDs in Packaging Compositions from BOM and Packaging Elements from MCL reports
	
      ### 📘 Documentation
      
      * New version for User guide has been updated with details on the features introduced

### **Update: V6.0.6 – October 2025**

	### **TR 901467.BP7**

	### ✨ Features and Fixes

	* **Packaging compositions from BoM Report**
	  - Optimized logic in determine BOM to avoid short dumps when material type is missing.
	  - Improved error handling for delta load scenario.
	
	* **Packaging Fee API V2**
	  - Introduced support for **RDP Packaging Fee API V2** .
	  - Adjusted ABAP structures and logic to align with the new API specification.
	  - Both V1 and V2 are supported; customers can select the version via RFC connection path.
	  - When RDP API V2 is preferred the `Context` field is removed form selection screen (as this is obsolete field in V2), adjusted renamed attributes, and updated sample BAdI mapping recommendations.
	
	* **Packaging Element Report from Material Classification**
	  - Added support for the new attributes `isExpanded` and `Functions` under the *Fraction* node, aligned with **RDP Packaging Data V2 API**.
	  
	* **Material Document report**
	  - Performance improvement in the material document selection and in Country Determination method.
	  - Display mode - Fixed issue where duplicate log entries appeared when no data was found.
	
	* **Packaging Data Validation**
	  - Introduced validation ensuring that API paths defined in the RFC connection(s) and in the Configuration settings for services match the same API version

	### 📘 Documentation

	* User Guide updated with details on the new features and adjustments.


---
### **Installation Instructions for fixes**
To apply available fixes/updates:
1. Ensure that the base **RDP Integration Accelerator** package is installed.
2. Import all available TRs in [the specified order](/rdp-abap-technical-objects#apply-fixes-mandatory-for-all-installations) using your transport management system.


_Note: Additional fixes and new features will be added in the future. Customers should always check for the latest available fixes/features and ensure they are installed._

---


