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
 */
def environmentMap = [
    "us" : [
        "default" : [
            "REPO" : "allaccess-domestic",
            "ROLE" : "api-web",
        ],
        "dev" : [
            "BUILD_ENV" : "stage-us-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "stage-service-account.json"
        ],
        "stage" : [
            "BUILD_ENV" : "stage-us-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "stage-service-account.json"
        ],
        "shadow" : [
            "BUILD_ENV" : "shadow-us-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "prod-service-account.json"
        ],
        "preview" : [
            "BUILD_ENV" : "preview-us-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "prod-service-account.json"
        ],
        "prod" : [
            "BUILD_ENV" : "prod-us-gcp",
            "STAGE_PROD" : "prod",
            "GCP_BIGTABLE_ENV" : "prod-service-account.json"
        ],
        "test-www" : [
            "BUILD_ENV" : "test-www-us-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "stage-service-account.json"
        ]
    ],
    "us_standby" : [
        "default" : [
            "REPO" : "allaccess-domestic-standby",
            "ROLE" : "api-web",
        ],
        "prod" : [
            "BUILD_ENV" : "prod-standby-us-gcp",
            "STAGE_PROD" : "prod",
            "GCP_BIGTABLE_ENV" : "prod-service-account.json"
        ]
    ],
    "au" : [
        "default" : [
            "REPO" : "allaccess-aus",
            "ROLE" : "api-web",
        ],
        "stage" : [
            "BUILD_ENV" : "stage-aus-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "stage-service-account.json"
        ],
        "shadow" : [
            "BUILD_ENV" : "shadow-aus-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "prod-service-account.json"
        ],
        "preview" : [
            "BUILD_ENV" : "preview-aus-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "prod-service-account.json"
        ],
        "prod" : [
            "BUILD_ENV" : "prod-aus-gcp",
            "STAGE_PROD" : "prod",
            "GCP_BIGTABLE_ENV" : "prod-service-account.json"
        ]
    ],
    "intl" : [
        "default" : [
            "REPO" : "allaccess-intl",
            "ROLE" : "api-web",
        ],
        "stage" : [
            "BUILDR_ENV" : "stage-intl-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "stage-service-account.json"
        ],
        "shadow" : [
            "BUILDR_ENV" : "shadow-intl-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "prod-service-account.json"
        ],
        "preview" : [
            "BUILDR_ENV" : "preview-intl-gcp",
            "STAGE_PROD" : "stage",
            "GCP_BIGTABLE_ENV" : "prod-service-account.json"
        ],
        "prod" : [
            "BUILDR_ENV" : "prod-intl-gcp",
            "STAGE_PROD" : "prod",
            "GCP_BIGTABLE_ENV" : "prod-service-account.json"
        ]
    ],
]

pipeline {
    agent any
    environment {
        PATH = "/bin/:/usr/bin/:/usr/local/bin:$JRUBY_ROOT/bin:/usr/bin:/usr/local/bin:$SCRIPTS_ROOT/bin/solr/:$SCRIPTS_ROOT/bin/contest/:$SCRIPTS_ROOT/bin/deploy/:$SCRIPTS_ROOT/bin/can/:$SCRIPTS_ROOT/bin/prod_utilities:$SCRIPTS_ROOT/prod/jenkins:$SCRIPTS_ROOT/bin/infrastructure:$SCRIPTS_ROOT/bin/webmastertools:$SCRIPTS_ROOT/prod/jenkins/phx2/:$RUBYLIB:$SCRIPTS_ROOT/bin/deploy/phx2/:$SCRIPTS_ROOT/docker/bin:$PATH"
        SCRIPTS_ROOT="/home/jenkins/workspace/tools/cbs-tools"
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
                sh 'ls $SCRIPTS_ROOT/roku'
                
            }
        }
    }
    post {
        success {
            slackSend (color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Success (<${env.BUILD_URL}|Open)>")
        }

        failure {
            slackSend (color: 'danger', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Failed (<${env.BUILD_URL}|Open)>")
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
