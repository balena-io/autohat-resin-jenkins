# AutoHAT-Resin-Jenkins
**This Resin application spawns a jenkins slave for each AutoHAT board connected.**

* AutoHAT boards are detected using the following USB data every 3 minutes:
    * Manufacturer = "Resin.io"
    * Serial = "ABCD"
    * Product = "dtype:deviceType[SKU]"
* Fresh AutoHAT boards are provisioned with [autohat-configurator](https://github.com/resin-io/autohat-configurator)
  * For each board a systemd service is started that uses the ENV variables from Resin to spawn a jenkins slave to the jenkins master ( provided in the ENV ).
    * Device types and SKUs are added as labels to the slave to allow for targetted selection of a board to run tests from Jenkins.
    * The slave runs with 1 executor to ensure that only one job runs at any time on a board.
    * The slaves connect to Jenkins master with the [Jenkins Swarm Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin).
    * When a board is disconnected the jenkins slave systemd service for the board is stopped.
    * Each slave has all the ENV variables required to run tests on the specific AutoHAT boards associated with the slave service.
  * This application runs a Docker in Docker instance to allow for AutoHAT test suites to run.
  * New NUCs added to the application will automatically appear on Jenkins.




Please set the following environment variables in your resin application:

```
NAME=RIG
LOCATION=london
JENKINS_MASTER=https://myjenkinsurl
JENKINS_USERNAME=jenkinsusername
JENKINS_PASSWORD=jenkinspassword
```


## License

Copyright 2017 Resinio Ltd.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing permissions and limitations under the License.
