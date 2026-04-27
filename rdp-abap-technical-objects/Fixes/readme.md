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

	### **TR 901473.BP7** and
	    **TR 900518.M19**

	### ✨ Features and Fixes

	* **Packaging compositions from BoM Report**
	  - Optimized logic in determine BOM to avoid short dumps when material type is missing.
	  - Improved error handling for delta load scenario.
	
	* **Packaging Fee API V2**
	  - Introduced support for **RDP Packaging Fee API V2** .
	  - Adjusted ABAP structures and logic to align with the new API specification.
	  - Both V1 and V2 are supported; customers can select the version via RFC connection path.
	  - When RDP API V2 is preferred the `Context` field is removed form selection screen (as this is obsolete field in V2), adjusted renamed attributes, and updated sample BAdI mapping recommendations.
	
	* **Packaging Element Report from Material Classification (this functionality is included in TR 900518.M19)**
	  - Added support for the new attributes `isExpanded` and `Functions` under the *Fraction* node, aligned with **RDP Packaging Data V2 API**.
	  
	* **Material Document report**
	  - Performance improvement in the material document selection and in Country Determination method.
	  - Display mode - Fixed issue where duplicate log entries appeared when no data was found.
	
	* **Packaging Data Validation**
	  - Introduced validation ensuring that API paths defined in the RFC connection(s) and in the Configuration settings for services match the same API version

	### 📘 Documentation

	* User Guide updated with details on the new features and adjustments.

### **Update: V6.0.7 – October 2025**

	### **TR 901481.BP7**

	### ✨ Features and Fixes

	* **Material documents replication report**
	  - Adjust the logic for determining the ShipToCountry attribute, to correctly handle cases where a receiving vendor is maintained on the corresponding Purchase Order

### **Update: V6.1 – December 2025**

	### **TR 901524.BP7**

      ⚠️ **Important Note – Impact on Pack Fee Replication Report**

      A new mandatory selection parameter **Load ID** has been introduced for Delta Load execution in the **Packaging Fee Retrieval** report.

      * Existing scheduled background jobs for “Retrieving Pack Fee – Delta Load” **will fail** unless batch jobs are updated to include this new parameter.
      * Customers must **update their job variants** and verify the selected Load ID.
      * Customer-specific **BAdI implementations**, especially those enhancing retrieval or posting logic, may require adjustments to align with the updated report logic.

      It is highly recommended that customers review their automation and BAdI code before importing this update to avoid interruptions in replication processes.

      ### ✨ Enhancements & Fixes

      * **Packaging Fee – Retrieving & Posting Reports Adjustments**  
        The RDP Pack Fee API now supports multiple delta tokens in parallel.  
        Major functional enhancements include:
        - Allow customers to maintain **separate delta runs per variant**
        - During initial load, the variant name is stored together with the delta token
        - Delta load must be executed **per variant**
        - Retrieved data is saved and archived
        - Added option to **post retrieved data directly** from the same report (via radio button)

      * **Handling Unit Report Adjustments**
        - Fix for correct handling of the entity mapper class

      * **HTTP Protocol Version – Updated Logic for JSON Header**
        - SM59 configuration now determines whether HTTP 1.0 or HTTP 1.1 is used when replicating data to RDP
        - System automatically sets correct protocol version in HTTP requests

      * **Determination of BOM Valid-To Field – Plant Added to Sorting Attribute**
        - Ensures BOMs assigned to multiple plants appear correctly  
        - Fix implemented without impacting existing customer BAdI logic

      * **Material Document – Country Determination Priority Update**
        - Implemented logic for prioritizing **country of target customer**  
          (relevant for drop shipment scenarios)

      * **Packaging Fee Reports – Added Missing Authorization Objects**
        New authorization objects introduced for:
        - Customer Role
        - Company Code Exemptions
        - Customer Exemptions

      * **Delivery Report – Fix in Package Splitting**
        - Adjustment in the package-splitting logic, in case BAdI is implemented

      * **Bug in Example Implementation – Material Classification Fraction Mapping Versioning**
        - Fix for missing **VERP** material in BOM processing
        - Corrections in BOM where-used determination when components have no assigned material
        - Includes performance improvements

### **Update: V6.1.1 – January 2026**

	### **TR 900528.M19**

	### ✨ Features and Fixes

	* **Delivery documents replication report**
	  -  Adjusted the logic to correctly send all objects split across multiple packages. Previously, objects starting from the second package were not sent.  
	* **Packaging element from material classification report**
	  - Fixed a short dump caused by an unassigned field symbol.    

### **Update: V6.1.2 – February 2026**

	### **TR 900529.M19**

	### ✨ Features and Fixes

	* **Support for Packaging Composition Variants**
	  - Packaging Data Reports – Support for Packaging Composition Variants
 		 Adjustments were implemented to include additional variant-defining attributes:
  		  - productionPlant
  		  - plant
  		  - shipToParty
 		  - distributionChannel
 		 These attributes allow more accurate replication of packaging composition variants across different operational contexts.

	- Batch Report – Enhanced Support for ProductionPlant
  		The Batch replication report has been updated to handle the ProductionPlant attribute (as part of characteristics data), enabling improved data consistency and alignment with upstream manufacturing processes.   

### **Update: V7.0 – March 2026**

	### **TR 901559.BP7 – install only for upgrade from V6 to V7; skip for fresh installation**

	### ✨ Features 

	* **Introduces support for **two APIs**:
		- **RDP Push API** (traditional API used in previous accelerator versions)  
		- **SAP Sustainability Solutions API (SDF API)** — new in V7 

### **Update: V7.0.1 – April 2026**

	### **TR 901589.BP7**

	### ✨ Features and Fixes

	* **Packaging Data – Delta Token Support (BOM)
		- Implemented delta token handling for Packaging Composition from BOM report
		- Enables efficient delta-based replication
	
	* **Configuration Data – Product Brand Replication
		- Added support for Product Brand replication via Configuration Data report

	* **Packaging Element – refillType Support
		- Added support for refillType attribute in Packaging Element replication
	
	* **Customer / Supplier Tax Number (CVI)
	- Improved logic for tax number determination:
  		- Uses CVI data when available (Fallback to KNA1/KNAS (Customer) or LFA1/LFAS (Supplier) if CVI is not 		maintained)

	* **Packaging data replication reports - Extensibility Enhancements for ABAP Structures
	- Enhanced standard ABAP structures to improve extensibility  
	- Enables customers to add additional attributes without replacing standard logic 

---
### **Installation Instructions for fixes**
To apply available fixes/updates:
1. Ensure that the base **RDP Integration Accelerator** package is installed.
2. Import all available TRs in [the specified order](/rdp-abap-technical-objects#apply-fixes-mandatory-for-all-installations) using your transport management system.


_Note: Additional fixes and new features will be added in the future. Customers should always check for the latest available fixes/features and ensure they are installed._

---


