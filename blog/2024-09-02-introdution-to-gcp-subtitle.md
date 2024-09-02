---
title: Introduction to Google Cloud Subtitle
description: Microsoft Azure Questions and Answers
tags: [google, cloud platform, subtitle]
hide_table_of_contents: false
---

**Introduction:**
PRIYANKA VERGADIA: Welcome to "Build with Google Cloud," where we build things, reference architectures that can help you make your Google Cloud journey a little bit easier.

**Setting the Scene:**
Imagine you are a Cloud architect for foo.com, an internet-accessible application. There are many different ways to architect such an application on Google Cloud. No one way is right or wrong. I'm Priyanka Vergadia, developer advocate here at Google Cloud. And today, I'm going to walk you through one such way. You ready? Let's go.

**Explaining the Architecture:**
Let's say our internet-facing application is foo.com and our users are accessing it by typing foo.com in the browser. What happens next? We've written code for this application and deployed it on a web server.

Initially, let's say our application is decently popular with minimal functionality and this one server is enough to handle the traffic. Our users will access this application at foo.com, but how would the request reach the web server? On the internet, every single device has an IP address which other devices use to communicate with each other.

The request from the user's computer goes to the DNS server, which responds back with an IP address that is used by the user's computer to then make a connection to our server. Great.
<!-- truncate -->

But our website also has some business logic. For that, we add an additional application server to handle some backend processing, such as authentication servers, inventory, payment services, and things like that.

**Database and Scaling:**
Then comes the database. Now, every modern web application leverages one or more databases to store information. It could be a relational or nonrelational database, depending on the type of data and the use case.

Let's come back to that in just a little bit. Now, let's say our app becomes really popular and the one server we have is just not enough. We need to scale our servers to handle the increased traffic. We have two options here: We could either scale vertically by increasing the size of our machines, giving it more memory and more CPU. Or we could scale horizontally by adding more servers to the equation.

You will find that scaling horizontally, or scaling out, is almost always a good idea because it gives you more flexibility. With vertical scaling, we reach a limit at a certain point beyond which we really won't be able to add any more memory or CPU. And at that point, you will have to scale horizontally.

I would like to know if you've tried scaling an application vertically or horizontally and how it went. What was the use case and why did you make that choice of scaling up or out?

**Load Balancing and More:**
Now that we have more than one server, we also have more than one IP addresses for these servers. So we need something to balance the load to our servers. That's where the load balancer comes in. It distributes the traffic to the servers. There are lots of different algorithms that a load balancer can be set up for, such as round robin where routing to the server would be in a cyclic pattern, or global where traffic would be routed based on where it's coming from. 

For example, a request from Asia is sent to the server in Asia. Now, weighted weight load balancing is based on load and performance. For example, if a load on the server reaches, say, 70%, send traffic to another one. And you can add a combination of a bunch of these rules.

We also add an internal load balancer that does the same for our internal application servers.

**Database Focus:**
Let's focus our attention on the database. For applications with heavy transaction processing where you need to ensure that the transactions are accurate, consistent, isolated, and durable, also called ACID, relational databases should be used. Relational databases, or also called SQL databases, store data in tables. 
You have the predefined schema prior to filling the table and the tables are linked with each other through keys. For applications that require analysis of data, nonrelational databases have emerged to handle massive amounts of data and process it to generate really meaningful insights out of them.

Most NoSQL databases can scale horizontally. What kind of database are you using in your application and why you made that choice? I would love to know. Share with me in the comments.

When it comes to scale, we also reduce the load on the database for the frequently accessed data. For this reason, relational databases leverage in-memory database cache. So the app servers don't hit the database for every single request, rather, those requests are served from the database cache, such as Memcached or Redis.

**Handling Media Files:**
Now, the next part of the equation is media files. We typically never save our images, video files, and static content on the web and application servers. Such object files are better stored in external Blob storage. They usually save the metadata for those objects as the database, and the file is in external storage.

