# Chapter 01 - Designing for a Distributed World

1. What is distributed computing?
    - Distributed computing is the art of building large systems that divide the work
over many machines.

2. Describe the three major composition patterns in distributed computing.
    1. load balancer with multiple backend replicas
    2. Server with multiple backends
    3. Server tree

3. What are the three patterns discussed for storing state?
    1. On single machine
    2. fractions or shards replicated across individual machines
    3. updates using cached data
    
4. Sometimes a master server does not reply with an answer but instead replies with where the answer can be found. What are the benefits of this method?
    - the answer's location saves the master server from overloading. This way, the requestor can contact the machines with the needed information directly.

5. Section 1.4 describes a distributed file system, including an example of how reading terabytes of data would work. How would writing terabytes of data work?
    - Distribute a the chunks of terabytes of data to multiple machines. 

6. Explain each component of the CAP Principle. (If you think the CAP Principle is awesome, read “The Part-Time Parliament” (Lamport & Marzullo 1998) and “Paxos Made Simple” (Lamport 2001).)
    - Consistency
        - All nodes see the same data at the same time. Consistency means that when something got updated, all the nodes will update and go live at the same time.
    - Availability
        - a guarantee that every request receives a response about whether it was successful or failed. This means that if one replicas is down, there will be at least one replica that guranatees to be up and running.
    - Partitioning Tolerance
        - The system continues to operate despite arbitary message loss or failure of part of the system. This means that if the machine that providing the service or the data lose ability to communicate with the other machines, the system will still be able to operate.

7. What does it mean when a system is loosely coupled? What is the advantage of these systems?
    - Loosely coupled systems are systems that are not dependent on each other. The advantage of these systems is that a subsystem can be replaced by one that provids the same abstract interface even if its implementation is completely different.

8. How do we estimate how fast a system will be able to process a request such as retrieving an email message?
    - To esitame how fast a system will be able to process a request, we need to know the distance from the user to the datacenter and the number of disk seeks required.

9. In Section 1.7 three design ideas are presented for how to process email deletion requests. Estimate how long the request will take for deleting an email message for each of the three
    1. First Design: contact the server and delete the message from the storage system and the index.
        * Send packet from California to Netherlands to California (150 ms)
        * Disk Seek (10 ms) x 3
        * Read 1MB from disk (30 ms)
        * = 210 ms estimation for deleting an email message.
    2. Second Design: the storage system simply mark the message as deleted in the index.
        * Disk Seek (10 ms) x 3
        * Read 1MB from disk (30 ms)
        * = 60 ms estimation for deleting an email message.
    3. Third Design: Asynchronous design.
        * Disk Seek (10 ms) x 3
        * = 30 ms estimation for deleting an email message.
