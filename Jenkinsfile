/*
 Keyed by country:

 Jenkins Param: COUNTRY
 Values:
 us: USA / domestic
 ca: canada
 au: australia

 First submap is "default" which has common configs for all envs included.
 Generally these are the helm REPO and ROLE, but could include other common values.

 Other submaps are tied to build and deploy environment.
 
 ROKU_DEV = IP of device to build on.
 ROKU_PASS = developer password for roku device.
 */
def environmentMap = [
    "us" : [
        "default" : [
        	"APPNAME": "cbs-roku",
            "REPO" : "allaccess-domestic",
            "ROLE" : "roku",
            "ROKU_DEV" : "10.16.180.78",
            "ROKU_PASS" : "1234",
            "ROKU_GEO" : "domestic",
            "STAGE_PROD": "us",
            "CHANNEL_TOKEN" : "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2t1LXBlcm0iOlsiZ2V0X2RldmljZV9pZCJdLCJzdWIiOiJ1cm46cm9rdS5jb206c3RiLzMxNDQwIiwiaXNzIjoidXJuOnJva3UuY29tOnRva2VubWludDpjaGFubmVsdG9rZW4iLCJqdGkiOiJ1cm46ZDJhMzA0ZjctOGViMS00ZmY0LWFmNzUtNjg2NDExNGFhNzQ0IiwiZXhwIjoxNTU5MzUwODAwLCJpYXQiOjE1NTQ3Njk1MDIsInJva3UtY2hhbm5lbC1pZCI6WyIzMTQ0MCJdLCJuYmYiOjE0NzI5MDQwMDAsInJva3UtdGZ2IjoiMSIsImF1ZCI6InVybjpyb2t1LmNvbTpzdGIvY2hhbm5lbCJ9.DGt01TOljBt1HYaUt8_BxoUn10okS-OBliQ3YAX26W32fWFzsCnN1t6aODD62AHX_srtBDziqLSRbAEXnnEM9a0m_AgVxZ9SBAZSOnV02V-td4i8c3Ep-pre8LP40uAlOeXgawDdBj05lIukdandxfsaT6OXZElKWDaQ6a54oS5FPaUjjs0bmud8UwVtHFaDk9vP94RX53wetwJHysCrgHIlNaHf1uGnDDc8I-rQvaJIjahjt08gT7h20yImnQ7RmON6t2sOSCbnzzNYU7fXB_iQuKi4AJ4YybzvnyN52htacLbuv8dRJ2e4-cplVFSoyVgDSZppfShckZH4AgOjxw",
        ],
        "qa-testwww" : [
            "BUILD_TYPE" : "qa",
            "BUILD_ENV" : "testwww",
            "CONFIG_FILE" : "pkg:/config-staging.json",
            "ANALYTICS_SSL" : "false",
            "MEDIAHEARTBEAT_SSL" : "false",
        ],
        "qa-prod" : [
            "BUILD_TYPE" : "qa",
            "BUILD_ENV" : "prod",
            "CONFIG_FILE" : "pkg:/config.json",
            "ANALYTICS_SSL" : "true",
            "MEDIAHEARTBEAT_SSL" : "true",
        ],
        "cert-prod" : [
            "BUILD_TYPE" : "cert",
            "BUILD_ENV" : "prod",
            "CONFIG_FILE" : "pkg:/config.json",
            "ANALYTICS_SSL" : "true",
            "MEDIAHEARTBEAT_SSL" : "true",
        ],
    ],
    "ca" : [
        "default" : [
        	"APPNAME": "cbs-roku",
            "REPO" : "allaccess-ca",
            "ROLE" : "roku",
            "ROKU_DEV" : "10.16.180.78",
            "ROKU_PASS" : "1234",
            "ROKU_GEO" : "canada",
            "STAGE_PROD": "ca",
            "CHANNEL_TOKEN" : "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2t1LXBlcm0iOlsiZ2V0X2RldmljZV9pZCJdLCJzdWIiOiJ1cm46cm9rdS5jb206c3RiLzMxNDQwIiwiaXNzIjoidXJuOnJva3UuY29tOnRva2VubWludDpjaGFubmVsdG9rZW4iLCJqdGkiOiJ1cm46ZDJhMzA0ZjctOGViMS00ZmY0LWFmNzUtNjg2NDExNGFhNzQ0IiwiZXhwIjoxNTU5MzUwODAwLCJpYXQiOjE1NTQ3Njk1MDIsInJva3UtY2hhbm5lbC1pZCI6WyIzMTQ0MCJdLCJuYmYiOjE0NzI5MDQwMDAsInJva3UtdGZ2IjoiMSIsImF1ZCI6InVybjpyb2t1LmNvbTpzdGIvY2hhbm5lbCJ9.DGt01TOljBt1HYaUt8_BxoUn10okS-OBliQ3YAX26W32fWFzsCnN1t6aODD62AHX_srtBDziqLSRbAEXnnEM9a0m_AgVxZ9SBAZSOnV02V-td4i8c3Ep-pre8LP40uAlOeXgawDdBj05lIukdandxfsaT6OXZElKWDaQ6a54oS5FPaUjjs0bmud8UwVtHFaDk9vP94RX53wetwJHysCrgHIlNaHf1uGnDDc8I-rQvaJIjahjt08gT7h20yImnQ7RmON6t2sOSCbnzzNYU7fXB_iQuKi4AJ4YybzvnyN52htacLbuv8dRJ2e4-cplVFSoyVgDSZppfShckZH4AgOjxw",
        ],
        "qa-testwww" : [
            "BUILD_TYPE" : "qa",
            "BUILD_ENV" : "testwww",
            "CONFIG_FILE" : "pkg:/config-staging.json",
            "ANALYTICS_SSL" : "false",
            "MEDIAHEARTBEAT_SSL" : "false",
        ],
        "qa-prod" : [
            "BUILD_TYPE" : "qa",
            "BUILD_ENV" : "prod",
            "CONFIG_FILE" : "pkg:/config.json",
            "ANALYTICS_SSL" : "true",
            "MEDIAHEARTBEAT_SSL" : "true",
        ],
        "cert-prod" : [
            "BUILD_TYPE" : "cert",
            "BUILD_ENV" : "prod",
            "CONFIG_FILE" : "pkg:/config.json",
            "ANALYTICS_SSL" : "true",
            "MEDIAHEARTBEAT_SSL" : "true",
        ],
    ]
]



