#Guidance on what to consider across the board for all projects.

	1. Design a theoretical process for the pipeline which is efficient for the team to use in the project. CI/ CD
	2. If required setup GitLAB server and Jenkins server
	3. Create gitlab; accounts; branching strategy.
	4. Create jenkins; accounts; access
	5. Decide what parts you want to automate
	6. Automate this process stage by stage
	7. Create accounts in AWS and AZURE - dev and ops as well as billing, logging, etc..
	8. How many environments do we need, demo, dev, testing, prod, pen testing.
	9. How long are environments taking to build?  Why is taking so long?
	10. When is the go-live date?!! **IMPORTANT**
	11. What are the demands of the app in the production environment.  
	
NOTES:
Pipeline will never be given a priority, it's an Ops engineers job to convince the team that this is a priority and to push to make sure that this is made a priority.
First define a theoretical process showing how code will go from your machine to production, this needs to be efficient for the whole team and should be clearly defined.

In a project meeting you will decide the strategy and pipeline, you will also decide the branch naming conventions.
Most of the time this will adhere to the naming convention in the Jira ticket name. Jira101-VPC for example.
The ticket will be reviewed to check the acceptance criteria has been met.
Make sure you use the Jenkins job in the merge request if used, as otherwise the merge will be rejected.

What is the standard of merge requests?, What is the branching naming convention?

Git branch names should marry with things like JIRA tickets numbers
