# SAP RDP Integration Accelerator - Installation Guide

## Fresh Installation of RDP Integration Package V6

If you do **not** have an existing version of the RDP Integration Accelerator installed **and** you do **not** have any version of the SFM Integration Accelerator installed in your system, follow these steps:

### **Step 1: Install Technical Objects**
1. **Install RDP/EPR ABAP Technical Objects**:
   - **TR 901362.BP7** (Note: This transport does **not** include customizing objects).
   - **TR 901354.BP7** (This transport contains reports for data replication from PLM. Only install this if the UI component **PLMWUI** is present in your system).  
     - **Important**: When installing in an S/4HANA system, this transport may fail with errors. After installing **TR 901274.BP7**, the errors will be resolved.
2. **Note on SAP SP Level Issues:**
   - If you are on a lower SAP SP level, you may encounter errors related to the `/UI2/CL_JSON` standard class.
   - You have **two options** to resolve this:
     1. Install SAP Note **2526405 - /UI2/CL_JSON Corrections** via [SAP for Me](https://me.sap.com/notes/2526405) to apply the necessary corrections.
     2. If installing the SAP Note is not possible, you may **ignore** the errors in this transport request (TR) and proceed with the remaining TRs. In this case, the TRs in Step 2 become **mandatory**.

### **Step 2: Apply Fixes (ONLY for NW version 7.4 SP15 or lower)**
- Install the following transport requests:
  - **Fixes -> TR 910061.BP7** ????or TR 900230.BMT???
  - **Fixes -> TR 900101.BP7** ??? is this needed ???

### **Step 3:  Install Customizing objects**
- **RDP reports Customizing:**
  - Install **RDP/EPR ABAP Technical Objects -> TR 901346.BP7**
- **Packaging Data reports Customizing:**
  - Install **RDP ABAP Technical Objects -> TR 901348.BP7**


## Upgrading from RDP Integration Accelerator V5 to V6

If you already have **RDP Integration Accelerator V5** installed and want to upgrade to **V6**, follow these steps:

### **Step 1: Install Delta Technical Objects**
- Install **RDP/EPR ABAP Technical Objects**:
  - **TR 901359.BP7 (Note: Prerequisite: All RDP IA V5 fixes should already be installed)**.
- Install **PLM ABAP Technical Objects (Only install this if the UI component **PLMWUI** is present in your system)**:
  - **TR 901336.BP7**.

### **Step 2:  Install Delta Customizing objects**
- **RDP reports Delta Customizing (will overwrite existing customizing ):**
  - Install **RDP/EPR ABAP Technical Objects -> TR 901346.BP7**
- **Packaging Data reports Delta Customizing (will overwrite existing customizing ):**
  - Install **RDP ABAP Technical Objects -> TR 901348.BP7**
---

## Notes
- Ensure all transport requests are imported **in the specified sequence**.
- If you encounter issues, open a support ticket via **SAP ONE Support Launchpad**: [SAP ONE Support](https://support.sap.com/en/index.html) using Ticket Component: SV-COE-VPT-RDP.

---
© 2025 SAP SE or an SAP affiliate company. All rights reserved.

