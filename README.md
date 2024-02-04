# AWS Multi-Region Deployment

## 1. The Basics
A) Structure: moving terraform configuration to terraform.tf file to define state and version constraints. Also, this code should run on a newer version with no issue, so checking that this is the case then locking in that constraint, to save time by using what I've already got installed. 

I've used remote state for safety. When running this on another AWS account, you must either comment out the `terraform` block or manually create a bucket which matches the configuration. In a real prod env, I would also implement dynamodb state locking, or use a tool such as [atlantis](https://www.runatlantis.io/) to prevent simltaneous writes to state. 

B) Authentication: I'm using a personal sandbox account, so used my existing long-lived credentials. In a prod environment, I would set up role-based access for devs to run `terraform plan` with readonly locally, and apply using a CI/CD pipeline or plugin. 

C) Checked that the original code does work, but only in HTTP, which is expected. In a prod env there'd be ssl certs, but in this case I have updated the output, for ease and clarity. 