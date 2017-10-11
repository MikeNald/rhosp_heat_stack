In this repo you’ll find:

# stack-3tier.yaml 

   Main HOT template which define the skeleton of our stack
    input parameters
    resources type
    output

# Lb-resource-stack-3tier.yaml

   Hot template to configure our lbaas v2. 
   This file will be retrieve by the main HOT template via http 
   
# Run.sh 

   Bash script to perform:
     - Openstack project creation
     - User creation/delete
     - Heat stack creation under preconfigured project

  
# The heat stack will provision:

## 5 VMs ( 2 web servers, 2 application servers, 1 DB)
right now app servers and db are placeholder. Feel free to evolve your own stack 
with a real app server (jboss eap for instance) and a db like mysql/postgres or whatever you want
  
## Auto scaling: scale up when the 50% of CPU usage persists for 5 minutes
scale down if the CPU usage falls down to 15% for 3 minutes
  
## Load balancers: 1 for the web tier, the other for the application tier
Fe lbaas exposed by Floating IP on port tcp 80, lbaas reacheable internally from web server layer
2 vNICs per VM (tenant network corresponding to the layer + management)
  
Floating IP assignment: 1 IP from the Floating IP web server network, 1 IP from the Floating IP MGMT VM network
  
Security groups: 1 for the web tier (sg_web), 1 for the application tier (sg_app), 1 for the DB tier (sg_db), 1 for the management network (sg_mgmt, all VMs) 
   
Tenant: heat stack is designed to create every resources inside the tenant specified by the parameters tenant_id or using CF tenant mapping feature



a big THANK YOU to my Red Hat colleagues Francesco Vollero and Matteo Piccinini