Your mobile devices will need a different image size and resolution than your desktop app. Or you can still have videos that need transcoding. For that sort of processing logic, you write a function code that triggers every time a file gets uploaded into your storage.

**Consider Global Distribution:**
Now, consider this. If a file is frequently accessed, say, a popular video or an image on the website, and your users are distributed globally, then you don't want to access the file every time from external storage. You would rather want to cache the file closer to the user for lower costs, low latency, and overall better performance.

Additionally, there might be push or email notifications that you need to send to the user for certain things. For those, we can use an asynchronous messaging service, push notifications in it, and then have a server subscribe to that queue to send those notifications out to users through another service.

**Focus on Analytics:**
Next part of the puzzle is analytics. We usually have two types of data to ingest into the analytics system, the real-time data and the batch data. The real-time could be content from servers such as ClickStream data or, from IoT devices, sensors. The batch data could be from your logs. These are just examples.

What types of real-time and batch data are you collecting for analytics and processing? Let's discuss more in the comments.

Once the data is ingested, we process and enrich it to clean it up and make it ready for downstream systems, then store it in a data warehouse for further analysis. Now, data warehouse is a storage where you keep processed data.

The data from our databases could also be aggregated, processed, and saved in the data warehouse for further analysis. You might have heard the term ETL, Extract, Transform, and Load. That's what that is, but ETL is usually applied to batch data.

Now, data analysts then analyze the data and create dashboards for broader consumption. And then data scientists and your machine learning teams can pick up that data from the data warehouse and use it for creating machine learning models to generate predictions.

You could also directly ingest data from storage systems for the ML models. The term that I did not describe here is data lake. Do you know what it is and where does it fit in this puzzle? Drop it in the comments and I'll chime into the discussion.

**Back to foo.com Application:**
Back to our application. We also need to make sure we holistically monitor our servers at every part of the architecture and we need to make sure all this is secure in a private network. Use a firewall to ensure that the servers that should not be exposed to the public internet are not, and the ones that should talk to each other can.

We also need to make sure that developers have the right access to build the apps, DevOps teams have the access to deploy them, and data analysts have access to analyze the data, and other such access-related rules around application security, data security, and infrastructure security.

**Challenge to the Audience:**
Now, if you were a Cloud architect for foo.com, how would you translate this architecture onto Google Cloud? There are so many different ways of achieving the same goal. No one way is right or wrong. Let me show you one of my approaches, but I would love to know how you would do it. I'm sure your approach is another unique one that everyone watching would benefit from.

So share it in the comments, and I'll chime in if you comment in the first seven days.

**Building on Google Cloud:**
The first thing is to create a virtual private cloud which provides managed networking functionality for all of our Google Cloud resources. For our application infrastructure, the web, and app servers, we have multiple options, depending on multiple factors.

If I have got a small team of developers, their time is better spent coding and not worrying about infrastructure and scaling tasks. Serverless options such as Cloud Run, App Engine would be great picks.

Both are serverless and scale with no effort as your traffic grows. Cloud Run offers the ability to run serverless containers, not just supporting web traffic, but also web sockets and gRPC.

If we want to run containerized apps but with more configuration and flexibility, then we would pick Google Kubernetes Engine. It helps us deploy, containerize apps with Kubernetes without much of a learning curve while giving us the control over configuration of nodes that we want in our infrastructure.

GKE also offers autopilot for when you need the flexibility and control but have limited ops and engineering support. The maximum control option is Compute Engine. It is straight up virtual machines.

So we can define the configuration of our machines depending on what the amount of memory and CPU we need. But this control also means more responsibility to scale, manage, patch, and maintain them as needed.

My recommendation would be to use Compute Engine for legacy applications or applications that require high CPU and memory with specific needs in situations that truly require full control because you will need a bigger, better operations team to manage.

**Exploring Compute Options:**
Which of these compute options are you using today? And what do you like about it? I would love to know. Share with me in the comments.

