Petshop Template
- Export commands to invoke for CRUD
- Use App Config for env vars
- from aws_lambda_powertools.event_handler import APIGatewayRestResolver
- terraform test
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pipes_pipe
- 
- main branch promote
- API key is optional in terraform
- Provision dynamo db
- Provision inter lambda invocation ??

Lambdas
- cors config

--------------------------------------------------------------------------------
Examon Libs

- Mongo DB examon driver library
  - use graphene for query
- Mongo DB set username and password

--------------------------------------------------------------------------------

UI
- Game
  - Profile
  - History
  - Play
  - Create
- Auth

Terraform
- aws_api_gateway_rest_api_policy

--------------------------------------------------------------------------------
Examon Question Bank 1.0 API

Use TFL:
  https://dev.to/ineedale/terraform-templating-and-loops-479p

General
* Make a production environment
* Make a euat environment

Add typescript to lambda templates

Make sub domain configurable

Setup Terraform Cloud
* Host modules
* Do deployments via terraform cloud

Make s3 bucket configurable

--------------------------------------------------------------------------------
Examon Question Bank 1.1 API

* Add env vars to lambda via app config via powertools
* App Config
   * create secure connection to mongo db




Terraform App

Add config via appConfig
Cloud insights saved searches
Fix install examon
* Terraform Mongo db set config
* MongoDB
  * Mongo Atlas terraform
  * indexes https://www.mongodb.com/docs/manual/core/indexes/create-index/specify-index-name/

examon_writer
b1DPMW4hQjVgbVKt


* API Key
* Secrets Manager
* OpenAPI
* Auth
* Advanced lambda
* Cost Monitoring

Ingest 1.0 -> Lambda -> Mongo DB

----------------------------------------------------------------------------------
Proposal
----------------------------------------------------------------------------------
1. Jira Backlog
2. Screen Designs
3. CI/CD
4. Development Standards

----------------------------------------------------------------------------------
Core 1.5.0
----------------------------------------------------------------------------------

- examon.class decorator
- examon.function decorator
- InputParam question v2
- callable class question
- select random for input param
- Input param collect all inputs to answers

--------------------------------------------------------------------------------
Ideas
* Post to stackoverflow
* Create replit
* Create gist
* Add as cheatsheet
* Record output of each expression using pdb
* https://pythontutor.com/visualize.html#mode=edit
* https://pypi.org/project/pyflowchart/
  * https://github.com/pathrise-eng/pathrise-python-tutor
* timeout exec call
* Open pull request on question

---------------------------------------------------------------------------------
Packages
* Proper Python One Liners Quiz
* Proper Effective Python Quiz
* Proper Beginners Quiz
    * operator precedence
    * list functions
    * function as arg
    * sorting
* Proper Easy Quiz
* Proper PCAP Quiz
* Use temp files for file operations

---------------------------------------------------------------------------------
Proper Examon CLI Doc

----------------------------------------------------------------------------------

Install-ability tests

* Windows
* Pyenv linux

* Install via brew
* Publish artefact

---------------------------------------------------------------------------------
Examon CLI

* pip install only if needed
* pyip.inputStr
    * (support arrow keys)
    * format array, dict

* Homepage doc


---------------------------------------------------------------------------------

Repos

* Add github actions (repo 1)
    * publish
    * Auto publish everything from GHA

---------------------------------------------------------------------------------

Code execution sandbox add drivers

* Execute docker
* starlark
* pyiode
* Execute lambda

---------------------------------------------------------------------------------

```shell
python -m pip install  "examon-repo-1 @ git+https://github.com/JarrodFolinoFC/examon-repo-1"

poetry run python examon/main.py run --pip-module examon_repo_1  --pip-from-list fa
```

* create React app from JSON
