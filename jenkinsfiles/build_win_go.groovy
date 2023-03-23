pipeline {
    agent { label 'windows_fleet' }

    options {
        quietPeriod(60)
        disableConcurrentBuilds()
        timeout(time: 2, unit: 'HOURS')
    }

    stages {
        stage ('Build') {
            steps {
                s3ArtifactCopyInvoke(
                    "PDFNetC64 VS2013/" + getWrappersBranch(branch: env.BRANCH_NAME),
                    "PDFNetC64.zip", params.INVOKER_BUILD_ID
                )

                powershell '''
                    python3 PDFTronGo/build_go.py
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