**Discussing Load Balancing:**
Now comes the time when we need to balance the load across our compute choices. Cloud load balancing is a fully distributed, software-defined system. It can literally respond to over a million queries per second and is based on any past IP address.

What does that mean? Well, it means that we can define our frontend infrastructure with a single IP address. If we had global users coming from, say, Asia, US, Europe, it can serve requests from a server that is as close to them as possible.

It also offers internal load balancing for our internal application servers, so we can route traffic amongst them as needed. Right at the load balancer, we have an option to enable Cloud CDNs to cache the frequently requested media and web content closer to the user at the nearest edge location.

This reduces latency and optimizes for last-mile performance for our users. It also saves costs by fielding the request right at the edge without needing to send it to the back end. And Cloud CDN would be caching content that is stored in Cloud Storage, our object store where we store all of our media assets, CSS, JavaScript, images, basically everything static in nature.

**Managing DNS and Media Processing:**
Now, Cloud DNS is Google's infrastructure for high volume, authoritative DNS serving, which offers 100% SLA, meaning it never goes down. It uses our global network of Anycast name servers to serve the DNS zone from the redundant location around the world, providing that high availability and low latency for the users.

This media processing function can be deployed on Cloud Functions, which is serverless function as a service that scales as needed and can be triggered from Cloud Storage and any other service.

**Messaging and Databases:**
For asynchronous messaging service, we would use Pub/Sub and send messages to a topic, and then the service could subscribe to that topic to receive those messages and send out those notifications and do other things with it if needed.

Now, coming to databases, we have a few choices here. For relational databases, we have Cloud SQL and Spanner. They are both managed. For generic SQL needs, MySQL, Postgres, and SQL Server, Cloud SQL is perfect.

Spanner is best for massive scale relational database that needs horizontal scaling. By massive, I mean thousands of writes per second and tens of thousands of reads per second. And while doing so, it also supports strong consistency and asset transactions.

I would say you use Spanner when you need the benefits of both relational and non-relational databases. For nonrelational databases, we have three major options: Firestore, Bigtable, and Memorystore.

Firestore is a serverless document database that can be used as a database as a service which is easy to set up and provides fast results to complex queries in real-time. It also supports offline data and syncs, which makes it a great choice for mobile use cases, along with web, IoT, and gaming.

Now, Bigtable, on the other hand, is a wide-column NoSQL database that supports heavy reads and writes with extremely low latency. This makes it a perfect choice for events, time series data from IoT devices, ClickStream, event fraud, recommendations, and other personalization-related use cases.

Memorystore is a fully managed, in-memory data storage service for Redis and Memcached at Google Cloud. It is best for in-memory and transient data stores and automates the complex tasks of provisioning, replication, failover, and patching, so you can spend more time coding.

Because it offers extremely low latency and high performance, Memorystore is great for web and mobile, gaming, leaderboard, social, chat, news feeds-types of applications, along with in-memory database caches.

I would love to know which database options you're using. Share them with me in the comments.

**Discussing Analytics:**
Now comes the analytics piece. We can ingest the batch data from Cloud Storage and real-time data from the applications using Pub/Sub, which is a serverless messaging service that scales to ingest millions of events per second.

Data flow can be used for processing and enriching the batch and streaming data. It is based on open-source Apache Beam. You could use dataprep instead for processing if you are looking to do the transformations with the UI in a no-code fashion.

But if you're in a Hadoop ecosystem, then Dataproc would be a better choice for processing. It is a managed Hadoop and Spark platform that sets up to Analyze the data faster instead of worrying about managing and standing up your Hadoop cluster.

We just need to change that HDFS link to point to Cloud Storage, and everything else just works exactly the same as it would on your Hadoop cluster.

BigQuery is a serverless data warehouse that supports SQL queries and can scale to petabytes of data. It can also act as your long-term storage and a data lake. We can run SQL queries to analyze our data within BigQuery, and it literally queries over petabytes of data and responds in seconds due to the underlying separation of storage from compute that's needed to run that query.

