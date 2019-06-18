## Deploying WordPress on Elastic Beanstalk using Terraform

Use [Terraform](https://www.terraform.io/) to create an Elastic Beanstalk environment with an attached RDS DB and EFS file system to provide WordPress with a MySQL database and shared storage for uploaded files.

NOTE: Amazon EFS is not available in all AWS regions. Check the [Region Table](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/) to see if your region is supported.

These instructions were tested with WordPress **5.2.1**
        
### Install Terraform
        
https://learn.hashicorp.com/terraform/getting-started/install

### Set up your project directory

1. Edit `dev.tfvars` to specify your AWS Access Key and Secret, and other custom variables.

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html

### Networking configuration

*NOTE: This automation assumes an existing VPC with 1 or More Subnets.*

Modify the configuration files `dev.config` and `efs-create.config` with the IDs of your [default VPC and subnets](https://console.aws.amazon.com/vpc/home#subnets:filter=default), and [your public IP address](https://www.google.com/search?q=what+is+my+ip).

 - `dev.config` restricts access to your environment to your IP address to protect it during the WordPress installation process. Replace the placeholder IP address near the top of the file with your public IP address.
 - `efs-create.config` creates an EFS file system and mount points in each Availability Zone / subnet in your VPC. Identify your default VPC and subnet IDs in the [VPC console](https://console.aws.amazon.com/vpc/home#subnets:filter=default). If you have not used the console before, use the region selector to select the same region that you chose for your environment.

#### WARNING: EFS lifecycle

Any resources that you create with configuration files are tied to the lifecycle of your environment. They are lost if you terminate your environment or remove the configuration file.
Use this configuration file to create an Amazon EFS file system in a development environment. When you no longer need the environment and terminate it, the file system is cleaned up for you.
For production environments, consider creating the file system using Amazon EFS directly.
For details, see [Creating an Amazon Elastic File System](http://docs.aws.amazon.com/efs/latest/ug/creating-using-create-fs.html).

### Get required files and Create AWS Infrastructure

###### Bash script

1. Initialize Terraform for the AWS Provider

        ~$ terraform init

2. Run the provided build script:

        ~$ chmod u+x build.sh
        ~$ ./build.sh
        
3. Apply the Terraform plan

        ~$ terraform apply "tfplan"

###### Manual

1. Download WordPress.

        ~$ wget https://wordpress.org/wordpress-5.2.1.tar.gz

2. Download the configuration files in this repository.

        ~$ wget https://github.com/awslabs/eb-php-wordpress/releases/download/v1.1/eb-php-wordpress-v1.zip

3. Extract WordPress and the EB configuration files

        ~$ tar -xvf wordpress-5.2.1.tar.gz && mv wordpress wordpress-5.2.1-beanstalk && cd wordpress-5.2.1-beanstalk && unzip ../eb-php-wordpress-v1.zip

4. Copy our previously edited Network files and Apache access directives to .ebextensions

        ~$ cp ../*.config ../.htaccess .ebextensions/

5. Zip the directory to prepare for deployment

        ~$ zip ../wordpress-5.2.1-beanstalk.zip -r * .[^.]* && cd ..

6. Initialize Terraform for the AWS Provider

        ~$ terraform init

7. Generate the Terraform plan, and then run manually (to be cautious)

        ~$ terraform plan -var-file=dev.tfvars -out "tfplan"
        var.bucket_name
        S3 Bucket to store Application Source (Elastic Beanstalk) and other Application data (i.e., Data Lake for Analytics)

        Enter a value: wordpress-5.2.1-beanstalk
        
        var.project_source
        Application Source (Elastic Beanstalk); env. var. exported from build.sh script

        Enter a value: wordpress-5.2.1-beanstalk.zip
        
        var.project_version
        Application Version (Elastic Beanstalk); env. var. exported from build.sh script

        Enter a value: wordpress-5.2.1-beanstalk
        ...
        ...
        ...
        Plan: 6 to add, 0 to change, 0 to destroy.
     
8. Apply the Terraform plan (takes ~10 mins to create the 6 resources)

        ~$ terraform apply "tfplan"
        ...
        ...
        ...
        Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

#### NOTE: security configuration

This project includes a configuration file (`loadbalancer-sg.config`) that creates a security group and assigns it to the environment's load balancer, using the IP address that you configured in `ssh.config` to restrict HTTP access on port 80 to connections from your network. Otherwise, an outside party could potentially connect to your site before you have installed WordPress and configured your admin account.

You can [view the related SGs in the EC2 console](https://console.aws.amazon.com/ec2/v2/home#SecurityGroups:search=wordpress-beanstalk).

### Deploy source bundle (application) and Install WordPress

1. Open the [Elastic Beanstalk console](https://console.aws.amazon.com/elasticbeanstalk)

2. Navigate to the [management page](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-console.html) for your environment

3. Click 2nd breadcrumb link: All Applications > **[my-project]**

4. Click "Application versions" link

5. Select the option for `wordpress-5.2.1-beanstalk` and click **Actons** and select **Deploy** and click **Deploy** button (takes ~3 mins, and Events are printed during the deployment process)

6. Navigate back to the [management page](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-console.html) for your environment and wait for the source bundle (application) to deploy

7. Choose the environment URL to open your site in a browser. You are redirected to a WordPress installation wizard because you haven't configured the site yet.

You are redirected to the WordPress installation wizard because the site has not been configured yet.

Perform a standard installation. The `wp-config.php` file is already present in the source code and configured to read database connection information from the environment, so you shouldn't be prompted to configure the connection.

### Updating keys and salts

The WordPress configuration file `wp-config.php` also reads values for keys and salts from environment properties. Currently, these properties are all set to `test` by the `wordpress.config` configuration file in the `.ebextensions` folder. (The hash salt can be any value but shouldn't be stored in source control). 

1. Open the [Elastic Beanstalk console](https://console.aws.amazon.com/elasticbeanstalk)

2. Navigate to the [management page](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-console.html) for your environment

3. On the navigation pane, choose **Configuration**

4. Under **Software**, choose **Modify**

5. For `Environment properties`, modify the following properties:

        AUTH_KEY – The value chosen for AUTH_KEY.

        SECURE_AUTH_KEY – The value chosen for SECURE_AUTH_KEY.

        LOGGED_IN_KEY – The value chosen for LOGGED_IN_KEY.

        NONCE_KEY – The value chosen for NONCE_KEY.

        AUTH_SALT – The value chosen for AUTH_SALT.

        SECURE_AUTH_SALT – The value chosen for SECURE_AUTH_SALT.

        LOGGED_IN_SALT – The value chosen for LOGGED_IN_SALT.

        NONCE_SALT — The value chosen for NONCE_SALT.

6. Choose Apply

Setting the properties on the environment directly overrides the values in wordpress.config. 

### Remove the custom load balancer configuration to open the site to the Internet.

The sample project includes a configuration file (loadbalancer-sg.config) that creates a security group and assigns it to the environment's load balancer, using the IP address that you configured in dev.config to restrict HTTP access on port 80 to connections from your network. Otherwise, an outside party could potentially connect to your site before you have installed WordPress and configured your admin account.

Now that you've installed WordPress, remove the configuration file to open the site to the world.

1. Delete the .ebextensions/loadbalancer-sg.config file from your project directory.

        ~$ ~/wordpress-5.2.1-beanstalk$ rm .ebextensions/loadbalancer-sg.config

2. Create a source bundle.

        ~$ ~/eb-wordpress$ zip ../wordpress-5.2.1-beanstalk-v2.zip -r * .[^.]*

Upload the source bundle to Elastic Beanstalk to deploy WordPress to your environment.

### To deploy a source bundle

1. Open the [Elastic Beanstalk console](https://console.aws.amazon.com/elasticbeanstalk)

2. Navigate to the [management page](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-console.html) for your environment

3. Choose **Upload and Deploy**

4. Choose **Choose File** and use the dialog box to select the source bundle.

5. Choose **Deploy**

When the deployment completes, choose the site URL to open your website in a new tab.

### To configure your environment's Auto Scaling group for high availability

1. Open the [Elastic Beanstalk console](https://console.aws.amazon.com/elasticbeanstalk)

2. Navigate to the [management page](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-console.html) for your environment

3. Choose **Configuration**

4. On the **Capacity** configuration card, choose **Modify**

5. In the **Auto Scaling Group** section, set **Min instances** to 2.

6. Choose **Apply**

To support content uploads across multiple instances, the sample project uses Amazon Elastic File System to create a shared file system. Create a post on the site and upload content to store it on the shared file system. View the post and refresh the page multiple times to hit both instances and verify that the shared file system is working. 

### Updating WordPress

Do not use the update functionality within WordPress or update your source files to use a new version. Both of these actions can result in your post URLs returning 404 errors even though they are still in the database and file system.

To update WordPress, perform these steps.
1. Export your posts to an XML file with the export tool in the WordPress admin console.
2. Deploy and install the new version of WordPress to Elastic Beanstalk with the same steps that you used to install the previous version. To avoid downtime, you can create a new environment with the new version.
3. On the new version, install the WordPress importer tool in the admin console and use it to import the XML file containing your posts. If the posts were created by the admin user on the old version, assign them to the admin user on the new site instead of trying to import the admin user.
4. If you deployed the new version to a separate environment, do a [CNAME swap](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.CNAMESwap.html) to redirect users from the old site to the new site.

### Backup

Now that you've gone through all the trouble of installing your site, you will want to back up the data in RDS and EFS that your site depends on. See the following topics for instructions.

 - [DB Instance Backups](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.BackingUpAndRestoringAmazonRDSInstances.html)
 - [Back Up an EFS File System](http://docs.aws.amazon.com/efs/latest/ug/efs-backup.html)
 
 ### Destroy AWS Infrastructure
 
 1. Generate the Terraform plan, and then run manually (to be cautious)

        ~$ terraform plan -var-file=dev.tfvars -destroy -out "tfplan-destroy"
        var.bucket_name
        S3 Bucket to store Application Source (Elastic Beanstalk) and other Application data (i.e., Data Lake for Analytics)

        Enter a value: wordpress-5.2.1-beanstalk
        
        var.project_source
        Application Source (Elastic Beanstalk); env. var. exported from build.sh script

        Enter a value: wordpress-5.2.1-beanstalk.zip
        
        var.project_version
        Application Version (Elastic Beanstalk); env. var. exported from build.sh script

        Enter a value: wordpress-5.2.1-beanstalk
        ...
        ...
        ...
        Plan: 0 to add, 0 to change, 6 to destroy.
        
2. Apply the Terraform plan (takes ~10 mins to destroy the 6 resources)

        ~$ terraform apply "tfplan-destroy"
        ...
        ...
        ...
        Apply complete! Resources: 0 added, 0 changed, 6 destroyed.
