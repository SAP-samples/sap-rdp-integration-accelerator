[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/sap-rdp-integration-accelerator)](https://api.reuse.software/info/github.com/SAP-samples/sap-rdp-integration-accelerator)


# SAP RDP Integration Accelerator

## Description

The SAP Responsible Design and Production (RDP) Integration Accelerator is an ABAP package designed to streamline the integration of SAP RDP with backend ECC systems or older S/4HANA systems. The package includes prebuilt integration content that allows for selection, extraction, and replication of relevant data into the cloud-based RDP solution via standard RDP push APIs.

The code in the ABAP package can be used as it is published in this repository, or you can use it as a sample reference for your own implementation. However, if you require support, you must use it as it is and enhance it if needed via BAdI implementation.

## Requirements

- SAP ERP ECC 6.0 EHP7 SP16 (or later)/EHP8 or S/4HANA 1909/2021.
- Minimum SAP\_BASIS 740 (Package Level 0019 or higher).
- Access to SAP Business Technology Platform (BTP) for creating RDP replication services instances.
  - More details on [BTP configurations](https://help.sap.com/docs/sap-responsible-design-and-production/user-guide-sap-rdp/initial-setup).

## Features

- Preconfigured ABAP reports for data replication.
- Compatibility with master data and transactional data.
- Support for both initial and delta data loads.
- Error handling and logging capabilities, including reprocessing failed payloads.
- Extensibility for customer-specific adaptations and sample BAdI implementations.

### **Sample Implementation**
Sample implementations of BAdIs available are provided in the repository **[`sample_badi_implementations`](rdp-integration-enhancements-samples/)**. This file serves as a reference for customers looking to create their own implementations.

## Download and Installation

To install/update the RDP Integration Accelerator package:

1. Upload the provided transport files using transaction **CG3Z** or any relevant function modules/tcodes in your system.
2. Import transport requests in the specified sequence (see [installation steps](rdp-abap-technical-objects/readme.md)).
3. Perform the configuration steps described in the [RDP Integration Accelerator Guide](Documentation/SAP_VP_RDP_Integration%20Accelerator_ConfigGuide_v6_0.4.pdf).
   - Ensure all prerequisites for initial setup on BTP account and subaccount are fulfilled (More details on [BTP configurations](https://help.sap.com/docs/sap-responsible-design-and-production/user-guide-sap-rdp/initial-setup).
   - Configure RFC destinations (**SM59**) for HTTPS communication with the RDP API.
   - Maintain service path prefixes (optional).
   - Create and activate change pointers (optional).
   - Add maximum limit on data replication (optional).

## Usage

The integration package provides several reports for required data replication, including:


### **ERP Integration Reports**

- **Organizational Data** – Replication of company structures, plants, sales organizations, distribution channels, and divisions.
- **Configuration Data** – Synchronization of unit of measure definitions, currency details, product hierarchies, movement types, and other configuration elements.
- **Master Data Replication**
  - Supplier
  - Customer
  - Product
  - Batches

### **Transactional Data Replication**

- Delivery Documents including the Billing Document Items
- Material Movements including the Billing Document Items & Supplier Invoice Items
- Inventory
- Incoterms

### **Packaging Data Integration**

- **Packaging Composition Replication** – Extracted from PLM, Recipe Development, and Bill of Materials (BOM).
- **Packaging Elements Replication** – Retrieved from PLM and Material Classification.
- **Partial Packaging Composition Item Replication** – Handling Units replication.
- **Creation of RDP recommended classes and characteristics** – Create example classes and characteristics for storing packaging data in your SAP ECC / S/4HANA system based on Material Classification or Specification Database.

### **Packaging Fee Replication**

- Synchronization of Packaging Fees – Replication from RDP back to ECC/S4H for creating pricing conditions and compliance reporting.
- Customer Role Replication – Replication of customer-specific role attributes from RDP to ECC/S4H for creating customer dependent/independent pricing conditions and material classifications.
- Customer Exemptions and Company Code Exemptions – Replication of customer-specific and company code-specific exemptions from RDP to ECC/S4H for creating customer dependent/independent pricing conditions and material classifications.

### **Analytical and Configuration Reports**

- Report for Generating Recommended RDP Classes and Characteristics
  - Packaging Elements in Material Classification
  - Packaging Compositions in BOM, classifying Packaging Elements into Main/Subordinate
  - Packaging Compositions and Main/Subordinate Packaging Elements in PLM SpecDB
  - Packaging fee data classification
  - Customer extension data classification

### **Error Handling and Logging**

- **Error Monitoring and Troubleshooting Reports** – Comprehensive logging and troubleshooting capabilities for monitoring replication status and resolving data inconsistencies.


For a complete list of reports and instructions on how to load the data, refer to the [RDP Integration Accelerator Guide](Documentation/SAP_VP_RDP_Integration%20Accelerator_ConfigGuide_v6_0.pdf).

## BAdI Technical Documentation

For extending data retrieval and mapping functionality for ERP reporting, the **BAdI `/VPCOE/ADJUST_DATA_RETRIEVAL`** can be implemented. 

For packaging data replication and mapping functionality, the **BAdI `/VPCOE/BADI_UPH_CUSTOM`** needs to be implemented. 

For packaging fee data replication and mapping functionality, the **BAdI `/VPCOE/BADI_PCKF_CUSTOM`** needs to be implemented. 

For email notification processing enhancements, the **BAdI `/VPCOE/BADI_NOTIFICATION_PROCESSING`** needs to be implemented. 

More details about these BAdIs and their usages can be found in the **[BAdI Technical Documentation](rdp-integration-enhancements-samples/)** and in the [RDP Integration Accelerator Guide](Documentation/SAP_VP_RDP_Integration%20Accelerator_ConfigGuide_v6_0.pdf).


Sample BAdI implementations are included in the RDP IA package for all available BAdIs, to serve as a starting point for customer's own implementation.

## Security

All replication endpoints are secured using TLS (HTTPS) to ensure encryption of customer data during transmission.
SSL certificates and the TLS handshake process establish trust between the communicating systems.

Access to the API is secured using authorization mechanisms based on the XSUAA (SAP Authorization and Trust Management) component, leveraging the OAuth 2.0 client credentials grant.
XSUAA serves as the central identity provider on SAP BTP, managing authentication and authorization.

Through the RDP service broker, customers create a service instance, allowing them to obtain an access token for replication.

## Known Issues

- Only English language is supported as of now.

## Contributing

This project is maintained and updated exclusively by SAP employees. External contributions, such as pull requests, are not accepted. However, we encourage users to submit bug reports and feature requests via SAP Support.

## How to Obtain Support

If you encounter issues or have questions, you can submit a support ticket via SAP ONE Support Launchpad: [SAP ONE Support Launchpad](https://support.sap.com/en/index.html):

- **Ticket Component:** SV-COE-VPT-RDP

  **Important Note:** Support on any standard code issues on integration accelerator is only offered for the latest code available in this repository. Customers must ensure that the latest transport requests (TRs) are installed on their system before reporting any issues. If an issue persists after updating to the latest version/latest TR available, a support ticket should be raised. Support is not provided for older versions where the latest updates have not been applied.

## Importance of Regular Updates for Integration Accelerator

Due to the rapid evolution of RDP, it is highly recommended that customers update their Integration Accelerator package regularly. Regular updates ensure compatibility with the latest features and enhancements in RDP.

## License

Copyright (c) 2025 SAP SE or an SAP affiliate company. All rights reserved. This project is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSE) file.


