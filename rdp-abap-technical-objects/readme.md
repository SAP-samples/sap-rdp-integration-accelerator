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
  - **Fixes -> TR 900230.BMT


### **Step 3:  Install Customizing objects**
- **RDP reports Customizing:**
  - Install **RDP/EPR ABAP Technical Objects -> TR 901346.BP7**
- **Packaging Data reports Customizing:**
  - Install **RDP ABAP Technical Objects -> TR 901348.BP7**


## Upgrading from RDP Integration Accelerator V5 to V6

If you already have **RDP Integration Accelerator V5** installed and want to upgrade to **V6**, follow these steps:

### **Step 1: Install Delta Technical Objects**
- Install **RDP/EPR ABAP Technical Objects**:
  - **TR 901359.BP7 (Note: Prerequisite: All RDP IA V5 fixes should already be installed. Latest TR installed for V5 should be TR 900289.BMT)**.
- Install **PLM ABAP Technical Objects (Only install this if the UI component **PLMWUI** is present in your system)**:
  - **TR 901336.BP7**.

### **Step 2:  Install Delta Customizing objects**
- **RDP reports Delta Customizing (will overwrite existing customizing ):**
  - Install **RDP/EPR ABAP Technical Objects -> TR 901346.BP7**
- **Packaging Data reports Delta Customizing (will overwrite existing customizing ):**
  - Install **RDP ABAP Technical Objects -> TR 901348.BP7**

## **Upgrade from Older Versions of the Accelerator**
If you are running an **older version** of the RDP Integration Accelerator (prior to V5), you must first upgrade to **V5** before proceeding to V6. 

- Customers using an older version should open a **support ticket** under the **SV-COE-VPT-RDP** component. SAP will provide guidance and the necessary transport requests to first upgrade to **V5** before continuing with the V6 upgrade.

---
## Apply Fixes (Mandatory for All Installations)

Regardless of whether you are performing a fresh installation or an update, it is essential to install any available fixes to ensure stability and compatibility.
Details on addressed issues or features can be verified [here](Fixes).  
Install all available fixes/new features transport requests from [Fixes](Fixes) folder in the specified sequence below:

1. **Fixes -> TR 901380.BP7
2. **Update to Version 6.0.1** (Details on changes introduced in V6.0.1 are available in the [Fixes](Fixes) folder)
   2.1 **TR 901394.BP7** – General update.
   2.2 **TR 901395.BP7** – Additional update for reports for PLM data replication.  ⚠️ *Only install this transport if the UI component **PLMWUI** is present in your system.*


Note: Additional fixes may be provided in the future. Customers should always check for the latest available fixes or new features and ensure they are installed.


## Notes
- Ensure all transport requests are imported **in the specified sequence**.
- If you encounter issues, open a support ticket via **SAP ONE Support Launchpad**: [SAP ONE Support](https://support.sap.com/en/index.html) using Ticket Component: SV-COE-VPT-RDP.

---
© 2025 SAP SE or an SAP affiliate company. All rights reserved.

