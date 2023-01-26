String cron_default = "0 0 * * *"

String cron_string = isBaseBranch(env.BRANCH_NAME) ? cron_default : ""

pipeline {
    agent { label 'Courage' }

    options {
        quietPeriod(60)
        disableConcurrentBuilds()
        timeout(time: 2, unit: 'HOURS')
    }

    environment {
        BUILD_TYPE   = "experimental"
    }

    parameters {
        string(defaultValue: "", description: "The calling build number", name: "INVOKER_BUILD_ID")
    }

    stages {
        stage('Checkout') {
            steps {
                toolsCheckout()
            }
        }

        stage ('Build') {
            steps {
                script {
                    def pulling_branch = env.BRANCH_NAME
                    if (env.BRANCH_NAME == 'next_release') {
                        pulling_branch = 'master'
                    }

                    dir('PDFNetC') {
                        s3ArtifactCopyInvoke("PDFNet Mac/" + pulling_branch.replace("/", "%2F"), "PDFNetCMac.zip", params.INVOKER_BUILD_ID)
                    }
                }

                sh '''
                    python3 build.py -cs /usr/local/opt/swig/bin/swig --skip_dl
                '''

                zip zipFile: "build/PDFTronGo.zip", dir: "build/PDFTronGo/pdftron", overwrite: true
            }
        }

        // stage ('Samples') {
        //     steps {
        //         dir('build/PDFTronGo/pdftron/Samples') {
        //             sh './runall_go.sh'
        //         }
        //     }
        // }

        stage ('Upload') {
            steps {
                s3ArtifactUpload("build/PDFTronGo.zip")
                // withCredentials([usernamePassword(credentialsId: 's3_upload_nightly_creds', passwordVariable: 'AWS_SECRET', usernameVariable: 'AWS_ACCESS')]) {
                //     sh '''
                //         python ./script_tools/scripts/PDFTronUploaderGit.py build/PDFTronGo.tar.gz -ak ${AWS_ACCESS} -s ${AWS_SECRET} -b ${BUILD_TYPE} -ak ${AWS_ACCESS} -s ${AWS_SECRET} --force
                //     '''
                // }
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