We can use this data from BigQuery to create a dashboard in Looker or Data Studio. It also offers machine learning capabilities, so we can create ML models and make predictions by just writing some SQL statements.

So, all in all, BigQuery is amazing. If we want, we can do all our data analytics with just BigQuery. Do you do that? Let me know in the comments.

**Machine Learning and AI:**
Now, for machine learning and AI projects, we can use the data in BigQuery to train our models in Vertex AI, or we can import our media files, images, and other unstructured data sets from Cloud Storage as well.

ML/AI, our options depend really on whether we want to create our own custom models or use pretrained models. My recommendation is always to start with a pretrained model. See if it works for you. Most common use cases are all covered, including images, text, videos, and tabular data.

If a pretrained model does not work for your use case, then you can use the AutoML version within Vertex AI to train a custom model on your data set. Again, you'll be doing less coding in this case.

AutoML supports all your common use cases. In case you have lots of ML and data science experience in-house, that is only when I would say, write your own custom model code in the frameworks of your choice, TensorFlow, PyTorch, or whatever you choose.

**Operations, Monitoring, and Security:**
Next. For operations, monitoring, debugging, and troubleshooting, the Cloud Operations Suite offers all the tools that you need to troubleshoot.

When it comes to security, understand that security in the Cloud is a shared responsibility. Google Cloud offers those inherent infrastructure security and tools that you would need to protect your application, your data, and your software.

Now, how do you make sure your data is secure? Well, data is always encrypted, addressed, and in transit when on Google Cloud. You can use confidential computing VMs to also encrypt data in use for sensitive workloads.

You can also bring your own custom keys for encryption, and there are multiple options for that with key management service where you can manage your own keys in Google Cloud. You can use an external key manager or hardware security model for data loss prevention.

And protecting PII information, you have DLP which helps mask and tokenize sensitive data in BigQuery, Cloud Storage, or even on-prem.

**User Access and Application Security:**
How do you make sure the right users have the right access? For user authentication, you have Cloud Identity which checks if the user is who they say they are. And for authorization, you have Cloud IAM, where you can define who has access to what.

How do you make sure your applications are secure? For an application like `<foo.com>`, which is an internet-facing application, the application security and API security solution are provided, where you can use reCAPTCHA for generating a token.

reCAPTCHA Enterprise deciphers the token in the incoming request and then enforces or allows or denies the decisions in Cloud Armor. If Cloud Armor allows the request, then it is forwarded to a load balancer and load balancer then sends the request to a respective backend with Apigee API gateway in the middle, which allows or denies or routes API calls based on client credentials and quotas.

**Monitoring Systems for Security:**
How do you monitor your systems for security? Well, the Security Command Center continuously monitors your Google Cloud environment for visibility into the system. It discovers vulnerabilities, it detects threats, and then shows them so you can take action on them.

There's a lot more in security that I'm not covering here. Let me know which topics you would like to learn more in the comments.

**CI/CD Process:**
Now, how does CI/CD work? As a developer, I would write the code for an application. I can use Cloud Code within IDE, push the code to Cloud Build, which then packages and tests it, runs vulnerability scans on it, binary authorization, then checks for trusted images.

And once the tests are passed, it deploys the package to staging using Cloud Deploy. From there, you can create a process to review and promote the application to production. In the case of containers, the container images are stored in an artifact registry from which they can be deployed to GKE or Cloud Run.

If you stuck around this far, then congratulations! You just learned most of the Google Cloud Services for networking, compute, storage, databases, data analytics, machine learning, AI, security, operations, CI/CD. 

There is definitely a lot more to explore, but I'm confident this will get you started with the right background.

_Youtube_ [https://www.youtube.com/watch?v=IeMYQ-qJeK4](https://www.youtube.com/watch?v=IeMYQ-qJeK4)
