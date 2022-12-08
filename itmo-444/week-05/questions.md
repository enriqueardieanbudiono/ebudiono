# Chapter 2 Designing for Operations

Place your answers below each question.  Answer are found directly in the text.

1. Why is design for operations so important?
    - it makes sure that all normal operational functions are done well and run smoothly. It is relied on for users to perform tasks in its infrastructure life cycle. It should not only benefit the end user, but the operations itself.
2. How is automated configuration typically supported?
    1. Make a backup of a configuration and restore it
    2. View the difference between one archived copy and another revision
    3. Archive the running configuration without taking the system down
3. List the important factors for redundancy through replication.
    1. services must be designed initially for redundancy
    2. services must work behind a load-balancer
    3. services must have state replication, following CAP principle
4. Why might you not want to solve an issue by coding the solution yourself?
    - the code that you write might not be up to their policy or their coding standards. Also, it will be bad as a developers where others will think that you will finish their work for them.
5. Which type of problems should appear first on your priority list?
    - High impact items with easy effort
    - High impact items with high effort
    - Low impact items with easy effort
    - Low impact items with high effort
6. Which factors can you bring to an outside vendor to get the vendor to take your issue seriously?
    - be sensitive to their perception while raising visibility to your issues in a constructive way
    - create a postmortem report
    - build framework that works with vendor's software
    - bring them into the process and show potential shared rewards
