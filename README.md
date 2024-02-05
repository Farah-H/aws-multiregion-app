# AWS Multi-Region Deployment

These notes are in chronological order, each section represents a commit to main.

## 1. The Basics
A) Structure: moving terraform configuration to terraform.tf file to define state and version constraints. Also, this code should run on a newer version with no issue, so checking that this is the case then locking in that constraint, to save time by using what I've already got installed. 

I've used remote state for safety. When running this on another AWS account, you must either comment out the `terraform` block or manually create a bucket which matches the configuration. In a real prod env, I would also implement dynamodb state locking, or use a tool such as [atlantis](https://www.runatlantis.io/) to prevent simltaneous writes to state. 

B) Authentication: I'm using a personal sandbox account, so used my existing long-lived credentials. In a prod environment, I would set up role-based access for devs to run `terraform plan` with readonly locally, and apply using a CI/CD pipeline or plugin. 

C) Checked that the original code does work, but only in HTTP, which is expected. In a prod env there'd be ssl certs, but in this case I have updated the output, for ease and clarity. 

## 2. Replicating the stack to another region 
I believe the best way to achieve this is to use modularisation for the VPC, and to have seperate directories for each region. The AWS VPC module is quite good, and is often used in production. If there was a usecase where there is a specific configuration that isn't easily achieved by the module, then it would make more sense to build the VPC from scratch like this. 

I also want to get rid of the `tfvar` files here. It's ugly when deploying in a wrapper (as the apply command has to be parametised). As most of these variables would not be changed by a user on most applies, it's better to use `local` blocks here, in my opinion. 

Now is also a good time to implement VPC endpoints and improve security, specifically to allow admin users with access to assume an ssm role to login to the instances for debugging, without the need to open ssh ports. The instances also don't need public IPs.

Regarding the location of terraform modules, it's good practice to have them in a seperate repository, so that they can be versioned seperately in different environments / regions, but in this case they're here. 