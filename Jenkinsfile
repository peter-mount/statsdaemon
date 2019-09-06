// Build properties
properties([
  buildDiscarder(
    logRotator(
      artifactDaysToKeepStr: '',
      artifactNumToKeepStr: '',
      daysToKeepStr: '',
      numToKeepStr: '10'
    )
  ),
  disableConcurrentBuilds(),
  disableResume(),
  pipelineTriggers([
    cron('H H * * *')
  ])
])

// The version to build
version="0.7.1-area51"

// The architectures to build. This is an array of goos & entries per platform eg [goos,arch,goarch,goarm]
amd64 = [ 'amd64',   'amd64', '' ]
arm32v6 = [ 'arm32v6', 'arm',   '6' ]
arm32v7 = [ 'arm32v7', 'arm',   '7' ]
arm64v8 = [ 'arm64v8', 'arm64', ''  ]

architectures = [
  [ 'linux',   [ amd64, arm32v6, arm32v7, arm64v8 ] ],
  [ 'darwin',  [ amd64 ] ],
  [ 'freebsd', [ amd64, arm32v6, arm32v7, arm64v8 ] ],
]

def buildTarget = {
    operatingSystem, architecture, target -> sh "docker build -t test/statsdaemon:latest" +
        " --build-arg goos=" + operatingSystem +
        " --build-arg arch=" + architecture[0] +
        " --build-arg goarch=" + architecture[1] +
        " --build-arg goarm=" + architecture[2] +
        " --build-arg branch=" + BRANCH_NAME +
        " --build-arg buildNumber=" + BUILD_NUMBER +
        " --build-arg version=" + version +
        " --build-arg uploadCred=" + UPLOAD_CRED +
        " --build-arg uploadPath=https://nexus.area51.onl/repository/snapshots/statsdaemon/" + BRANCH_NAME + "/" +
        " --target " + target +
        " ."
}

// Now the build pipeline
node( 'Build' ) {
    withCredentials([
        usernameColonPassword(credentialsId: 'artifact-publisher', variable: 'UPLOAD_CRED')]
    ) {

        stage( 'prepare' ) {
            checkout scm
            buildTarget( 'linux', amd64, 'source' )
        }

        stage( 'test' ) {
            buildTarget( 'linux', amd64, 'test' )
        }

    }
}

architectures.each {
    platform -> stage( platform[0] ) {
        def builders = [:]
        platform[1].each {
            architecture -> builders[ architecture[0] ] = node( "Build" ) {
                withCredentials([
                    usernameColonPassword(credentialsId: 'artifact-publisher', variable: 'UPLOAD_CRED')]
                ) {
                    stage( architecture[0] ) {
                        checkout scm
                        buildTarget(  platform[0], architecture, 'compile' )
                    }
                }
            }
        }
        parallel builders
    }
}
