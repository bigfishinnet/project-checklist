#Pipeline

    1. Ensure that Jenkins instance is built if not already present in any project,
    2. Ensure it is backed up and you have tested you can restore the backup successfully.
    3. Ensure required plugins are installed in Jenkins. (AWS CLI, Pipeline, Multi-Branch Pipeline)
    4. How many Jenkins Masters and Agents are to be used? Possibly needs to be obtained in the requirements of the whole project.
    5. Ensure staff within the project have access to Jenkins so they can test there code out in the future via Jenkins.
    6. Agree on what type of pipeline is to be used?
    7. Need pipeline to build environments (Dev, Test, Pre-Prod, Prod). This includes Jenkinsfile.
    8. Need pipeline to destroy all NON-Prod environments at the end of every working day to save money. This includes Jenkinsfile.
    9. Ensure that each Jenkins job is set to have the *Do not allow concurrent builds* option selected.
    10. Ensure pipeline jobs are parameterized so that we can pass parameters into the Jenkins pipeline from Choice / Credential / String parameters etc.