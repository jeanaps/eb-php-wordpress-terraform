#!/bin/bash

CURR_DATE=`date +%Y%m%d`
WP_VERSION="5.2.1" #"4.9.5"
AWS_EB_WP_VERSION="v1"
APP_DIR="wordpress-$WP_VERSION-beanstalk"
APP_FILE="$APP_DIR.zip"

# Terraform vars
export TF_VAR_project_version="$APP_DIR"
export TF_VAR_project_source="$APP_FILE"
export TF_VAR_bucket_name="$APP_DIR-$CURR_DATE"

# Download WordPress from wordpress.org 
wget https://wordpress.org/wordpress-$WP_VERSION.tar.gz

# Download the configuration files from the sample repository
wget https://github.com/aws-samples/eb-php-wordpress/releases/download/v1.1/eb-php-wordpress-$AWS_EB_WP_VERSION.zip

tar -xvf wordpress-$WP_VERSION.tar.gz && mv wordpress $APP_DIR && unzip eb-php-wordpress-$AWS_EB_WP_VERSION.zip -d $APP_DIR

cp *.config .htaccess $APP_DIR/.ebextensions/
cd $APP_DIR && zip ../$APP_FILE -r * .[^.]* && cd ..

# output the Terraform plan, and then run manually (to be cautious)
terraform plan -var-file=dev.tfvars -out "tfplan"
#terraform plan -var-file=dev.tfvars -destroy -out "tfplan-destroy"
