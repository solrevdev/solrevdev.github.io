---
layout: post
title: "Deleting nearline storage via gsutil"
author: "John Smith"
tags:
- "#google-cloud"
- "#nearline"
- "#cli"
---

In order to save some cash after seeing some recurring Google invoices for their [nearline storage](https://cloud.google.com/storage/docs/storage-classes) buckets prompted me to realise that I was paying for storage that was essentially just a test of what I at the time considered to be a match for Amazon's [S3](https://aws.amazon.com/s3/) and [Glacier](https://aws.amazon.com/glacier/) storage. 

Now they do have a nice [console web app](https://console.cloud.google.com/) and an [iOS app](https://itunes.apple.com/us/app/google-cloud-console/id1005120814?mt=8) to manage these but attempts at deleting my buckets of data did not work. 

Probably due to the size of the storage.  

---

So, a quick search and I found they have a [CLI SDK](https://cloud.google.com/sdk/docs/) which would enable me to run a delete command from the Mac Terminal.

The following are instructions for Mac but the [docs](https://cloud.google.com/sdk/docs/) should cover others including windows. 

---

* Download the [Python](https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-116.0.0-darwin-x86_64.tar.gz) package 
* Extract it to a folder in your home directory such as  `~/google-cloud-sdk`  
* Run the install script `./google-cloud-sdk/install.sh`
* Initialize the SDK `./google-cloud-sdk/bin/gcloud init`

>Welcome! This command will take you through the configuration of gcloud.
 
>Your current configuration has been set to: [default]
 
>To continue, you must login. Would you like to login (Y/n)?


* Follow the rest of the setup and then once you have chosen the project that contains the bucket you want to delete you can run the following command however do note this will **delete all your data** so do know that is what you are doing here! 

>  `$ gsutil rm -r gs://INSERT-NAME-OF-BUCKET/`


---

And this is what you should see : 

![alt text](http://static.solrevdev.com.s3.amazonaws.com/blog/gsutil.gif_1.gif "gsutil deleting a bucket")







