String cron_default = "0 0 * * *"
String cron_string = (env.BRANCH_NAME != 'pre_release') ? cron_default : (getWrappersBranch('pre_release') == 'master') ? cron_default : ""

pipeline {
    agent { label 'windows_fleet' }

    options {
        quietPeriod(60)
        disableConcurrentBuilds()
        timeout(time: 2, unit: 'HOURS')
    }

    environment {
        GOCACHE      = "/tmp/.cache"
    }

    parameters {
        string(name: "FORCE_BRANCH_VERSION", defaultValue: "" ,
               description: "Set to a version if you wish to change the core SDK version used.")
    }

    stages {
        stage ('Build') {
            steps {
                script {
                    if (params.FORCE_BRANCH_VERSION?.trim()) {
                        s3ArtifactCopyInvoke(
                            "PDFNetC64 VS2013/" + params.FORCE_BRANCH_VERSION.replace("/", "%2F"),
                            "PDFNetC64.zip"
                        )
                    } else {
                        s3ArtifactCopyInvoke(
                            "PDFNetC64 VS2013/" + getWrappersBranch(env.BRANCH_NAME),
                            "PDFNetC64.zip"
                        )
                    }
                }
                

                powershell '''
                    python3 PDFTronGo/build_go.py
                '''
            }
        }

        // stage ('Run test samples') {
        //     steps {
        //         withCredentials([string(credentialsId: 'jenkins/core-sdk-key', variable: 'ENV_LICENSE_KEY')]) {
        //             dir('build/PDFTronGo/pdftron/samples') {
        //                 sh '''
        //                     ./runall_go.bat
        //                 '''
        //             }
        //         }
        //     }
        // }

        stage ('Upload') {
            steps {
                powershell 'move build/PDFTronGo.zip build/PDFTronGoWin.zip'
                s3ArtifactUpload("build/PDFTronGoWin.zip")
            }
        }
    }

    post {
        failure {
            sendMail([
                currentBuild: currentBuild,
                env: env
            ])
        }
    }
}
