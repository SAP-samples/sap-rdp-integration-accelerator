# SAP RDP Integration Accelerator - Fixes

This document provides details on the fixes available in the **Fixes** folder. All customers must ensure they install the latest fixes to maintain compatibility and resolve known issues.

## **Available Fixes**

### **Fix: TR 900230.BMT - custom code for handling JSON objects**
#### **Issue Addressed**
- Resolved an issue where **/UI2/CL_JSON** standard class is not available or is an old version in the system. 
- this is relevant ONLY for NW version 7.4 SP15 or lower

### **Fix: TR 901380.BP7 - fix for Material Documents attribute 'purchaseOrderItem' in JSON objects**
#### **Issue Addressed**
- Resolved an issue where attribute 'purchaseOrderItem' contains empty value in JSON for Material Documents entity


---
### **Installation Instructions for fixes**
To apply available fixes:
1. Ensure that the base **RDP Integration Accelerator** package is installed.
2. Import all available TRs in [the specified order](/rdp-abap-technical-objects#apply-fixes-mandatory-for-all-installations) using your transport management system.


_Note: Additional fixes and new features will be added in the future. Customers should always check for the latest available fixes/features and ensure they are installed._

---


