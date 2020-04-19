# ruby-benchmark-time
Ruby benchmarks with time

## Requirements

- Ruby - MRI, JRuby, etc.
- [GNU Time](https://www.gnu.org/software/time/)

## Getting started

### Bundle

To run the IPS benchmarks we need to install some gems with Bundler.

```sh
gem install bundler
bundle install
```

### Run the benchmarks

```sh
# Run set number of iterations to measure how long those take
./bench.sh

# Run for a set amount of time to measure iterations per second
./bench-ips.sh
```
