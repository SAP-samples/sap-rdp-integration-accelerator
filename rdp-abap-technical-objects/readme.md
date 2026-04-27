# SAP RDP Integration Accelerator - Installation Guide

---

## 📦 Installation Packages by Version

Below you can expand each version section to view installation steps and required transports.

---

<br>

# **V6 – Installation Instructions**

<details>
<summary><strong>Click to expand installation instructions for Version V6</strong></summary>
<br>

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
     1. Install SAP Note **2526405 - /UI2/CL_JSON Corrections**.
     2. Ignore the errors and proceed with remaining TRs — Step 2 becomes **mandatory**.

### **Step 2: Apply Fixes (ONLY for NW version 7.4 SP15 or lower)**
- Install:
  - **Fixes → TR 900230.BMT**

### **Step 3: Install Customizing Objects**
- **RDP Reports Customizing** → TR **901346.BP7**
- **Packaging Data Reports Customizing** → TR **901348.BP7**


## Upgrading from RDP Integration Accelerator V5 to V6

### **Step 1: Install Delta Technical Objects**
- RDP/EPR: **TR 901359.BP7**  
- PLM Reports (only if **PLMWUI** exists): **TR 901336.BP7**

### **Step 2: Install Delta Customizing Objects**
- RDP Reports Customizing → **TR 901346.BP7**
- Packaging Data Customizing → **TR 901348.BP7**

## Upgrade from Older Versions
If you are on a version **older than V5**, contact SAP support (component **SV-COE-VPT-RDP**) to obtain the required intermediate upgrades.

</details>

---

<br>

# **V6 – Fixes and Updates**

<details>
<summary><strong>Click to expand fixes & updates for Version V6</strong></summary>
<br>

## Apply Fixes/Updates (Mandatory)

Install all available fixes/new features transport requests from the [Fixes](Fixes) folder in the specified sequence below:

1. **Fixes → TR 901380.BP7**

2. **Update: Version 6.0.1**
   - **TR 901394.BP7** – General update  
   - **TR 901395.BP7** – PLM reports update (*only with PLMWUI*)

3. **Update V6.0.2** → TR **901413.BP7**

4. **Update V6.0.3** → TR **901420.BP7**

5. **Update V6.0.4** → TR **901435.BP7**

6. **Update V6.0.5** → TR **901440.BP7**

7. **Update V6.0.6** → TR **901473.BP7** and **900518.M19**

8. **Update V6.0.7** → TR **901481.BP7**

9. **Update V6.1.0** → TR **901524.BP7**  
   ✔ Includes all fixes from V6.0.1–V6.0.7  
   ✔ Plus new V6.1 enhancements  
   > New customers may skip steps 1–8 and install only V6.1.0.

10. **Update V6.1.1** → TR **900528.M19**

11. **Update V6.1.2** → TR **900529.M19**

📂 Details for each version are available in the [Fixes](Fixes) folder.

</details>

---

<br>

# **V7 – Installation Instructions (New)**

<details open>
<summary><strong>Click to expand installation instructions for Version V7</strong></summary>
<br>

Version **V7** introduces support for **two APIs**:
- **RDP Push API** (traditional API used in previous accelerator versions)  
- **SAP Sustainability Solutions API (SDF API)** — new in V7  

Customers can choose which API to use per entity type.
> Important: Customers using BAdI enhancements must review mappings, as switching to the SDF API may require adjustments.

### More Details  
Full API comparison, configuration requirements, and usage scenarios are documented in the **V7 Configuration Guide**.

## Fresh Installation of RDP Integration Package V7

---

### **Step 1: Install Technical Objects**
1. **Install the V7 technical transports:**
- **TR 901557.BP7** – RDP/EPR technical objects 
- **TR 901568.BP7** – PLM reports (*This transport contains reports for data replication from PLM. Only install this if the UI component PLMWUI is present in your system*)

2. **Note on SAP SP Level Issues:**

If you are on a lower SAP SP level, you may encounter errors related to the `/UI2/CL_JSON` standard class.
   - You have **two options** to resolve this:
     1. Install SAP Note **2526405 - /UI2/CL_JSON Corrections**.
     2. Ignore the errors and proceed with remaining TRs — Step 2 becomes **mandatory**.

### **Step 2: Apply Fixes (ONLY for NW version 7.4 SP15 or lower)**
Install:
- **Fixes → TR 900230.BMT**

### **Step 3: Install Customizing Objects**
- **TR 901346.BP7** – RDP customizing  
- **TR 901348.BP7** – PLM Packaging Data customizing  (*This transport contains customizing for reports for data replication from PLM. Only install this if the UI component PLMWUI is present in your system*)

---

## Upgrading from V6 to V7

### Step 1: Install Delta Technical Objects
- **TR 901559.BP7** – V7 delta technical update  

<br>

### Upgrade Notes
- Ensure all V6 transport requests and fixes are imported **in the correct sequence** before upgrading to V7.
- Review BAdI logic if switching from RDP API to SDF API.
- If you encounter issues, open a support ticket via:  
  [SAP ONE Support](https://support.sap.com/en/index.html), Component: **SV-COE-VPT-RDP**

---

# **V7 – Fixes and Updates**
<details open>
<summary><strong>Click to expand fixes & updates for Version V7</strong></summary>

## Apply Fixes/Updates (Mandatory)

Install all available fixes/new features transport requests from the [Fixes](Fixes) folder in the specified sequence below:

1. **Updates and Fixes → TR 901589.BP7**

</details>

© 2025 SAP SE or an SAP affiliate company. All rights reserved.
