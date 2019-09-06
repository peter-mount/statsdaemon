# statsdaemon
[![Build Status](http://jenkins.area51.dev/buildStatus/icon?job=peter-mount%2Fstatsdaemon%2Fmaster)](http://jenkins.area51.dev/job/peter-mount/job/statsdaemon/job/master/)
![GitHub last commit](https://badge.area51.onl/github/last-commit/peter-mount/statsdaemon.svg?style=plastic)
![GitHub](https://badge.area51.onl/github/license/peter-mount/statsdaemon.svg?style=plastic)
![GitHub repo size in bytes](https://badge.area51.onl/github/repo-size/peter-mount/statsdaemon.svg?style=plastic)
![Twitter Follow](https://badge.area51.onl/twitter/follow/peter_mount.svg?style=plastic)

This is a fork of [bitly/statsdaemon](https://github.com/bitly/statsdaemon) with a few modifications:

* New -log flag. The original logged to the console the number of stats sent every period spamming syslog when run
inside statsd. This fork doesn't do this unless this flag is set.
* Example systemd script to launch it
* Jenkinsfile thats used by my public Jenkins instance to build it & makes regular public builds

## Download

The recent builds are available via [Nexus](https://nexus.area51.dev/#browse/browse:snapshots:statsdaemon%2Fmaster)
with each file of the format statsdaemon-0.7.1-area51.master.18.darwin-amd64.go1.13.tgz
* statsdaemon-0.7.1-area51 is the version
* master.18 is the master branch build 18
* darwin the operating system
* amd64 the processor architecture
* go1.13 the version of go used in the build, in this instance 1.13

The files are ordered by build number so scroll down until you get to the most recent build.

## Original README

Port of [Etsy's statsd](https://github.com/etsy/statsd), written in Go (originally based
on [amir/gographite](https://github.com/amir/gographite)).

Supports:

* Timing (with optional percentiles)
* Counters (positive and negative with optional sampling)
* Gauges (including relative operations)
* Sets

Initially only integers were supported for metric values, but now double-precision floating-point is supported.

## Command Line Options

```
Usage of ./statsdaemon:
  -address=":8125": UDP service address
  -debug=false: print statistics sent to graphite
  -delete-gauges=true: don't send values to graphite for inactive gauges, as opposed to sending the previous value
  -flush-interval=10: Flush interval (seconds)
  -graphite="127.0.0.1:2003": Graphite service address (or - to disable)
  -log: Log to console every time stats are submitted to graphite
  -max-udp-packet-size=1472: Maximum UDP packet size
  -percent-threshold=[]: percentile calculation for timers (0-100, may be given multiple times)
  -persist-count-keys=60: number of flush-intervals to persist count keys
  -postfix="": Postfix for all stats
  -prefix="": Prefix for all stats
  -receive-counter="": Metric name for total metrics received per interval
  -tcpaddr="": TCP service address, if set
  -version=false: print version string
```
