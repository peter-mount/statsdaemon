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
architectures = [
  [ 'linux',   [
    [ 'amd64',   'amd64', ''  ],
    [ 'arm32v6', 'arm',   '6' ],
    [ 'arm32v7', 'arm',   '7' ],
    [ 'arm64v8', 'arm64', ''  ],
  ]],
  [ 'darwin', [
    [ 'amd64',   'amd64', ''  ]
  ]],
  [ 'freebsd', [
    [ 'amd64',   'amd64', ''  ],
  ]],
]

def buildTarget = {
    architecture, target -> sh "docker build -t test/statsdaemon:latest" +
        " --build-arg goos=" + architecture[0] +
        " --build-arg arch=" + architecture[1] +
        " --build-arg goarch=" + architecture[2] +
        " --build-arg goarm=" + architecture[3] +
        " --build-arg branch=" + BRANCH_NAME +
        " --build-arg buildNumber=" + BUILD_NUMBER +
        " --build-arg version=" + version +
        " --build-arg uploadCred=" + UPLOAD_CRED +
        " --build-arg uploadPath=https://nexus.area51.onl/repository/snapshots/statsdaemon/" + BRANCH_NAME + "/" +
        " ."
}

// Now the build pipeline
node( 'Build' ) {
  withCredentials([
    usernameColonPassword(credentialsId: 'artifact-publisher', variable: 'UPLOAD_CRED')]
  ) {

    stage( 'prepare' ) {
        checkout scm
        buildTarget( architectures[0][0], architectures[0][1][0], 'build' )
    }

    stage( 'test' ) {
        buildTarget( architectures[0][0], architectures[0][1][0], 'test' )
    }

    architectures.each {
        platform -> stage( platform[0] ) {
            def builders = [:]
            platform[1].each {
                architecture -> stage( architecture[0] ) {
                    buildTarget(  platform[0], architecture, 'compile' )
                }
            }
            parallel builders
        }
    }
  }
}
