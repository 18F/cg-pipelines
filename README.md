## 18F Cloud Foundry Concourse pipelines

This repo contains various [Concourse](http://concourse.ci/) pipelines that help
manage the 18F Cloud Foundry infrastructure.


### Structure of this repository:

Each pipeline in this repository should be contained within a folder that
contains all of the files related to that pipeline.  In order to keep the
infrastructure secure all of the credentials and other sensitive information
contained in the pipeline should be split out of the pipeline YAML file and
into a credentials YAML file.  You can also create run scripts that automate
the execution or addition of the pipeline through the Concourse
[fly](http://concourse.ci/fly-cli.html) CLI.


#### The structure of this repository will look like:

* {repo-root-dir}/{pipeline-name}/pipeline.yml

    The pipeline.yml file contains the structure of the pipeline and as much
    information as can be made accessible to the public without compromising the
    security of the hosted platform.  If you need help determining what
    information needs to be private consult with the 18F DevOps team.  See the
    "Working with Pipelines" section for information on how to embed private
    variables in the pipeline YAML definition.

* {repo-root-dir}/{pipeline-name}/credentials.yml

  The credentials.yml file contains any private configurations needed to
  complete the Concourse pipeline for the target environment.  These should not
  be versioned with the repository and are ignored in the **.gitignore** file.

* {repo-root-dir}/{pipeline-name}/credentials.example.yml

  The credentials.example.yml file contains a scaffolding of all the private
  properties in the pipeline to make it easier for any of the public users of
  this repository to create a secure credentials.yml file.  This file is
  versioned and can be copied to create a new credentials.yml file.

* {repo-root-dir}/{pipeline-name}/register (**optional**)

  The register script is used when creating a custom fly registration command
  sequence.  This is a simple bash script that should call the required fly CLI
  commands to register the pipeline.  This script is not required.

* {repo-root-dir}/{pipeline-name}/destroy (**optional**)

  The destroy script is used when creating a custom fly removal command
  sequence.  This is a simple bash script that should call the required fly CLI
  commands to remove the pipeline from Concourse.  This script is not required.

* {repo-root-dir}/register

  The register script loops through all of the defined pipelines and either
  calls the register.sh script in each pipeline directory or runs a default
  **set-pipeline** command is no register.sh script is found for the pipeline.

* {repo-root-dir}/destroy

  The destroy script loops through all of the defined pipelines and either
  calls the destroy.sh script in each pipeline directory or runs a default
  **destroy-pipeline** command if no destroy.sh script is found for the pipeline.


### Working with Concourse pipelines:

You can learn a lot about working with pipelines by consulting the
[Concourse documentation](http://concourse.ci/) or by taking a look at this
[tutorial repository](https://github.com/starkandwayne/concourse-tutorial) but
this section will cover some of the basics for assembling the pipelines from
the required files.

#### How to use private variables:

A private variable may be specified anywhere in the pipeline.yml file.  The
syntax is simple.  Any name enclosed in {{}} (double curly brackets) will be
read as a private variable and interpolated into the file from the
credential.yml file.  For example:

./say-something/pipeline.yml

    ---
    jobs:
    - name: job-say-something
      public: true
      plan:
      - task: say-something
        config:
          platform: linux
          image: docker:///busybox
          run:
            path: echo
            args: [{{message}}]


./say-something/credentials.yml

    ---
    message: Hello world!


Properties are listed at the top level of the credential YAML definition.


#### Common fly commands

To login and create a local session, you would run:

    fly --target example login --concourse-url 'https://ci.example.com'


To register this pipeline, you would run:

    fly --target example set-pipeline --pipeline say-something --config ./say-something/pipeline.yml --load-vars-from ./say-something/credentials.yml


To destroy the pipeline in Concourse, you would run:

    fly --target example destroy-pipeline --pipeline say-something
