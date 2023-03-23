pipeline {
    agent { label 'Courage' }

    options {
        quietPeriod(60)
        disableConcurrentBuilds()
        timeout(time: 2, unit: 'HOURS')
    }

    stages {
        stage ('Build') {
            steps {
                s3ArtifactCopyInvoke(
                    "PDFNet Mac/" + getWrappersBranch(branch: env.BRANCH_NAME),
                    "PDFNetCMac.zip", params.INVOKER_BUILD_ID
                )

                sh '''
                    python3 PDFTronGo/build_go.py -cs /usr/local/opt/swig/bin/swig
                '''
            }
        }

        // stage ('Run test samples') {
        //     steps {
        //         dir('build/PDFTronGo/pdftron/samples') {
        //             sh './runall_go.sh'
        //         }
        //     }
        // }

        stage ('Upload') {
            steps {
                sh 'mv build/PDFTronGo.zip build/PDFTronGoMac.zip'
                s3ArtifactUpload("build/PDFTronGoMac.zip")
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
