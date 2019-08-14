# Guidance on what to consider for testing in your project.

	1. What is the testing strategy for the project.  Has this been defined?  Where is it kept?
	2. What tools are being used to test the code?  Are there links to the system that is being used?
	3. Own your code and be proud of it (JP).
	4. Test branch code in local env.
	5. Understand why is it working in my local env?
	6. Test branch code in local env AFTER merge from master
	7. Test branch code in local env AFTER merge from master
	8. Test branch code in local env AFTER merge from master
	9. Request peer review of code
	10. Request merge to master

NOTES:
First pull the repo, create the branch and start coding.
When its ready, test the code by pulling master and merge the master in my branch, then test the code.
Once this has been tested and it's working with the latest master, I create a merge request and alert the team that it's ready and test in Jenkins to show that it successfully merged.

If I started Monday and by Wednesday I think its ready, master has probably moved in this time.
There are lots of master merges and now 50 commits behind.

My code is ready, so pull master and merge the changes down into my branch, then test my branch.
This will have resolved the merge conflicts and issues, once working then create a merge request.

Every morning, pull the master by default. Also pull before a merge request!

Finish whatever task you have started first, work on only the assigned task.
Push people to review code, if its been waiting for a day and you have requested, then go to scrum master and tell them you are waiting for code review to be able to continue your work.
Dev and Ops can both review code.
