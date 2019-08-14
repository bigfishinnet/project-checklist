# Committing to GIT

	1. Own your code and be proud of it (JP).
	2. There are several stages to check before you commit to git and before you request to merge.
    git status
    git log ....
    git add .... -p
    git diff --staged
    git commit
#NOTE: Write a propper git commit message.
    github check for code differences in github before requesting a merge to master.

# Guidance on what to consider for reviewing code in your project.

    1. Check for hardcoded values.
    2. Check there is no authentication included in the code. **IMPORTANT**
    3. Make sure that there is suitable identification tagging in the resources and data blocks.
        https://aws.amazon.com/answers/account-management/aws-tagging-strategies/
    4. Check that output values are suitable / defined to accept lists if they are eventually required.
    5. Try and ensure line length does not exceed 70 characters.
    6. terraform fmt <<<IMPORTANT>>>, then plan, apply, etc.. 
