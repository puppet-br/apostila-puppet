Facter
======
http://docs.puppetlabs.com/guides/custom_facts.html

http://www.devco.net/archives/2009/10/18/middleware_for_systems_administration.php

I spoke a bit on the puppet IRC channel about my middleware based systems administration tool, I made a video to demo it below.

The concept is that I use publish / subscribe middleware – ActiveMQ with Stomp in my case – to do one-off administration. Unlike using Capistrano or some of those tools I do not need lists of machines or visit each machine with a request because the network supports discovery and a single message to the middleware results in 10s or 100s or 1000s of machines getting the message.

This means any tasks I ask to be done happens in parallel on any number of machines typically I see ~100 machines finish the task in the same time as 1 machine would and no need for SSH or anything like that.


http://www.devco.net/archives/2009/11/10/activemq_clustering.php