//artifactory_server.upload spec: uploadSpec

pipeline {
    agent any
    environment {
        SCRIPTS_ROOT="/home/jenkins/workspace/tools/cbs-tools"
        PATH = "/bin/:/usr/bin/:/usr/local/bin:$JRUBY_ROOT/bin:/usr/bin:/usr/local/bin:$SCRIPTS_ROOT/bin/solr/:$SCRIPTS_ROOT/bin/contest/:$SCRIPTS_ROOT/bin/deploy/:$SCRIPTS_ROOT/bin/can/:$SCRIPTS_ROOT/bin/prod_utilities:$SCRIPTS_ROOT/prod/jenkins:$SCRIPTS_ROOT/bin/infrastructure:$SCRIPTS_ROOT/bin/webmastertools:$SCRIPTS_ROOT/prod/jenkins/phx2/:$RUBYLIB:$SCRIPTS_ROOT/bin/deploy/phx2/:$SCRIPTS_ROOT/docker/bin:$SCRIPTS_ROOT/roku/roku-scripts/:$PATH"
        ARTIFACTORY = "http://maven.cbs.com:7305/artifactory/cbs-roku-deploys"
    }

    triggers {
        pollSCM(env.ENV_NAMESPACE != 'prod' ? '''* * * * *''' : '')
    }
    stages {

        stage('Start') {
            steps {
                script {
                    environmentMap.get(env.COUNTRY).get("default").each{ k, v -> println("Assigning: ${k} -- ${v}") ;env[k] = v }
                    environmentMap.get(env.COUNTRY).get(env.ENV_NAMESPACE).each{ k, v -> println("Assigning: ${k} -- ${v}") ;env[k] = v }
                    //hack to get the right helm user.
                    env.COUNTRY = env.COUNTRY.replaceAll('-util', '')
                    //this sets the command and makes sure that the country / env and roots are all set.
                    env.SUDO_CMD="sudo -u helm_${COUNTRY}_${STAGE_PROD} GOOGLE_APPLICATION_CREDENTIALS=${env.SCRIPTS_ROOT}/docker/global/auth/cbscomdev@i-cbscom-dev.iam.json"
                    //ditto, but with the helm repo and role.
                    env.HELM_TARGET="${env.REPO}/${env.ROLE}"
                }

		slackSend (color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Started by ${getJobInitiator()} on ${new Date().format('yyyy/MM/dd HH:mm:ss')} (<${env.BUILD_URL}|Open)>\n Changes:\n${showChangeLogs()}")
            }
        }
        stage('clean-workspace') {
            steps {
                sh 'git clean -xfd'
            }
        }
        stage('build') {
            steps {
                sh 'echo "Test roku build"'
                sh 'cp -rv $SCRIPTS_ROOT/roku exclude'
                sh 'roku-make all'
            }
        }
        stage('configure-artifactory-and-deploy') {
            steps {
                script {
                    configureArtifactoryAndDeploy()
                }
            }
        }        
    }
    post {
        success {
        	script {
	        	def output = readFile('.roku-make.out')
	            slackSend (channel: "#i-cbsi-roku-deploys", color: 'good', message: "@here ${output}")
            }
        }

        failure {
        	script {
	        	def output = readFile('.roku-make.out')
            	slackSend (channel: "#i-cbsi-roku-deploys", color: 'danger', message: "@here ${env.JOB_NAME} - #${env.BUILD_NUMBER} Failed (<${env.BUILD_URL}|Open)>\n${output}")
        	}
        }
    }
}

@NonCPS
def showChangeLogs() {
	def changeLogSets = currentBuild.changeSets
	def messages = ""
	for (int i = 0; i < changeLogSets.size(); i++) {
	    def entries = changeLogSets[i].items
	    for (int j = 0; j < entries.length; j++) {
		def entry = entries[j]
		messages += " - ${entry.msg} [${entry.author}]\n"
	    }
	}

	if ( messages.equals("") ) 
		messages = "No Changes"

	return messages
}
@NonCPS
def getJobInitiator() {
        def cause = currentBuild.rawBuild.getCause(hudson.model.Cause.UserIdCause.class)
	if ( cause == null ) 
		return "jenkins";
        else
		return cause.getUserName()
}
@NonCPS
def configureArtifactoryAndDeploy() {
    def artifactory_server = Artifactory.server 'maven-cbs-com'
                        //"pattern" : "exclude/dist/packages/*",
    def uploadSpec = """{
                      "files": [{
                        "pattern" : "exclude/dist/",
                        "target" : "cbs-roku-deploys/"
                      }]
                    }"""
    artifactory_server.upload spec: uploadSpec
}
