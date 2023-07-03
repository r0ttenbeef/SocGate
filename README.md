# SocGate
Opensource SIEM and SOAR solution based on Elastic Security solution integrated with multiple SOC components all in one inside docker.
# Disclaimer
This project doesn't meant for producation environments, Just use it for testing purposes or personal practices just like a POC environment.
# Project Components and Structure
Each component is deployed in a docker container and the diagram below should be explaining how the workflow is done.
 
![SocGate](https://github.com/r0ttenbeef/SocGate/assets/48027449/1761ccbe-d4ca-4a06-91a5-102740adebb7)

# Machine Requirements
You don't need to install any packages before starting installation, Just a fresh installed ubuntu server.
The minimum requirements to run the full stack:

| RAM | CPU | Disk |
|------|------|-----|
| 10 GB | 4 Cores | 100 GB |

# Setup and Configuration

- Modify the `.env` file with your own credentials and urls to be accessed of each component.
- Start running `deploy.sh` script to initiate containers building, It might take some time depends in the resources and network connection.

```bash
chmod 750 deploy.sh
./deploy.sh
```
- After script finishes the installation, run `docker-compose ps` and make sure that all containers are in **UP** status.
- When the deployment is done you will need to generate API tokens for **MISP** and **Cortex** to be integrated with **TheHive** , And use **Shuffle** to connect and automate between the elastic security and the rest of the components.
  - For example the Generated tokens should be added in `cortex/application.conf` , `thehive/application.conf` for the two components.
 
# Contact Me
If you need to deploy this in a production environment or any kind of help, Contact me on telegram [@dh4ze](https://t.me/dh4ze)
