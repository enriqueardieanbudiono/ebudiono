# Exercises - Chapter 04 Application Architecture

1. Describe the single-machine, three-tier, and four-tier web application architectures in detail.
    - Single Machine
        - A single self-sufficient machine used to provide web services. The machine runs software that speaks the HTTP protocol, receiving request, processing them, generating a result, and sending the reply.
    - Three-Tier
        - A three-tier architecture is a pattern built from three layers: the load balancer layer, the web server layer, and the data service layer. The web servers all rely on a common backend data server, often an SQL database. The load balancer layer is responsible for receving request enter from the user. The load balancer picks on of the machines in the middle layer and relays the request to that web server. The web server process the request, possibly querying the database to aid it in doing so. The web server then sends the result back to the load balancer, which then sends it back to the user.
    - Four-Tier
        - A four-tier architecture is used when there are many individual applications with a common frontend infrastructure. The web requests come in to the load balancer, which divides the traffic among the various frontends. The frontends handle interactions with the users, and communicate to the application servers for the content that user want. The application servers access shared data sources in the final layer.

2. Describe how a single-machine web server, which uses a database to generate content, might evolve to a three-tier web server. How would this be done with minimal downtime?
    - A single machine web server can evolve to a three-tier web server by using the Multiple Data Store method. In this method, there are many different data stores that each replica has access to, or can be shared. Each data store can also be assigned to a particular task or purpose. This can reduce downtime as there is not a single database to query.

3. Describe the common web service architectures, in order from smallest to largest (hint 4 of them remember the Cloud Scale or Cloud tier as number 4).
    -  The common web service architectures from smallest to largest are:
        - single-machine
        - three-tier
        - four-tier
        - cloud-scale

4. Describe how different local load balancer types work and what their pros and cons are. You may choose to make a comparison chart.
    - **Round Robin (RR)**:
        - machines are rotated by consecutive order (A-B-C-A-B-C); can be timely
    - **Weighted RR**:
        - similar to RR with more queries and capacity; a particular backend will be able to handle more traffic than the others (A-C-B-C); can be timely
    - **Least Loaded (LL)**:
        - each load balancer reports its load status, and the least loaded will handle requests; can become flooded with queries
    - Least Loaded with Slow Start:
        - similar to LL, starts sending low rate of traffic to LL backend; can be timely
    - **Utilization Limit**:
        - calculates how many QPS can be handled and sends this to the load balancer where estimations can be based on data from synthetic load tests
    - **Latency**:
        - load balancer stops forwarding requests to backend based on latency of recent requests; manages bursts of slow requests
    - **Cascade**:
        - first replica takes all request until capacity, then overflow continues forward; load balancer must know how much traffic each replica can handle

5. What is “shared state” and how is it maintained between replicas?
    - Share State:
        - a state that all processes can access, and have it be consistent. To maintain shared state
    - Maintained between replicas:
         - **Sticky Connections**: a user's previous HTTP request was sent a particular backend, so the next one will too
        - **Shared State**: for each HTTP connection, the user's state will be fetched where their profile info is stored (somewhere all backends can access)
        - **Hybrid**: using both sticky and shared methods to deal with user's state moving around backends

6. What are the services that a four-tier architecture provides in the first tier?
    -  Four-tier architecture provides services in the first tier, or frontend, for user interactions like login, profile, and preferences.

7. What does a reverse proxy do? When is it needed?
    - Reverse Proxy enables one web server to provide content from another web server transparently. The user sees one cohesive web site, even though it is actually made up of a patchwork of applications. For example, suppose there is a web site that provides users with sports news, weather reports, financial news, an email service, plus a main page

8. Suppose you wanted to build a simple image-sharing web site. How would you design it if the site was intended to serve people in one region of the world? How would you then expand it to work globally?
    - To build a web-site in one area of the world, we would invest in data servers that are nearby to get the fastest request possible. To expand, we want to bring data and computation servers closers to the users. We would build or rent data centers across the globe and then replicate the services.

9. What is a message bus architecture and how might one be used?
    - Message bus architecture: a many-to-many communication mechanism between servers.
    - How might one be used: a way to distribute information among different services. For example, system administration systems, web-based services, and enterprise systems.

10. Who was Christopher Alexander and what was his contribution to architecture?
    - Christopher Alexander was an architect and design theorist that said "patterns are solutions to recurring problems in a context". For cloud computing, patterns and replicas are one of the most important factors in creating a seamless web service.